## code to prepare `osm_amenities` dataset goes here

library(readr)

osm_amenities <- readr::read_csv("./data-raw/amenities.csv")


usethis::use_data(osm_amenities, overwrite = TRUE)
