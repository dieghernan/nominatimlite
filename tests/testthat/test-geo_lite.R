test_that("Returning empty query", {
  skip_on_cran()
  skip_if_api_server()

  expect_message(
    obj <- geo_lite("xbzbzbzoa aiaia"),
    "No results for"
  )

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
    obj_renamed <- geo_lite("xbzbzbzoa aiaia",
      lat = "lata",
      long = "longa"
    ),
    "No results for"
  )

  expect_identical(names(obj_renamed), c("query", "lata", "longa"))

  names(obj_renamed) <- names(obj)

  expect_identical(obj, obj_renamed)
})

test_that("Data format", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  obj <- geo_lite("Madrid")

  expect_s3_class(obj, "tbl")
  expect_false(inherits(geo_lite("Madrid"), "sf"))
  # this is _not_ a _sf function
})


test_that("Checking query", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()


  expect_message(
    obj <- geo_lite(c("Madrid", "Barcelona"),
      limit = 51
    ), "50 results"
  )


  expect_identical(names(obj), c("query", "lat", "lon", "address"))


  obj <- geo_lite("Madrid",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = FALSE
  )
  expect_identical(names(obj), c("query", "at", "ong"))

  obj <- geo_lite("Madrid",
    long = "ong", lat = "at",
    full_results = FALSE,
    return_addresses = TRUE
  )

  expect_identical(names(obj), c("query", "at", "ong", "address"))

  obj <- geo_lite("Madrid",
    long = "ong", lat = "at",
    full_results = TRUE,
    return_addresses = FALSE
  )

  expect_identical(names(obj)[1:4], c("query", "at", "ong", "address"))
  expect_gt(ncol(obj), 4)


  expect_gt(
    nrow(geo_lite("Catedral",
      limit = 10,
      custom_query = list(countrycode = "ES")
    )), 4
  )

  expect_equal(
    nrow(geo_lite("Madrid",
      custom_query = list(countrycode = "es")
    )), 1
  )

  expect_equal(
    nrow(geo_lite("Madrid",
      custom_query = list(extratags = TRUE)
    )), 1
  )
})

test_that("Dedupe", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # Dupes
  expect_silent(
    dup <- geo_lite(rep(c("Pentagon", "Barcelona"), 50),
      limit = 1,
      progressbar = FALSE,
      verbose = FALSE
    )
  )

  expect_equal(nrow(dup), 100)
  expect_equal(as.character(dup$query), rep(c("Pentagon", "Barcelona"), 50))

  # Check deduping
  dedup <- dplyr::distinct(dup)

  expect_equal(nrow(dedup), 2)
  expect_equal(as.character(dedup$query), rep(c("Pentagon", "Barcelona"), 1))
})


test_that("Progress bar", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()
  # No pbar
  expect_silent(geo_lite("Madrid"))
  expect_silent(geo_lite("Madrid", progressbar = TRUE))

  # Get a pbar
  expect_output(aa <- geo_lite(c("Madrid", "Barcelona")))

  # Not
  expect_silent(aa <- geo_lite(c("Madrid", "Barcelona"), progressbar = FALSE))
})
test_that("Fail", {
  skip_on_cran()
  skip_if_api_server()
  skip_if_offline()

  # KO
  expect_snapshot(several <- geo_lite(
    "Madrid",
    full_results = TRUE,
    nominatim_server = "https://xyz.com/"
  ))

  expect_true(all(is.na(several[, 2:3])))
})
