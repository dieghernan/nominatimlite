test_that("geo_amenity() displays progress only for multiple enabled queries", {
  local_mocked_bindings(geo_lite_struct = function(
    amenity,
    lat = "lat",
    long = "lon",
    ...
  ) {
    mock_geo_tbl(amenity, lat, long)
  })

  bbox <- c(-73.9894467311, 40.75573629, -73.9830630737, 40.75789245)

  # No pbar
  expect_silent(geo_amenity(bbox, "restaurant"))
  expect_silent(geo_amenity(bbox, "restaurant", progressbar = TRUE))

  # Get a pbar
  expect_output(geo_amenity(bbox, c("pub", "restaurant")))

  # Not
  expect_silent(geo_amenity(bbox, c("pub", "restaurant"), progressbar = FALSE))
})

test_that("geo_amenity() forwards options and deduplicates amenities", {
  bbox <- c(-2, 40, -1, 41)
  state <- new.env(parent = emptyenv())
  state$calls <- list()

  local_mocked_bindings(geo_lite_struct = function(
    amenity,
    lat,
    long,
    limit,
    full_results,
    return_addresses,
    verbose,
    nominatim_server,
    custom_query
  ) {
    state$calls[[length(state$calls) + 1L]] <- list(
      amenity = amenity,
      lat = lat,
      long = long,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query
    )
    mock_geo_tbl(amenity, lat, long)
  })

  out <- geo_amenity(
    bbox,
    c("pub", "restaurant", "pub"),
    lat = "latitude",
    long = "longitude",
    limit = 3,
    full_results = TRUE,
    return_addresses = FALSE,
    verbose = TRUE,
    nominatim_server = "https://example.com/nominatim",
    progressbar = FALSE,
    custom_query = list(countrycode = "es")
  )

  expect_named(out, c("query", "latitude", "longitude", "address"))
  expect_equal(out$query, c("pub", "restaurant"))
  expect_length(state$calls, 2)
  expect_equal(
    vapply(state$calls, `[[`, character(1), "amenity"),
    c("pub", "restaurant")
  )
  expect_equal(state$calls[[1]]$custom_query$viewbox, bbox)
  expect_true(state$calls[[1]]$custom_query$bounded)
  expect_identical(state$calls[[1]]$custom_query$countrycode, "es")
  expect_identical(state$calls[[1]]$limit, 3)
  expect_true(state$calls[[1]]$full_results)
  expect_false(state$calls[[1]]$return_addresses)
})

test_that("geo_amenity() strict mode keeps only rows inside the bbox", {
  local_mocked_bindings(geo_lite_struct = function(amenity, lat, long, ...) {
    dplyr::tibble(
      q_amenity = amenity,
      lat = c(0.5, 2),
      lon = c(0.5, 2),
      address = c("inside", "outside")
    )
  })

  out <- geo_amenity(c(0, 0, 1, 1), "pub", strict = TRUE, progressbar = FALSE)

  expect_named(out, c("query", "lat", "lon", "address"))
  expect_equal(nrow(out), 1)
  expect_equal(out$query, "pub")
  expect_equal(out$address, "inside")
  expect_equal(out$lat, 0.5)
  expect_equal(out$lon, 0.5)
})

test_that("geo_amenity() caps limits and controls output columns", {
  skip_if_api_server()

  expect_message(
    obj <- geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      c("pub", "restaurant"),
      limit = 51
    ),
    "at most 50"
  )

  expect_named(obj, c("query", "lat", "lon", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_named(obj, c("query", "at", "ong"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_named(obj, c("query", "at", "ong", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)
})

test_that("geo_amenity() forwards custom query options", {
  skip_if_api_server()

  expect_gt(
    nrow(geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      limit = 10,
      custom_query = list(countrycode = "es")
    )),
    4
  )
  expect_equal(
    nrow(geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      custom_query = list(countrycode = "es")
    )),
    1
  )
  expect_equal(
    nrow(geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      custom_query = list(extratags = 1)
    )),
    1
  )
})

test_that("geo_amenity() applies strict mode to numeric, sfc and sf bboxes", {
  skip_if_api_server()

  expect_lt(
    nrow(geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      limit = 1,
      strict = TRUE
    )),
    2
  )

  bbox_sfc <- bbox_to_poly(c(-1.1446, 41.5022, -0.4854, 41.8795))
  expect_s3_class(bbox_sfc, "sfc")

  expect_silent(
    a <- geo_amenity(bbox = bbox_sfc, "pub", limit = 1, strict = TRUE)
  )
  expect_s3_class(a, "tbl")

  bbox_sf <- sf::st_sf(x = 1, bbox_sfc)
  expect_s3_class(bbox_sf, "sf")

  bbox_sf <- sf::st_transform(bbox_sf, 3857)

  expect_silent(
    a <- geo_amenity(bbox = bbox_sf, "pub", limit = 1, strict = TRUE)
  )
  expect_s3_class(a, "tbl")
})
