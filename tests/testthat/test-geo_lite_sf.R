test_that("Returning empty query", {
  local_mocked_bindings(api_call = function(...) test_fixture("empty.geojson"))

  expect_snapshot(obj <- geo_lite_sf("xbzbzbzoa aiaia"))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "xbzbzbzoa aiaia")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Data format", {
  skip_if_api_server()

  obj <- geo_lite_sf(c("Madrid", "Barcelona"))

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 2)
  expect_identical(as.character(obj$query), c("Madrid", "Barcelona"))
  expect_equal(as.character(sf::st_geometry_type(obj)), c("POINT", "POINT"))

  # Polygon

  expect_message(
    test <- geo_lite_sf(
      c("Madrid", "ga hann xx kaa pa", "Barcelona"),
      points_only = FALSE
    ),
    "No results were found for the query"
  )

  expect_contains(as.character(sf::st_geometry_type(test)), "POLYGON")
  expect_s3_class(test, "sf")
  expect_s3_class(test, "tbl")
  expect_equal(nrow(test), 3)
  expect_identical(
    as.character(test$query),
    c("Madrid", "ga hann xx kaa pa", "Barcelona")
  )
  expect_identical(sf::st_is_empty(test), c(FALSE, TRUE, FALSE))
})

test_that("Successful fixture response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-one.geojson")
  })

  obj <- geo_lite_sf("Madrid", full_results = TRUE, return_addresses = FALSE)

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$query, "Madrid")
  expect_identical(as.character(sf::st_geometry_type(obj)), "POINT")
  expect_contains(names(obj), c("address.city", "extratags.wikidata"))
})

test_that("Checking query", {
  skip_if_api_server()

  expect_message(
    obj <- geo_lite_sf(c("Madrid", "Barcelona"), limit = 51),
    "at most 50"
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_named(obj, c("query", "address", "geometry"))

  obj <- geo_lite_sf("Madrid", full_results = FALSE, return_addresses = FALSE)

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_named(obj, c("query", "geometry"))

  obj <- geo_lite_sf("Madrid", full_results = FALSE, return_addresses = TRUE)

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_named(obj, c("query", "address", "geometry"))

  obj <- geo_lite_sf("Madrid", full_results = TRUE, return_addresses = FALSE)
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj)[1:2], c("query", "address"))
  expect_gt(ncol(obj), 4)

  expect_gt(
    nrow(geo_lite_sf(
      "Catedral",
      limit = 10,
      custom_query = list(countrycode = "es")
    )),
    4
  )

  expect_equal(
    nrow(geo_lite_sf("Madrid", custom_query = list(countrycode = "es"))),
    1
  )

  expect_equal(
    nrow(geo_lite_sf("Madrid", custom_query = list(extratags = TRUE))),
    1
  )
})

test_that("Dedupe", {
  local_mocked_bindings(
    geo_lite_sf_single = function(address, ...) {
      mock_geo_sf(address)
    }
  )

  # Dupes
  dup <- geo_lite_sf(rep(c("Madrid", "Barcelona"), 50), limit = 1)

  expect_s3_class(dup, "sf")
  expect_s3_class(dup, "tbl")

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("Madrid", "Barcelona"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("Madrid", "Barcelona"), 1))
})

test_that("Verify names", {
  skip_if_api_server()

  # Ok
  several <- geo_lite_sf(
    c("Murcia", "Segovia"),
    limit = 20,
    full_results = TRUE
  )

  expect_named(several, unique(names(several)))

  # Do I have dups by any chance?
  expect_no_match(names(several), "\\.[0-9]$")
})

test_that("Progress bar", {
  local_mocked_bindings(
    geo_lite_sf_single = function(address, ...) {
      mock_geo_sf(address)
    }
  )

  # No pbar
  expect_silent(geo_lite_sf("Madrid"))
  expect_silent(geo_lite_sf("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(geo_lite_sf(c("Madrid", "Barcelona")))

  # Not
  expect_silent(
    geo_lite_sf(c("Madrid", "Barcelona"), progressbar = FALSE)
  )
})
test_that("Fail", {
  local_mocked_bindings(api_call = function(...) FALSE)

  expect_snapshot(several <- geo_lite_sf("madrid", full_results = TRUE))

  expect_all_equal(sf::st_is_empty(several), TRUE)
})
