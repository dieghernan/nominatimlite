test_that("Returning Empty", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- geo_address_lookup_sf(34633854, "N"),
    "No results for query"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "N34633854")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_address_lookup_sf(34633854, "W")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_address_lookup_sf(34633854, "W")

  expect_equal(ncol(obj), 3)
  expect_gt(ncol(geo_address_lookup_sf(34633854, "W", full_results = TRUE)), 3)
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
  expect_true(
    sf::st_geometry_type(geo_address_lookup_sf(
      34633854,
      "W",
      points_only = TRUE,
      custom_query = list(countrycode = "us")
    )) ==
      "POINT"
  )
  expect_true(
    sf::st_geometry_type(geo_address_lookup_sf(
      34633854,
      "W",
      points_only = FALSE,
      custom_query = list(countrycode = "us")
    )) ==
      "POLYGON"
  )
})


test_that("Handle several", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Ok
  vector_ids <- c(146656, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup_sf(vector_ids, vector_type)
  expect_equal(nrow(several), 2)
  expect_identical(names(several)[1], "query")

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids))

  # KO

  vector_ids <- c(146, 240109189)
  vector_type <- c("J", "N")

  expect_warning(
    several <- geo_address_lookup_sf(vector_ids, vector_type, verbose = TRUE),
    "Check the final object"
  )
  expect_equal(nrow(several), 1)
  expect_identical(names(several)[1], "query")

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids)[2])
})


test_that("Verify names", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Ok
  vector_ids <- c(146656, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup_sf(vector_ids, vector_type, full_results = TRUE)

  expect_identical(names(several), unique(names(several)))

  # Do I have dups by any chance?
  expect_false(any(grepl("\\.[0-9]$", names(several))))
})

test_that("Fail", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # KO
  vector_ids <- c(146656, 240109189)
  vector_type <- c("R", "N")
  expect_snapshot(
    several <- geo_address_lookup_sf(
      vector_ids,
      vector_type,
      full_results = TRUE,
      nominatim_server = "https://xyz.com/"
    )
  )

  expect_true(all(sf::st_is_empty(several)))
})


test_that("Integers #47", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  vector_ids <- "9743343761"

  several <- geo_address_lookup_sf(vector_ids)

  # IDs should have the right string
  comp <- unique(gsub("[^0-9]", "", several$query))

  expect_identical(vector_ids, comp)

  # With decimals
  vector_ids2 <- 9743343761.34
  several <- geo_address_lookup_sf(vector_ids2)

  expect_identical(vector_ids, comp)

  # With negatives
  vector_ids3 <- -1 * vector_ids2
  several <- geo_address_lookup_sf(vector_ids3)

  expect_identical(vector_ids, comp)
})
