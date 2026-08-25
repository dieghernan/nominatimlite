test_that("geo_lite() completes a live address search", {
  skip_if_nominatim_unavailable()

  out <- geo_lite("Madrid", progressbar = FALSE)

  expect_s3_class(out, "tbl")
  expect_gt(nrow(out), 0)
  expect_contains(names(out), c("query", "lat", "lon", "address"))
  expect_all_true(is.finite(out$lat))
  expect_all_true(is.finite(out$lon))
})

test_that("geo_lite_sf() completes a live spatial address search", {
  skip_if_nominatim_unavailable()

  out <- geo_lite_sf("Madrid", progressbar = FALSE)

  expect_s3_class(out, "sf")
  expect_gt(nrow(out), 0)
  expect_all_false(sf::st_is_empty(out))
  expect_equal(sf::st_crs(out)$epsg, 4326)
})

test_that("geo_lite_struct() completes a live structured search", {
  skip_if_nominatim_unavailable()

  out <- geo_lite_struct(city = "Madrid", country = "Spain")

  expect_s3_class(out, "tbl")
  expect_gt(nrow(out), 0)
  expect_contains(names(out), c("q_city", "q_country", "lat", "lon"))
  expect_all_true(is.finite(out$lat))
  expect_all_true(is.finite(out$lon))
})

test_that("geo_lite_struct_sf() completes a live spatial structured search", {
  skip_if_nominatim_unavailable()

  out <- geo_lite_struct_sf(city = "Madrid", country = "Spain")

  expect_s3_class(out, "sf")
  expect_gt(nrow(out), 0)
  expect_all_false(sf::st_is_empty(out))
  expect_equal(sf::st_crs(out)$epsg, 4326)
})

test_that("geo_address_lookup() completes a live OSM object lookup", {
  skip_if_nominatim_unavailable()

  out <- geo_address_lookup(34633854, "W")

  expect_s3_class(out, "tbl")
  expect_gt(nrow(out), 0)
  expect_contains(names(out), c("query", "lat", "lon", "address"))
  expect_all_true(is.finite(out$lat))
  expect_all_true(is.finite(out$lon))
})

test_that("geo_address_lookup_sf() completes a live spatial OSM lookup", {
  skip_if_nominatim_unavailable()

  out <- geo_address_lookup_sf(34633854, "W")

  expect_s3_class(out, "sf")
  expect_gt(nrow(out), 0)
  expect_all_false(sf::st_is_empty(out))
  expect_equal(sf::st_crs(out)$epsg, 4326)
})

test_that("geo_amenity() completes a live amenity lookup", {
  skip_if_nominatim_unavailable()

  out <- geo_amenity(
    c(-3.71, 40.41, -3.69, 40.43),
    "restaurant",
    limit = 1,
    progressbar = FALSE
  )

  expect_s3_class(out, "tbl")
  expect_gt(nrow(out), 0)
  expect_contains(names(out), c("query", "lat", "lon", "address"))
  expect_all_true(is.finite(out$lat))
  expect_all_true(is.finite(out$lon))
})

test_that("geo_amenity_sf() completes a live spatial amenity lookup", {
  skip_if_nominatim_unavailable()

  out <- geo_amenity_sf(
    c(-3.71, 40.41, -3.69, 40.43),
    "restaurant",
    limit = 1,
    progressbar = FALSE
  )

  expect_s3_class(out, "sf")
  expect_gt(nrow(out), 0)
  expect_all_false(sf::st_is_empty(out))
  expect_equal(sf::st_crs(out)$epsg, 4326)
})

test_that("reverse_geo_lite() completes a live reverse lookup", {
  skip_if_nominatim_unavailable()

  out <- reverse_geo_lite(40.4168, -3.7038, progressbar = FALSE)

  expect_s3_class(out, "tbl")
  expect_gt(nrow(out), 0)
  expect_contains(names(out), c("address", "lat", "lon"))
  expect_all_true(!is.na(out$address))
})

test_that("reverse_geo_lite_sf() completes a live spatial reverse lookup", {
  skip_if_nominatim_unavailable()

  out <- reverse_geo_lite_sf(40.4168, -3.7038, progressbar = FALSE)

  expect_s3_class(out, "sf")
  expect_gt(nrow(out), 0)
  expect_all_false(sf::st_is_empty(out))
  expect_equal(sf::st_crs(out)$epsg, 4326)
})

test_that("nominatim_check_access() confirms the live status endpoint", {
  skip_if_nominatim_unavailable()

  expect_true(nominatim_check_access())
})
