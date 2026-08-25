test_that("osm_amenities has the documented tabular schema", {
  expect_s3_class(osm_amenities, c("tbl_df", "data.frame"))
  expect_named(osm_amenities, c("category", "amenity", "comment"))
  expect_type(osm_amenities$category, "character")
  expect_type(osm_amenities$amenity, "character")
  expect_type(osm_amenities$comment, "character")
})

test_that("osm_amenities contains non-missing unique amenity keys", {
  expect_gt(nrow(osm_amenities), 0)
  expect_false(anyNA(osm_amenities$category))
  expect_false(anyNA(osm_amenities$amenity))
  expect_identical(anyDuplicated(osm_amenities$amenity), 0L)
  expect_no_match(osm_amenities$category, "^\\s*$")
  expect_no_match(osm_amenities$amenity, "^\\s*$")
})
