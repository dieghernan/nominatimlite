test_that("add_custom_query() ignores unnamed options and encodes named ones", {
  u <- "http://test"
  t <- add_custom_query(custom_query = list(), url = u)
  expect_identical(u, t)

  # Unnamed argument
  t <- add_custom_query(custom_query = list(1, b = 2), url = u)
  expect_identical(u, t)

  # Unnamed argument
  t <- add_custom_query(custom_query = list(a = 1, 2), url = u)
  expect_identical(u, t)

  # Unnamed argument
  t <- add_custom_query(custom_query = list(3), url = u)
  expect_identical(u, t)

  # Check
  t <- add_custom_query(custom_query = list(a = 3, b = 3), url = u)
  expect_identical("http://test&a=3&b=3", t)
})

test_that("prepare_api_url() normalizes default and custom server URLs", {
  t <- prepare_api_url(entry = "an_entry")
  expect_identical(t, "https://nominatim.openstreetmap.org/an_entry")

  # Add trailing slash
  t2 <- prepare_api_url("https://nominatim.openstreetmap.org", "an_entry")
  expect_identical(t, t2)

  # Custom server
  t3 <- prepare_api_url("http://localhost:2322/nominatim-update", "custom")
  expect_identical(t3, "http://localhost:2322/nominatim-update/custom")
})

test_that("URL builders encode endpoint-specific query options", {
  expect_identical(
    build_search_url(
      "https://example.com",
      format = "json",
      limit = 10,
      full_results = TRUE,
      query = "New York",
      points_only = FALSE,
      custom_query = list(countrycodes = c("us", "ca"), extratags = TRUE)
    ),
    paste0(
      "https://example.com/search?q=New+York&format=json&limit=10",
      "&addressdetails=1&polygon_geojson=1&countrycodes=us,ca&extratags=1"
    )
  )

  expect_identical(
    build_search_url(
      "https://example.com",
      format = "geojson",
      limit = 1,
      full_results = FALSE,
      query = NULL
    ),
    "https://example.com/search?format=geojson&limit=1"
  )

  expect_identical(
    build_reverse_url(
      "https://example.com",
      lat = 42,
      long = -3,
      format = "json",
      full_results = FALSE
    ),
    "https://example.com/reverse?lat=42&lon=-3&format=json&addressdetails=0"
  )

  expect_identical(
    build_lookup_url(
      "https://example.com",
      nodes = "N1,W2",
      full_results = TRUE,
      custom_query = list(namedetails = TRUE)
    ),
    paste0(
      "https://example.com/lookup?osm_ids=N1,W2&format=jsonv2",
      "&addressdetails=1&namedetails=1"
    )
  )
})

test_that("cap helpers validate and report adjusted values", {
  expect_identical(cap_limit(10), 10)
  expect_message(limit <- cap_limit(51), "at most 50")
  expect_identical(limit, 50)

  expect_snapshot(error = TRUE, cap_coordinates("a", 1))
  expect_snapshot(error = TRUE, cap_coordinates(1, c(1, 2)))
  expect_snapshot(error = TRUE, cap_coordinates(NA_real_, 1))
  expect_snapshot(error = TRUE, cap_coordinates(1, NA_real_))

  expect_silent(integer_coords <- cap_coordinates(1L, 1L))
  expect_equal(integer_coords, list(lat = 1, long = 1))

  expect_snapshot(coords <- cap_coordinates(200, -200))
  expect_identical(coords$lat, 90)
  expect_identical(coords$long, -180)
})

test_that("sf_to_tbl() restores sf tibble classes", {
  normal_sf <- sf::st_as_sf(
    data.frame(x = 1, lon = 0, lat = 0),
    coords = c("lat", "lon"),
    crs = 4326
  )
  expect_s3_class(normal_sf, c("sf", "data.frame"), exact = TRUE)

  tbl_sf <- sf_to_tbl(normal_sf)
  expect_s3_class(tbl_sf, c("sf", "tbl_df"))
})

test_that("normalize_bbox() transforms sf and sfc inputs to coordinates", {
  bbox <- c(1, 2, 3, 4)
  bbox_sfc <- bbox_to_poly(bbox)
  bbox_sf <- sf::st_sf(id = 1, geometry = bbox_sfc)

  expect_equal(normalize_bbox(bbox_sfc), bbox)
  expect_equal(normalize_bbox(bbox_sf), bbox)
})

test_that("unnest_sf() removes placeholders for missing extra tags", {
  sfobj <- sf::st_as_sf(
    data.frame(extratags = NA_character_, lon = 0, lat = 0),
    coords = c("lon", "lat"),
    crs = 4326
  )

  out <- unnest_sf(sfobj)

  expect_s3_class(out, "sf")
  expect_named(out, "geometry")
})

test_that("is_named() distinguishes complete names from missing names", {
  # No names -> first branch
  expect_false(is_named(1:3))
  expect_false(is_named(list(1, 2, 3)))

  # NA names -> second branch
  x_na <- c(a = 1, b = 2, c = 3)
  names(x_na)[3] <- NA_character_
  expect_false(is_named(x_na))

  # Empty names -> third branch
  x_empty <- c(a = 1, b = 2, c = 3)
  names(x_empty)[2] <- ""
  expect_false(is_named(x_empty))

  # Valid names -> TRUE branch
  expect_true(is_named(c(a = 1, b = 2, c = 3)))
  expect_true(is_named(list(a = 1, b = 2, c = 3)))

  # Edge case: empty but named object
  expect_true(is_named(setNames(numeric(), character())))
})
