test_that("Check add_custom_query", {
  u <- "http://test"
  t <- add_custom_query(custom_query = list(), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(1, b = 2), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(a = 1, 2), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(3), url = u)
  expect_identical(u, t)

  # Check
  t <- add_custom_query(custom_query = list(a = 3, b = 3), url = u)
  expect_identical("http://test&a=3&b=3", t)
})

test_that("prepare_api_url", {
  t <- prepare_api_url(entry = "an_entry")
  expect_identical(t, "https://nominatim.openstreetmap.org/an_entry")

  # Add trailing slash
  t2 <- prepare_api_url("https://nominatim.openstreetmap.org", "an_entry")
  expect_identical(t, t2)

  # Custom server
  t3 <- prepare_api_url("http://localhost:2322/nominatim-update", "custom")
  expect_identical(t3, "http://localhost:2322/nominatim-update/custom")
})

test_that("sf to tibble", {
  normal_sf <- sf::st_as_sf(
    data.frame(x = 1, lon = 0, lat = 0),
    coords = c("lat", "lon"),
    crs = 4326
  )
  expect_s3_class(normal_sf, c("sf", "data.frame"), exact = TRUE)

  tbl_sf <- sf_to_tbl(normal_sf)
  expect_s3_class(tbl_sf, c("sf", "tbl_df"))
})

test_that("is_named() covers all branches", {
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
