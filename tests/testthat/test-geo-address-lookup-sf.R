test_that("geo_address_lookup_sf() returns empty geometry without a match", {
  local_mocked_bindings(api_call = function(...) test_fixture("empty.geojson"))

  expect_snapshot(obj <- geo_address_lookup_sf(34633854, "N"))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "N34633854")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("geo_address_lookup_sf() returns an sf tibble", {
  skip_nominatim_ci()

  obj <- geo_address_lookup_sf(34633854, "W")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
})

test_that("geo_address_lookup_sf() parses a successful GeoJSON response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("lookup-one.geojson")
  })

  obj <- geo_address_lookup_sf(10, "N", full_results = TRUE)

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "N10")
  expect_identical(as.character(sf::st_geometry_type(obj)), "POINT")
  expect_contains(names(obj), c("address.city", "extratags.wikidata"))
})

test_that("geo_address_lookup_sf() normalizes OSM IDs before building query", {
  state <- new.env(parent = emptyenv())
  state$urls <- character()

  local_mocked_bindings(api_call = function(url, ...) {
    state$urls <- c(state$urls, url)
    test_fixture("lookup-one.geojson")
  })

  out_string <- geo_address_lookup_sf("10", "N")
  out_decimal <- geo_address_lookup_sf(10.9, "N")
  out_negative <- geo_address_lookup_sf(-10.9, "N")

  expect_identical(out_string$query, "N10")
  expect_identical(out_decimal$query, "N10")
  expect_identical(out_negative$query, "N10")
  expect_length(state$urls, 3)
  expect_equal(
    state$urls,
    rep(
      "https://nominatim.openstreetmap.org/lookup?osm_ids=N10&format=geojson",
      3
    )
  )
})

test_that("geo_address_lookup_sf() adds geometry and custom options to URL", {
  state <- new.env(parent = emptyenv())
  state$url_seen <- NULL

  local_mocked_bindings(api_call = function(url, ...) {
    state$url_seen <- url
    test_fixture("lookup-one.geojson")
  })

  out <- geo_address_lookup_sf(
    10,
    "N",
    full_results = TRUE,
    points_only = FALSE,
    custom_query = list(extratags = TRUE, countrycodes = c("es", "fr"))
  )

  expect_identical(out$query, "N10")
  expect_match(state$url_seen, "lookup\\?osm_ids=N10&format=geojson")
  expect_match(state$url_seen, "polygon_geojson=1", fixed = TRUE)
  expect_match(state$url_seen, "addressdetails=1", fixed = TRUE)
  expect_match(state$url_seen, "extratags=1", fixed = TRUE)
  expect_match(state$url_seen, "countrycodes=es,fr", fixed = TRUE)
})

test_that("geo_address_lookup_sf() warns when some OSM IDs are missing", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("lookup-one.geojson")
  })

  expect_warning(
    out <- geo_address_lookup_sf(c(10, 999), "N", verbose = TRUE),
    "following OSM IDs: N999"
  )

  expect_identical(out$query, "N10")
})

test_that("geo_address_lookup_sf() controls compact and full output columns", {
  skip_nominatim_ci()

  obj <- geo_address_lookup_sf(34633854, "W")

  expect_equal(ncol(obj), 3)
  expect_gt(ncol(geo_address_lookup_sf(34633854, "W", full_results = TRUE)), 3)
})

test_that("geo_address_lookup_sf() forwards geometry and custom options", {
  skip_nominatim_ci()

  expect_equal(
    nrow(geo_address_lookup_sf(
      34633854,
      "W",
      full_results = TRUE,
      custom_query = list(extratags = TRUE)
    )),
    1
  )
  expect_equal(
    nrow(geo_address_lookup_sf(
      34633854,
      "W",
      points_only = FALSE,
      custom_query = list(countrycode = "us")
    )),
    1
  )
  expect_identical(
    as.character(sf::st_geometry_type(geo_address_lookup_sf(
      34633854,
      "W",
      points_only = TRUE,
      custom_query = list(countrycode = "us")
    ))),
    "POINT"
  )
  expect_identical(
    as.character(sf::st_geometry_type(geo_address_lookup_sf(
      34633854,
      "W",
      points_only = FALSE,
      custom_query = list(countrycode = "us")
    ))),
    "POLYGON"
  )
})


test_that("geo_address_lookup_sf() drops unmatched IDs from multiple lookups", {
  skip_nominatim_ci()

  # Ok
  vector_ids <- c(343921, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup_sf(vector_ids, vector_type)
  expect_equal(nrow(several), 2)
  expect_identical(names(several)[1], "query")

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids))

  # KO

  vector_ids <- c(146, 240109189)
  vector_type <- c("J", "N")

  expect_snapshot(
    several <- geo_address_lookup_sf(vector_ids, vector_type, verbose = TRUE)
  )
  expect_equal(nrow(several), 1)
  expect_identical(names(several)[1], "query")

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids)[2])
})


test_that("geo_address_lookup_sf() returns unique column names", {
  skip_nominatim_ci()

  # Ok
  vector_ids <- c(343921, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup_sf(vector_ids, vector_type, full_results = TRUE)

  expect_named(several, unique(names(several)))

  # Do I have dups by any chance?
  expect_no_match(names(several), "\\.[0-9]$")
})

test_that("geo_address_lookup_sf() returns empty geometry after API failure", {
  local_mocked_bindings(api_call = function(...) FALSE)

  vector_ids <- c(343921, 240109189)
  vector_type <- c("R", "N")
  expect_snapshot(
    several <- geo_address_lookup_sf(
      vector_ids,
      vector_type,
      full_results = TRUE
    )
  )

  expect_all_equal(sf::st_is_empty(several), TRUE)
})


test_that("geo_address_lookup_sf() preserves normalized long OSM identifiers", {
  skip_nominatim_ci()

  vector_ids <- "9743343761"

  several <- geo_address_lookup_sf(vector_ids)

  # IDs should have the right string
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)

  # With decimals
  vector_ids2 <- 9743343761.34
  several <- geo_address_lookup_sf(vector_ids2)
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)

  # With negatives
  vector_ids3 <- -1 * vector_ids2
  several <- geo_address_lookup_sf(vector_ids3)
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)
})
