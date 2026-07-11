test_that("Returning empty query", {
  local_mocked_bindings(api_call = function(...) test_fixture("empty.geojson"))

  expect_snapshot(obj <- geo_lite_struct_sf())
  expect_s3_class(obj, "sf")
  expect_true(sf::st_is_empty(obj))

  expect_snapshot(obj <- geo_lite_struct_sf("xbzbzbzoa aiaia"))
  expect_s3_class(obj, "sf")
  expect_true(sf::st_is_empty(obj))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$q_amenity, "xbzbzbzoa aiaia")
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_lite_struct_sf(city = "Madrid")

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(as.character(obj$q_city), "Madrid")
  expect_identical(as.character(sf::st_geometry_type(obj)), "POINT")

  # Polygon

  expect_snapshot(
    test <- geo_lite_struct_sf(
      city = "Madrid",
      points_only = FALSE,
      limit = 100
    )
  )

  expect_contains(as.character(sf::st_geometry_type(test)), "POLYGON")
  expect_s3_class(test, "sf")
  expect_s3_class(test, "tbl")
  expect_gt(nrow(test), 2)
  expect_identical(unique(as.character(test$q_city)), "Madrid")
})

test_that("Successful fixture response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-one.geojson")
  })

  obj <- geo_lite_struct_sf(city = "Madrid", full_results = TRUE)

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$q_city, "Madrid")
  expect_identical(as.character(sf::st_geometry_type(obj)), "POINT")
  expect_contains(names(obj), c("address.city", "extratags.wikidata"))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_message(
    obj <- geo_lite_struct_sf(city = c("Madrid", "Barcelona"), limit = 51),
    "at most 50"
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(rev(names(obj))[1:2], rev(c("address", "geometry")))

  obj <- geo_lite_struct_sf(
    "Madrid",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_no_match(names(obj), "^address$")

  obj <- geo_lite_struct_sf(
    city = "Madrid",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_identical(rev(names(obj))[1:2], rev(c("address", "geometry")))

  obj <- geo_lite_struct_sf(
    city = "Madrid",
    full_results = TRUE,
    return_addresses = FALSE
  )
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_gt(ncol(obj), 4)

  expect_gt(
    nrow(geo_lite_struct_sf(
      "restaurant",
      limit = 50,
      custom_query = list(countrycode = "es")
    )),
    4
  )

  expect_equal(
    nrow(geo_lite_struct_sf("school", custom_query = list(countrycode = "es"))),
    1
  )

  expect_equal(
    nrow(geo_lite_struct_sf("hospital", custom_query = list(extratags = TRUE))),
    1
  )
})


test_that("Fail", {
  local_mocked_bindings(api_call = function(...) FALSE)

  expect_snapshot(several <- geo_lite_struct_sf("madrid", full_results = TRUE))

  expect_all_equal(sf::st_is_empty(several), TRUE)
})
