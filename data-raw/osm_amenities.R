## code to prepare `osm_amenities` dataset goes here

# https://www.r-bloggers.com/2021/07/politely-scraping-wikipedia-tables-2/

# To clean data
library(tidyverse)
# To scrape data
library(rvest)

url <- "https://wiki.openstreetmap.org/wiki/Key:amenity"

osm_amenities <- rvest::read_html(url) %>% # scrape web page
  rvest::html_nodes("table.wikitable") %>% # pull out specific table
  rvest::html_table() %>%
  pluck(1) %>%
  as_tibble(.name_repair = "unique") %>%
  mutate(Element = ifelse(Element == "", NA, Element)) %>%
  fill(Element, .direction = "down") %>%
  select(category = Element, amenity = Value, comment = Comment) %>%
  mutate(
    category = str_trim(category),
    amenity = str_trim(amenity),
    comment = str_trim(comment)
  ) %>%
  filter(category != amenity) %>%
  as_tibble()

usethis::use_data(osm_amenities, overwrite = TRUE)
