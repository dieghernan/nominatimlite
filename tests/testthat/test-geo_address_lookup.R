test_that("Returning not reachable", {
  expect_message(geo_address_lookup("xbzbzbzoa aiaia", "R"))

  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- geo_address_lookup("xbzbzbzoa aiaia", "R"),
    "not reachable"
  )

  expect_true(nrow(obj) == 1)

  expect_true(obj$query == "Rxbzbzbzoa aiaia")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "lat", "lon"))
  expect_true(all(vapply(obj, class, FUN.VALUE = character(1))
  == c("character", rep("numeric", 2))))
  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))


  expect_message(
    obj_renamed <- geo_address_lookup("xbzbzbzoa aiaia", "R",
      lat = "lata",
      long = "longa"
    ),
    "not reachable"
  )

  expect_identical(names(obj_renamed), c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})


test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()


  expect_message(
    obj <- geo_address_lookup(34633854, "N"),
    "No results for query"
  )

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "N34633854")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "lat", "lon"))
  expect_true(all(vapply(obj, class, FUN.VALUE = character(1))
  == c("character", rep("numeric", 2))))
  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))


  expect_message(
    obj_renamed <- geo_address_lookup(34633854, "N",
      lat = "lata",
      long = "longa"
    ),
    "No results for query"
  )

  expect_identical(names(obj_renamed), c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  out <- geo_address_lookup(34633854, "W")

  expect_s3_class(out, "tbl")
  expect_false(inherits(out, "sf"))
})

test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_address_lookup(34633854, "W")

  expect_identical(names(obj), c("query", "lat", "lon", "address"))

  obj <- geo_address_lookup(34633854, "W",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )

  expect_identical(names(obj), c("query", "at", "ong"))

  obj <- geo_address_lookup(34633854, "W",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )
  expect_identical(names(obj), c("query", "at", "ong", "address"))


  obj <- geo_address_lookup(34633854, "W",
    long = "ong", lat = "at",
    full_results = TRUE,
    return_addresses = TRUE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)


  expect_equal(nrow(geo_address_lookup(34633854, "W",
    full_results = TRUE,
    custom_query = list(extratags = 1)
  )), 1)

  expect_equal(nrow(geo_address_lookup(34633854, "W",
    custom_query = list(countrycode = "us")
  )), 1)
})


test_that("Handle several", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Ok
  vector_ids <- c(146656, 240109189)
  vector_type <- c("R", "N")
  several <- geo_address_lookup(vector_ids, vector_type)
  expect_equal(nrow(several), 2)
  expect_identical(names(several), c("query", "lat", "lon", "address"))

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids))

  # KO

  vector_ids <- c(146, 240109189)
  vector_type <- c("J", "N")

  expect_warning(
    several <- geo_address_lookup(vector_ids, vector_type, verbose = TRUE),
    "Check the final object"
  )

  expect_equal(nrow(several), 1)
  expect_identical(names(several), c("query", "lat", "lon", "address"))

  expect_identical(as.vector(several$query), paste0(vector_type, vector_ids)[2])
})
