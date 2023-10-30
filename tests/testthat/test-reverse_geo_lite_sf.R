test_that("Errors", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_error(
    reverse_geo_lite_sf(0, c(2, 3)),
    "lat and long should have the same number"
  )
  expect_error(
    reverse_geo_lite_sf("a", "a"),
    "must be numeric"
  )
})

test_that("Messages", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_message(obj <- reverse_geo_lite_sf(0, 200))
  expect_true(nrow(obj) == 1)
  expect_true(obj$lon == 180)
  expect_true(is.na(obj$address))
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))

  expect_message(obj <- reverse_geo_lite_sf(200, 200))
  expect_true(nrow(obj) == 1)
  expect_true(obj$lat == 90)
  expect_true(is.na(obj$address))
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_true(sf::st_is_empty(obj))
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))
})


test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- reverse_geo_lite_sf(89.999999, 179.9999),
    "No results for query lon"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$lat == 89.999999)
  expect_true(obj$lon == 179.9999)
  expect_s3_class(obj, "tbl")
  expect_s3_class(obj, "sf")
  expect_identical(names(obj), c("address", "lat", "lon", "geometry"))
  expect_true(is.na(obj$address))

  expect_message(
    obj_renamed <- reverse_geo_lite_sf(89.999999, 179.9999,
      address = "adddata"
    ),
    "No results for"
  )

  expect_identical(names(obj_renamed), c("adddata", "lat", "lon", "geometry"))

  names(obj_renamed) <- names(obj)

  expect_identical(sf::st_drop_geometry(obj), sf::st_drop_geometry(obj_renamed))
  expect_identical(sf::st_geometry(obj), sf::st_geometry(obj_renamed))
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  obj <- reverse_geo_lite_sf(42, 3)
  expect_s3_class(obj, "sf")
  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_true(all(grepl("POINT", sf::st_geometry_type(obj))))

  # Polygon

  expect_message(test <- reverse_geo_lite_sf(
    c(42.34, 89.9999, 39.6777),
    c(-3.474, -179.9999, -4.8383),
    points_only = FALSE,
    custom_query = list(zoom = 5)
  ), "No results for query lon")


  expect_true(any(grepl("POLYGON", sf::st_geometry_type(test))))
  expect_s3_class(test, "sf")
  expect_s3_class(test, "tbl")
  expect_equal(nrow(test), 3)

  expect_identical(sf::st_is_empty(test), c(FALSE, TRUE, FALSE))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- reverse_geo_lite_sf(40.4207414, -3.6687109)
  expect_s3_class(obj, "tbl")
  expect_s3_class(obj, "sf")
  expect_equal(nrow(obj), 1)

  expect_identical(names(obj), c("address", "lat", "lon", "geometry"))

  # Same with different zoom
  obj_zoom <- reverse_geo_lite_sf(40.4207414, -3.6687109,
    custom_query = list(zoom = 3)
  )


  expect_s3_class(obj_zoom, "tbl")
  expect_s3_class(obj_zoom, "sf")

  expect_equal(nrow(obj_zoom), 1)
  expect_false(identical(obj, obj_zoom))

  # Several coordinates
  sev <- reverse_geo_lite_sf(
    lat = c(40.75728, 55.95335),
    long = c(-73.98586, -3.188375)
  )

  expect_equal(nrow(sev), 2)
  expect_s3_class(sev, "tbl")
  expect_s3_class(sev, "sf")

  # Check opts
  obj <- reverse_geo_lite_sf(40.4207414, -3.6687109,
    address = "addrs"
  )

  expect_s3_class(obj, "tbl")
  expect_s3_class(obj, "sf")
  expect_equal(nrow(obj), 1)

  expect_identical(names(obj), c("addrs", "lat", "lon", "geometry"))


  # Check opts
  obj <- reverse_geo_lite_sf(40.4207414, -3.6687109,
    address = "addrs", return_coords = FALSE
  )

  expect_s3_class(obj, "tbl")
  expect_s3_class(obj, "sf")
  expect_identical(names(obj), c("addrs", "geometry"))

  obj <- reverse_geo_lite_sf(40.4207414, -3.6687109,
    address = "addrs", return_coords = FALSE,
    full_results = TRUE
  )

  expect_s3_class(obj, "tbl")
  expect_s3_class(obj, "sf")
  expect_identical(names(obj)[1:3], c("addrs", "lat", "lon"))
  expect_gt(ncol(obj), 5)

  obj2 <- reverse_geo_lite_sf(40.4207414, -3.6687109,
    address = "addrs", return_coords = TRUE,
    full_results = TRUE
  )

  expect_identical(obj, obj2)
})


test_that("Check unnesting", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Several coordinates
  sev <- reverse_geo_lite_sf(
    lat = c(40.75728, 55.95335),
    long = c(-73.98586, -3.188375),
    full_results = TRUE,
    custom_query = list(extratags = 1)
  )

  expect_s3_class(sev, "tbl")
  expect_equal(nrow(sev), 2)


  # Classes of all cols

  colclass <- vapply(sf::st_drop_geometry(sev),
    class,
    FUN.VALUE = character(1)
  )

  # Not lists
  expect_false(any(grepl("list", colclass)))
})

test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes

  lats <- rep(c(40.75728, 55.95335), 50)
  longs <- rep(c(-73.98586, -3.188375), 50)

  expect_silent(dup <- reverse_geo_lite_sf(lats, longs))

  expect_s3_class(dup, "sf")
  expect_s3_class(dup, "tbl")
  expect_equal(nrow(dup), 100)

  nms <- unique(as.character(dup$address))
  expect_length(nms, 2)
  expect_equal(as.character(dup$address), rep(nms, 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$address), nms)
})
