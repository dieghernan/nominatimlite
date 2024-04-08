test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- geo_lite_sf("xbzbzbzoa aiaia"),
    "No results for"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "xbzbzbzoa aiaia")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_lite_sf(c("Madrid", "Barcelona"))

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 2)
  expect_identical(as.character(obj$query), c("Madrid", "Barcelona"))
  expect_true(all(grepl("POINT", sf::st_geometry_type(obj))))


  # Polygon

  expect_message(test <- geo_lite_sf(
    c("Madrid", "ga hann xx kaa pa", "Barcelona"),
    points_only = FALSE
  ), "No results for query ga hann xx kaa pa")


  expect_true(any(grepl("POLYGON", sf::st_geometry_type(test))))
  expect_s3_class(test, "sf")
  expect_s3_class(test, "tbl")
  expect_equal(nrow(test), 3)
  expect_identical(
    as.character(test$query),
    c("Madrid", "ga hann xx kaa pa", "Barcelona")
  )
  expect_identical(sf::st_is_empty(test), c(FALSE, TRUE, FALSE))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(
    obj <- geo_lite_sf(c("Madrid", "Barcelona"),
      limit = 51
    ), "50 results"
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "address", "geometry"))

  obj <- geo_lite_sf("Madrid",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "geometry"))


  obj <- geo_lite_sf("Madrid",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "address", "geometry"))

  obj <- geo_lite_sf("Madrid",
    full_results = TRUE,
    return_addresses = FALSE
  )
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj)[1:2], c("query", "address"))
  expect_gt(ncol(obj), 4)


  expect_gt(
    nrow(geo_lite_sf("Catedral",
      limit = 10,
      custom_query = list(countrycode = "es")
    )), 4
  )

  expect_equal(
    nrow(geo_lite_sf("Madrid",
      custom_query = list(countrycode = "es")
    )), 1
  )

  expect_equal(
    nrow(geo_lite_sf("Madrid",
      custom_query = list(extratags = TRUE)
    )), 1
  )
})

test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes
  dup <- geo_lite_sf(
    rep(c("Madrid", "Barcelona"), 50),
    limit = 1
  )

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
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Ok
  several <- geo_lite_sf(
    c("Murcia", "Segovia"),
    limit = 20,
    full_results = TRUE
  )

  expect_identical(names(several), unique(names(several)))

  # Do I have dups by any chance?
  expect_false(any(grepl("\\.[0-9]$", names(several))))
})

test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()
  # No pbar
  expect_silent(geo_lite_sf("Madrid"))
  expect_silent(geo_lite_sf("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- geo_lite_sf(c("Madrid", "Barcelona")))

  # Not
  expect_silent(
    aa <- geo_lite_sf(c("Madrid", "Barcelona"), progressbar = FALSE)
  )
})
test_that("Fail", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # KO
  expect_snapshot(several <- geo_lite_sf(
    "madrid",
    full_results = TRUE,
    nominatim_server = "https://xyz.com/"
  ))

  expect_true(all(sf::st_is_empty(several)))
})
