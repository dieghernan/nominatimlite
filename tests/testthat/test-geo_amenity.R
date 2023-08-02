test_that("Returning not reachable", {
  expect_message(geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ), "not reachable")

  skip_on_cran()
  skip_if_api_server()

  expect_message(obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    amenity = "xbzbzbzoa aiaia"
  ))

  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "xbzbzbzoa aiaia")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "lat", "lon"))
  expect_true(all(
    vapply(obj, class, FUN.VALUE = character(1))
    == c("character", rep("numeric", 2))
  ))
  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))

  expect_message(
    obj_renamed <- geo_amenity(
      bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
      amenity = "xbzbzbzoa aiaia",
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
    obj <- geo_amenity(
      bbox = c(-88.1446, 41.5022, -87.4854, 41.8795),
      amenity = "grit_bin"
    ),
    "No results"
  )


  expect_true(nrow(obj) == 1)
  expect_true(obj$query == "grit_bin")
  expect_s3_class(obj, "tbl")
  expect_identical(names(obj), c("query", "lat", "lon"))
  expect_true(all(
    vapply(obj, class, FUN.VALUE = character(1))
    == c("character", rep("numeric", 2))
  ))
  expect_true(is.na(obj$lat))
  expect_true(is.na(obj$lon))

  expect_message(
    obj_renamed <- geo_amenity(
      bbox = c(-88.1446, 41.5022, -87.4854, 41.8795),
      amenity = "grit_bin",
      lat = "lata",
      long = "longa"
    ),
    "No results"
  )

  expect_identical(names(obj_renamed), c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})


test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    c("pub", "restaurant"),
  )

  expect_s3_class(obj, "tbl")
  expect_false(inherits(obj, "sf"))
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


  expect_identical(names(obj), c("query", "lat", "lon", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(names(obj), c("query", "at", "ong"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(names(obj), c("query", "at", "ong", "address"))

  obj <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    "pub",
    long = "ong", lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
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
})

test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes
  dup <- geo_amenity(
    bbox = c(-1.1446, 41.5022, -0.4854, 41.8795),
    rep(c("pub", "restaurant"), 50),
    limit = 1
  )

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("pub", "restaurant"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("pub", "restaurant"), 1))
})
