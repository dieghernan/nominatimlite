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

test_that("message helpers report unavailable and empty API responses", {
  expect_message(
    unavailable <- message_api_unavailable("https://example.com/search"),
    "Could not reach the API endpoint: https://example.com/search\\."
  )
  expect_null(unavailable)

  expect_message(empty <- message_no_results(), "No results were found")
  expect_null(empty)

  expect_message(
    empty_query <- message_no_results("Madrid"),
    "No results were found for the query: Madrid\\."
  )
  expect_null(empty_query)
})

test_that("query helpers normalize structured and custom options", {
  pars <- structured_query_params(
    amenity = c("cafe", "pub"),
    city = "New York",
    country = "US"
  )

  expect_identical(
    pars,
    list(
      amenity = "cafe",
      street = NA_character_,
      city = "New York",
      county = NA_character_,
      state = NA_character_,
      country = "US",
      postalcode = NA_character_
    )
  )

  query <- structured_query_tbl(pars)
  expect_s3_class(query, "tbl")
  expect_named(
    query,
    c(
      "q_amenity",
      "q_street",
      "q_city",
      "q_county",
      "q_state",
      "q_country",
      "q_postalcode"
    )
  )

  compact <- compact_query_options(list(
    city = "New York",
    county = NULL,
    state = NA_character_,
    bounded = FALSE
  ))
  expect_identical(compact, list(city = "New York", bounded = FALSE))
  expect_identical(encode_query_value(TRUE), "1")
  expect_identical(encode_query_value(FALSE), "0")
  expect_identical(encode_query_value(c("us", "ca")), "us,ca")
  expect_identical(encode_search_text("New York City"), "New+York+City")
})

test_that("URL option helpers add only requested response details", {
  url <- "https://example.com/search?format=json"

  expect_identical(add_address_details(url, FALSE), url)
  expect_identical(
    add_address_details(url, FALSE, always = TRUE),
    paste0(url, "&addressdetails=0")
  )
  expect_identical(
    add_address_details(url, TRUE),
    paste0(url, "&addressdetails=1")
  )
  expect_identical(add_polygon_geojson(url, TRUE), url)
  expect_identical(
    add_polygon_geojson(url, FALSE),
    paste0(url, "&polygon_geojson=1")
  )
})

test_that("coordinate helpers rename and convert API columns", {
  input <- dplyr::tibble(lat = "40.5", lon = "-3.5", value = 1L)

  renamed <- rename_coordinate_cols(input, lat = "latitude", long = "longitude")
  expect_named(renamed, c("latitude", "longitude", "value"))

  converted <- convert_coordinate_cols(
    renamed,
    lat = "latitude",
    long = "longitude"
  )
  expect_type(converted$latitude, "double")
  expect_type(converted$longitude, "double")
  expect_identical(converted$latitude, 40.5)
  expect_identical(converted$longitude, -3.5)
})

test_that("reverse query helpers clamp, deduplicate and bind coordinates", {
  expect_message(
    keys <- reverse_query_keys(c(100, 100, 40), c(20, 20, -3)),
    "Latitude values outside"
  )
  expect_message(
    longitude_keys <- reverse_query_keys(40, 200),
    "Longitude values outside"
  )

  expect_equal(nrow(keys$init), 3)
  expect_equal(nrow(keys$unique), 2)
  expect_identical(keys$unique$lat_cap_int, c(90, 40))
  expect_identical(keys$unique$long_cap_int, c(20, -3))
  expect_identical(longitude_keys$unique$long_cap_int, 180)

  out <- run_reverse_queries(
    keys$unique,
    progressbar = FALSE,
    function(lat_cap, long_cap) {
      dplyr::tibble(result = paste(lat_cap, long_cap))
    }
  )

  expect_named(out, c("result", "lat_key_int", "long_key_int"))
  expect_identical(out$result, c("90 20", "40 -3"))
})

test_that("progress_lapply() preserves values with and without progress", {
  quiet <- progress_lapply(1, FALSE, \(i) i * 2)
  expect_identical(quiet, list(2))

  # jarl-ignore-start implicit_assignment: Use anonymous function
  expect_output(
    visible <- progress_lapply(2, TRUE, \(i) i * 2),
    "100%",
    fixed = TRUE
  )
  # jarl-ignore-end implicit_assignment
  expect_identical(visible, list(2, 4))
})

test_that("keep_names() selects compact fields and unnests bounding boxes", {
  input <- dplyr::tibble(
    query = "Madrid",
    lat = "40.4",
    lon = "-3.7",
    display_name = "Madrid, Spain",
    boundingbox = list(c("40", "41", "-4", "-3")),
    place_id = 1L
  )

  compact <- keep_names(
    input,
    return_addresses = TRUE,
    full_results = FALSE,
    colstokeep = c("query", "lat", "lon")
  )
  expect_named(compact, c("query", "lat", "lon", "address"))
  expect_identical(compact$address, "Madrid, Spain")

  full <- keep_names(
    input,
    return_addresses = FALSE,
    full_results = TRUE,
    colstokeep = c("query", "lat", "lon")
  )
  expect_contains(names(full), c("address", "boundingbox", "place_id"))
  expect_identical(full$boundingbox[[1]], c(40, 41, -4, -3))
})

test_that("keep_names_rev() controls reverse-geocoding output fields", {
  input <- dplyr::tibble(
    display_name = "Madrid, Spain",
    lat = 40.4,
    lon = -3.7,
    place_id = 1L
  )

  compact <- keep_names_rev(input, address = "place")
  expect_named(compact, "place")
  expect_identical(compact$place, "Madrid, Spain")

  coordinates <- keep_names_rev(input, return_coords = TRUE)
  expect_named(coordinates, c("address", "lat", "lon"))

  full <- keep_names_rev(input, full_results = TRUE)
  expect_contains(names(full), c("address", "lat", "lon", "place_id"))
})

test_that("empty output helpers preserve schemas and spatial metadata", {
  query <- dplyr::tibble(query = "missing")

  tabular <- empty_tbl(query, lat = "latitude", lon = "longitude")
  expect_named(tabular, c("query", "latitude", "longitude"))
  expect_type(tabular$latitude, "double")
  expect_type(tabular$longitude, "double")
  expect_all_true(is.na(tabular$latitude))
  expect_all_true(is.na(tabular$longitude))

  reverse <- empty_tbl_rev(dplyr::tibble(lat = 1, lon = 2), "place")
  expect_named(reverse, c("place", "lat", "lon"))
  expect_type(reverse$place, "character")
  expect_all_true(is.na(reverse$place))

  spatial <- empty_sf(query)
  expect_s3_class(spatial, "sf")
  expect_all_true(sf::st_is_empty(spatial))
  expect_identical(sf::st_crs(spatial), sf::st_crs(4326))
})

test_that("unnest_reverse() expands nested API fields", {
  input <- list(
    place_id = 1L,
    display_name = "Madrid, Spain",
    address = list(city = "Madrid", country = "Spain"),
    extratags = list(wikidata = "Q2807"),
    boundingbox = c("40", "41", "-4", "-3"),
    unused = NULL
  )

  out <- unnest_reverse(input)

  expect_s3_class(out, "tbl")
  expect_contains(
    names(out),
    c(
      "place_id",
      "display_name",
      "address.city",
      "address.country",
      "extratags.wikidata",
      "boundingbox"
    )
  )
  expect_no_match(names(out), "unused", fixed = TRUE)
  expect_identical(out$boundingbox[[1]], c(40, 41, -4, -3))
})

test_that("sf unnest helpers expand nested fields and remove missing columns", {
  input <- sf::st_as_sf(
    dplyr::tibble(
      address = '{"city":"Madrid","country":"Spain"}',
      extratags = '{"wikidata":"Q2807"}',
      missing = NA_character_,
      lon = -3.7,
      lat = 40.4
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )

  search <- unnest_sf(input)
  expect_s3_class(search, "sf")
  expect_contains(
    names(search),
    c("address.city", "address.country", "extratags.wikidata")
  )

  reverse <- unnest_sf_reverse(input)
  expect_s3_class(reverse, "sf")
  expect_contains(
    names(reverse),
    c("address.city", "address.country", "extratags.wikidata")
  )
  expect_no_match(names(reverse), "missing", fixed = TRUE)
})
