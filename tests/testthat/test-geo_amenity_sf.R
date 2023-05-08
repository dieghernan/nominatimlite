test_that("Returning not reachable", {
  expect_message(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ), "not reachable")

  skip_on_cran()
  skip_if_api_server()

  expect_message(obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "xbzbzbzoa aiaia")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()


  expect_message(
    obj <- geo_amenity_sf(
      bbox = c(-88.1446, 41.5022, -87.4854, 41.8795),
      amenity = "grit_bin"
    ),
    "No results"
  )


  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "grit_bin")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
  expect_equal(nrow(obj), 2)
  expect_identical(as.character(obj$query), c("pub", "restaurant"))


  # Polygon

  expect_message(hosp <- geo_amenity_sf(
    c(
      -3.888954, 40.311977,
      -3.517916, 40.643729
    ),
    c("hospital", "dump", "pub"),
    points_only = FALSE
  ), "No results for query dump")


  expect_true(any("POLYGON" == sf::st_geometry_type(hosp)))
  expect_s3_class(hosp, "sf")
  expect_s3_class(hosp, "tbl")
  expect_identical(sf::st_crs(hosp), sf::st_crs(4326))
  expect_equal(nrow(hosp), 3)
  expect_identical(as.character(hosp$query), c("hospital", "dump", "pub"))
  expect_identical(sf::st_is_empty(hosp), c(FALSE, TRUE, FALSE))
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
    limit = 51
  ), "50 results")


  expect_identical(names(obj), c("query", "address", "geometry"))
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(names(obj), c("query", "geometry"))
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(names(obj), c("query", "address", "geometry"))
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:2], c("query", "address"))
  expect_gt(ncol(obj), 3)
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
  expect_identical(attributes(obj)$sf_column, "geometry")

  expect_gt(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)


  expect_equal(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(countrycode = "es")
  )), 1)

  expect_equal(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(extratags = 1)
  )), 1)

  expect_lt(nrow(geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 1,
    strict = TRUE
  )), 2)
})


test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes
  dup <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    rep(c("pub", "restaurant"), 50),
    limit = 1
  )

  expect_s3_class(dup, "sf")
  expect_s3_class(dup, "tbl")
  expect_identical(sf::st_crs(dup), sf::st_crs(4326))

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("pub", "restaurant"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("pub", "restaurant"), 1))
})


test_that("Verify names", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Ok
  several <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
    limit = 20,
    full_results = TRUE
  )

  expect_identical(names(several), unique(names(several)))

  # Do I have dups by any chance?
  expect_false(any(grepl("\\.[0-9]$", names(several))))
})
