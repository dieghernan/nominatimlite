test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- geo_lite_struct(),
    "Nothing to search for"
  )

  expect_message(
    obj <- geo_lite_struct(amenity = "xbzbzbzoa aiaia"),
    "No results for"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$q_amenity == "xbzbzbzoa aiaia")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c(
    "q_amenity", "q_street", "q_city", "q_county",
    "q_state", "q_country", "q_postalcode", "lat",
    "lon"
  ))

  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))

  expect_message(
    obj_renamed <- geo_lite_struct("xbzbzbzoa aiaia",
      lat = "lata",
      long = "longa"
    ),
    "No results for"
  )

  expect_identical(
    names(obj_renamed),
    c(
      "q_amenity", "q_street", "q_city", "q_county",
      "q_state", "q_country", "q_postalcode", "lata",
      "longa"
    )
  )

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_lite_struct(city = "Madrid")

  expect_s3_class(obj, "tbl")
  expect_false(inherits(geo_lite("Madrid"), "sf"))
  # this is _not_ a _sf function
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(
    obj <- geo_lite_struct(
      city = c("Madrid", "Barcelona"),
      limit = 51
    ), "50 results"
  )


  expect_identical(
    rev(names(obj))[1:3],
    rev(c("lat", "lon", "address"))
  )


  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(rev(names(obj))[1:2], rev(c("at", "ong")))

  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(rev(names(obj))[1:3], rev(c("at", "ong", "address")))

  obj <- geo_lite_struct(
    city = "Madrid",
    long = "ong", lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_gt(ncol(obj), 10)


  expect_gt(
    nrow(geo_lite_struct("Catedral",
      country = "ES",
      limit = 10
    )), 4
  )

  expect_equal(
    nrow(geo_lite_struct("Madrid",
      custom_query = list(countrycode = "es")
    )), 1
  )

  expect_equal(
    nrow(geo_lite_struct("Madrid",
      custom_query = list(extratags = TRUE)
    )), 1
  )
})
test_that("Fail", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # KO
  expect_snapshot(several <- geo_lite_struct(
    "Madrid",
    full_results = TRUE,
    nominatim_server = "https://xyz.com/"
  ))

  expect_true(all(is.na(several[, c("lat", "lon")])))
})
