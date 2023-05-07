test_that("Errors", {
  expect_error(bbox_to_poly())
  expect_error(bbox_to_poly(1))
  expect_error(bbox_to_poly(xmin = 1))
})


test_that("Bbox", {
  expect_silent(bbox_to_poly(c(1, 2, 3, 4)))
  expect_silent(bbox_to_poly(
    xmin = 1,
    xmax = 2,
    ymin = 3,
    ymax = 4
  ))
  expect_true(all(sf::st_bbox(
    bbox_to_poly(
      xmin = 1,
      xmax = 2,
      ymin = 3,
      ymax = 4
    )
  ) == c(1, 3, 2, 4)))
  expect_false(sf::st_crs(bbox_to_poly(c(1, 2, 3, 4))) ==
    sf::st_crs(bbox_to_poly(c(1, 2, 3, 4), crs = 3857)))
})

test_that("Format output", {
  obj <- bbox_to_poly(c(1, 2, 3, 4))
  expect_s3_class(obj, "sfc")
  expect_equal(as.character(sf::st_geometry_type(obj)), "POLYGON")
  expect_identical(sf::st_crs(obj), sf::st_crs(4326))


  obj <- bbox_to_poly(c(1, 2, 3, 4), crs = 3035)
  expect_s3_class(obj, "sfc")
  expect_equal(as.character(sf::st_geometry_type(obj)), "POLYGON")
  expect_identical(sf::st_crs(obj), sf::st_crs(3035))
})
