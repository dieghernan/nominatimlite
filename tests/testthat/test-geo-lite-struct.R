test_that("geo_lite_struct() handles missing and unmatched components", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-empty.json")
  })

  expect_snapshot(obj <- geo_lite_struct())

  expect_snapshot(obj <- geo_lite_struct(amenity = "xbzbzbzoa aiaia"))

  expect_equal(nrow(obj), 1)
  expect_identical(obj$q_amenity, "xbzbzbzoa aiaia")
  expect_s3_class(obj, "tbl")
  expect_named(
    obj,
    c(
      "q_amenity",
      "q_street",
      "q_city",
      "q_county",
      "q_state",
      "q_country",
      "q_postalcode",
      "lat",
      "lon"
    )
  )

  expect_equal(obj$lat, NA_real_)
  expect_equal(obj$lon, NA_real_)

  expect_snapshot(
    obj_renamed <- geo_lite_struct(
      "xbzbzbzoa aiaia",
      lat = "lata",
      long = "longa"
    )
  )

  expect_named(
    obj_renamed,
    c(
      "q_amenity",
      "q_street",
      "q_city",
      "q_county",
      "q_state",
      "q_country",
      "q_postalcode",
      "lata",
      "longa"
    )
  )

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("geo_lite_struct() returns a non-spatial tibble", {
  skip_nominatim_ci()

  obj <- geo_lite_struct(city = "Madrid")

  expect_s3_class(obj, "tbl")
  expect_false(inherits(obj, "sf"))
  # this is _not_ a _sf function
})

test_that("geo_lite_struct() parses a successful JSON response", {
  local_mocked_bindings(api_call = function(...) {
    test_fixture("search-one.json")
  })

  obj <- geo_lite_struct(city = "Madrid", full_results = TRUE)

  expect_s3_class(obj, "tbl")
  expect_equal(nrow(obj), 1)
  expect_identical(obj$q_city, "Madrid")
  expect_equal(obj$lat, 40.4168)
  expect_equal(obj$lon, -3.7038)
  expect_contains(names(obj), c("address", "boundingbox"))
  expect_type(obj$boundingbox, "list")
})


test_that("geo_lite_struct() caps limits and controls output columns", {
  skip_nominatim_ci()

  expect_message(
    obj <- geo_lite_struct(city = c("Madrid", "Barcelona"), limit = 51),
    "at most 50"
  )

  expect_identical(rev(names(obj))[1:3], rev(c("lat", "lon", "address")))

  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(rev(names(obj))[1:2], rev(c("at", "ong")))

  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong",
    lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(rev(names(obj))[1:3], rev(c("at", "ong", "address")))

  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong",
    lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_gt(ncol(obj), 10)
})

test_that("geo_lite_struct() forwards custom query options", {
  skip_nominatim_ci()

  expect_gt(nrow(geo_lite_struct("Catedral", country = "ES", limit = 10)), 4)

  expect_equal(
    nrow(geo_lite_struct("Madrid", custom_query = list(countrycode = "es"))),
    1
  )

  expect_equal(
    nrow(geo_lite_struct("Madrid", custom_query = list(extratags = TRUE))),
    1
  )
})
test_that("geo_lite_struct() returns a typed row when the API is unavailable", {
  local_mocked_bindings(api_call = function(...) FALSE)

  expect_snapshot(several <- geo_lite_struct("Madrid", full_results = TRUE))

  expect_equal(
    several[, c("lat", "lon")],
    dplyr::tibble(
      lat = rep(NA_real_, nrow(several)),
      lon = rep(NA_real_, nrow(several))
    )
  )
})
