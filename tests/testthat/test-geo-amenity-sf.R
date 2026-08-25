test_that("geo_amenity_sf() displays progress for multiple enabled queries", {
  local_mocked_bindings(geo_lite_struct_sf = function(amenity, ...) {
    mock_geo_sf(amenity)
  })

  bbox <- c(-73.9894467311, 40.75573629, -73.9830630737, 40.75789245)

  # No pbar
  expect_silent(geo_amenity_sf(bbox, "restaurant"))
  expect_silent(geo_amenity_sf(bbox, "restaurant", progressbar = TRUE))

  # Get a pbar
  expect_output(geo_amenity_sf(bbox, c("pub", "restaurant")))

  # Not
  expect_silent(geo_amenity_sf(
    bbox,
    c("pub", "restaurant"),
    progressbar = FALSE
  ))
})

test_that("geo_amenity_sf() forwards options and deduplicates amenities", {
  bbox <- c(-2, 40, -1, 41)
  state <- new.env(parent = emptyenv())
  state$calls <- list()

  local_mocked_bindings(geo_lite_struct_sf = function(
    amenity,
    limit,
    full_results,
    return_addresses,
    verbose,
    nominatim_server,
    custom_query,
    points_only
  ) {
    state$calls[[length(state$calls) + 1L]] <- list(
      amenity = amenity,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query,
      points_only = points_only
    )
    mock_geo_sf(amenity)
  })

  out <- geo_amenity_sf(
    bbox,
    c("pub", "restaurant", "pub"),
    limit = 3,
    full_results = TRUE,
    return_addresses = FALSE,
    verbose = TRUE,
    nominatim_server = "https://example.com/nominatim",
    progressbar = FALSE,
    custom_query = list(countrycode = "es"),
    points_only = FALSE
  )

  expect_s3_class(out, "sf")
  expect_named(out, c("query", "address", "geometry"))
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
  expect_false(state$calls[[1]]$points_only)
})

test_that("geo_amenity_sf() strict mode keeps only rows inside the bbox", {
  local_mocked_bindings(geo_lite_struct_sf = function(amenity, ...) {
    sf::st_as_sf(
      dplyr::tibble(
        q_amenity = amenity,
        address = c("inside", "outside"),
        lon = c(0.5, 2),
        lat = c(0.5, 2)
      ),
      coords = c("lon", "lat"),
      crs = 4326
    )
  })

  out <- geo_amenity_sf(
    c(0, 0, 1, 1),
    "pub",
    strict = TRUE,
    progressbar = FALSE
  )

  expect_s3_class(out, "sf")
  expect_named(out, c("query", "address", "geometry"))
  expect_equal(nrow(out), 1)
  expect_equal(out$query, "pub")
  expect_equal(out$address, "inside")
})

test_that("geo_amenity_sf() caps limits and controls output columns", {
  skip_if_api_server()

  expect_message(
    obj <- geo_amenity_sf(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      c("pub", "restaurant"),
      limit = 51
    ),
    "at most 50"
  )

  expect_named(obj, c("query", "address", "geometry"))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_named(obj, c("query", "geometry"))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_named(obj, c("query", "address", "geometry"))

  obj <- geo_amenity_sf(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:2], c("query", "address"))
  expect_gt(ncol(obj), 3)
})

test_that("geo_amenity_sf() forwards custom query options", {
  skip_if_api_server()

  expect_gt(
    nrow(geo_amenity_sf(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      limit = 10,
      custom_query = list(countrycode = "es")
    )),
    4
  )
  expect_equal(
    nrow(geo_amenity_sf(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      custom_query = list(countrycode = "es")
    )),
    1
  )
  expect_equal(
    nrow(geo_amenity_sf(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      "pub",
      custom_query = list(extratags = 1)
    )),
    1
  )
})

test_that("geo_amenity_sf() accepts numeric, sfc and sf bounding boxes", {
  skip_if_api_server()

  expect_lt(
    nrow(geo_amenity_sf(
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
    a <- geo_amenity_sf(bbox = bbox_sfc, "pub", limit = 1, strict = TRUE)
  )
  expect_s3_class(a, "sf")

  bbox_sf <- sf::st_sf(x = 1, bbox_sfc)
  expect_s3_class(bbox_sf, "sf")

  bbox_sf <- sf::st_transform(bbox_sf, 3857)

  expect_silent(
    a <- geo_amenity_sf(bbox = bbox_sf, "pub", limit = 1, strict = TRUE)
  )
  expect_s3_class(a, "sf")
})
