test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  bbox <- c(2.113482, 41.328553, 2.206866, 41.420785)

  # No pbar
  expect_silent(geo_amenity(bbox, "school"))
  expect_silent(geo_amenity(bbox, "school", progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- geo_amenity(bbox, c("pub", "school")))

  # Not
  expect_silent(aa <- geo_amenity(
    bbox, c("pub", "school"),
    progressbar = FALSE
  ))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  expect_message(obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
    limit = 51
  ), "50 results")


  expect_identical(names(obj), c("amenity", "lat", "lon", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(names(obj), c("amenity", "at", "ong"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(names(obj), c("amenity", "at", "ong", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("amenity", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)


  expect_gt(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 10,
    custom_query = list(countrycode = "es")
  )), 4)
  expect_equal(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(countrycode = "es")
  )), 1)
  expect_equal(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    custom_query = list(extratags = 1)
  )), 1)

  expect_lt(nrow(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    limit = 1,
    strict = TRUE
  )), 2)

  bbox_sfc <- bbox_to_poly(c(-1.1446, 41.5022, -0.4854, 41.8795))
  expect_s3_class(bbox_sfc, "sfc")

  expect_silent(a <- geo_amenity(
    bbox = bbox_sfc,
    "pub",
    limit = 1,
    strict = TRUE
  ))


  bbox_sf <- sf::st_sf(x = 1, bbox_sfc)
  expect_s3_class(bbox_sf, "sf")

  bbox_sf <- sf::st_transform(bbox_sf, 3857)

  expect_silent(a <- geo_amenity(
    bbox = bbox_sf,
    "pub",
    limit = 1,
    strict = TRUE
  ))
})
