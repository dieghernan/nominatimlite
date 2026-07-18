test_that("Returning empty query", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-empty.json")
  })

  expect_snapshot(obj <- geo_address_lookup(34633854, "N"))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "N34633854")
  expect_s3_class(obj, "tbl")
  expect_named(obj, c("query", "lat", "lon"))

  objclass <- vapply(obj, class, FUN.VALUE = character(1))

  expect_equal(
    objclass,
    c(query = "character", lat = "numeric", lon = "numeric")
  )
  expect_equal(obj$lat, NA_real_)
  expect_equal(obj$lon, NA_real_)

  expect_snapshot(
    obj_renamed <- geo_address_lookup(
      34633854,
      "N",
      lat = "lata",
      long = "longa"
    )
  )

  expect_named(obj_renamed, c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("Data format", {
  skip_if_api_server()

  out <- geo_address_lookup(34633854, "W")

  expect_s3_class(out, "tbl")
  expect_false(inherits(out, "sf"))
})

test_that("Successful fixture response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("lookup-one.json")
  })

  obj <- geo_address_lookup(10, "N", full_results = TRUE)

  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "N10")
  expect_equal(obj$lat, 40.4168)
  expect_equal(obj$lon, -3.7038)
  expect_contains(names(obj), c("address", "boundingbox"))
  expect_type(obj$boundingbox, "list")
})

test_that("geo_address_lookup() normalizes OSM IDs before building query", {
  state <- new.env(parent = emptyenv())
  state$urls <- character()

  local_mocked_bindings(
    api_call = function(url, ...) {
      state$urls <- c(state$urls, url)
      test_fixture("lookup-one.json")
    }
  )

  out_string <- geo_address_lookup("10", "N")
  out_decimal <- geo_address_lookup(10.9, "N")
  out_negative <- geo_address_lookup(-10.9, "N")

  expect_identical(out_string$query, "N10")
  expect_identical(out_decimal$query, "N10")
  expect_identical(out_negative$query, "N10")
  expect_length(state$urls, 3)
  expect_equal(
    state$urls,
    rep(
      "https://nominatim.openstreetmap.org/lookup?osm_ids=N10&format=jsonv2",
      3
    )
  )
})

test_that("geo_address_lookup() adds full results and custom options to URL", {
  state <- new.env(parent = emptyenv())
  state$url_seen <- NULL

  local_mocked_bindings(
    api_call = function(url, ...) {
      state$url_seen <- url
      test_fixture("lookup-one.json")
    }
  )

  out <- geo_address_lookup(
    10,
    "N",
    full_results = TRUE,
    custom_query = list(extratags = TRUE, countrycodes = c("es", "fr"))
  )

  expect_identical(out$query, "N10")
  expect_match(state$url_seen, "lookup\\?osm_ids=N10&format=jsonv2")
  expect_match(state$url_seen, "addressdetails=1", fixed = TRUE)
  expect_match(state$url_seen, "extratags=1", fixed = TRUE)
  expect_match(state$url_seen, "countrycodes=es,fr", fixed = TRUE)
})

test_that("geo_address_lookup() warns when some OSM IDs are missing", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("lookup-one.json")
  })

  expect_warning(
    out <- geo_address_lookup(c(10, 999), "N", verbose = TRUE),
    "No results were found for some OSM IDs"
  )

  expect_identical(out$query, "N10")
})

test_that("Checking query", {
  skip_if_api_server()

  obj <- geo_address_lookup(32965412, "W")

  expect_named(obj, c("query", "lat", "lon", "address"))

  obj <- geo_address_lookup(
    34633854,
    "W",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_named(obj, c("query", "at", "ong"))

  obj <- geo_address_lookup(
    34633854,
    "W",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )
  expect_named(obj, c("query", "at", "ong", "address"))

  obj <- geo_address_lookup(
    34633854,
    "W",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = TRUE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)

  expect_equal(
    nrow(geo_address_lookup(
      34633854,
      "W",
      full_results = TRUE,
      custom_query = list(extratags = TRUE)
    )),
    1
  )

  expect_equal(
    nrow(geo_address_lookup(
      34633854,
      "W",
      custom_query = list(countrycode = "us")
    )),
    1
  )
})


test_that("Handle several", {
  skip_if_api_server()

  # Ok
  vector_ids <- c(343921, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup(vector_ids, vector_type)
  expect_equal(nrow(several), 2)
  expect_named(several, c("query", "lat", "lon", "address"))

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids))

  # KO

  vector_ids <- c(146, 240109189)
  vector_type <- c("J", "N")

  expect_snapshot(
    several <- geo_address_lookup(vector_ids, vector_type, verbose = TRUE)
  )

  expect_equal(nrow(several), 1)
  expect_named(several, c("query", "lat", "lon", "address"))

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids)[2])
})

test_that("Fail", {
  local_mocked_bindings(api_call = function(...) FALSE)

  vector_ids <- c(343921, 240109189)
  vector_type <- c("R", "N")
  expect_snapshot(
    several <- geo_address_lookup(
      vector_ids,
      vector_type,
      full_results = TRUE
    )
  )

  expect_equal(
    several[, 2:3],
    dplyr::tibble(
      lat = rep(NA_real_, nrow(several)),
      lon = rep(NA_real_, nrow(several))
    )
  )
})


test_that("Integers #47", {
  skip_if_api_server()

  vector_ids <- "9743343761"

  several <- geo_address_lookup(vector_ids)

  # IDs should have the right string
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)

  # With decimals
  vector_ids2 <- 9743343761.34
  several <- geo_address_lookup(vector_ids2)
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)

  # With negatives
  vector_ids3 <- -1 * vector_ids2
  several <- geo_address_lookup(vector_ids3)
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)
})
