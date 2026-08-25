test_that("geo_lite() returns a typed row when no address matches", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-empty.json")
  })

  expect_snapshot(obj <- geo_lite("xbzbzbzoa aiaia"))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "xbzbzbzoa aiaia")
  expect_s3_class(obj, "tbl")
  expect_named(obj, c("query", "lat", "lon"))
  expect_equal(
    vapply(obj, class, FUN.VALUE = character(1)),
    c(query = "character", lat = "numeric", lon = "numeric")
  )
  expect_equal(obj$lat, NA_real_)
  expect_equal(obj$lon, NA_real_)

  expect_snapshot(
    obj_renamed <- geo_lite("xbzbzbzoa aiaia", lat = "lata", long = "longa")
  )

  expect_named(obj_renamed, c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("geo_lite() returns a non-spatial tibble", {
  skip_if_api_server()

  obj <- geo_lite("Madrid")

  expect_s3_class(obj, "tbl")
  expect_false(inherits(obj, "sf"))
  # this is _not_ a _sf function
})

test_that("geo_lite() parses a successful JSON response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-one.json")
  })

  obj <- geo_lite("Madrid", full_results = TRUE, return_addresses = FALSE)

  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "Madrid")
  expect_equal(obj$lat, 40.4168)
  expect_equal(obj$lon, -3.7038)
  expect_contains(names(obj), c("address", "boundingbox"))
  expect_type(obj$boundingbox, "list")
})


test_that("geo_lite() caps limits and controls output columns", {
  skip_if_api_server()

  expect_message(
    obj <- geo_lite(c("Madrid", "Barcelona"), limit = 51),
    "at most 50"
  )

  expect_named(obj, c("query", "lat", "lon", "address"))

  obj <- geo_lite(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_named(obj, c("query", "at", "ong"))

  obj <- geo_lite(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_named(obj, c("query", "at", "ong", "address"))

  obj <- geo_lite(
    "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)
})

test_that("geo_lite() forwards custom query options", {
  skip_if_api_server()

  expect_gt(
    nrow(geo_lite(
      "Catedral",
      limit = 10,
      custom_query = list(countrycode = "ES")
    )),
    4
  )

  expect_equal(
    nrow(geo_lite("Madrid", custom_query = list(countrycode = "es"))),
    1
  )

  expect_equal(
    nrow(geo_lite("Madrid", custom_query = list(extratags = TRUE))),
    1
  )
})

test_that("geo_lite() queries unique addresses and restores input order", {
  local_mocked_bindings(geo_lite_single = function(address, lat, long, ...) {
    mock_geo_tbl(address, lat, long)
  })

  # Dupes
  expect_silent(
    dup <- geo_lite(
      rep(c("Pentagon", "Barcelona"), 50),
      limit = 1,
      progressbar = FALSE,
      verbose = FALSE
    )
  )

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("Pentagon", "Barcelona"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("Pentagon", "Barcelona"), 1))
})


test_that("geo_lite() displays progress only for multiple enabled queries", {
  local_mocked_bindings(geo_lite_single = function(address, lat, long, ...) {
    mock_geo_tbl(address, lat, long)
  })

  # No pbar
  expect_silent(geo_lite("Madrid"))
  expect_silent(geo_lite("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(geo_lite(c("Madrid", "Barcelona")))

  # Not
  expect_silent(geo_lite(c("Madrid", "Barcelona"), progressbar = FALSE))
})
test_that("geo_lite() returns a typed row when the API is unavailable", {
  local_mocked_bindings(api_call = function(...) FALSE)

  expect_snapshot(several <- geo_lite("Madrid", full_results = TRUE))

  expect_equal(
    several[, 2:3],
    dplyr::tibble(
      lat = rep(NA_real_, nrow(several)),
      lon = rep(NA_real_, nrow(several))
    )
  )
})
