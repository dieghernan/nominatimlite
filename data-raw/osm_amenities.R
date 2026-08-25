## Prepare the `osm_amenities` dataset.

# https://www.r-bloggers.com/2021/07/politely-scraping-wikipedia-tables-2/

# Load packages used to clean the data.
library(tidyverse)
# Load packages used to scrape the data.
library(rvest)

url <- "https://wiki.openstreetmap.org/wiki/Key:amenity"

osm_amenities <- rvest::read_html(url) |> # Scrape the web page.
  rvest::html_nodes("table.wikitable") |> # Extract the relevant table.
  rvest::html_table() |>
  pluck(1) |>
  as_tibble(.name_repair = "unique") |>
  mutate(Element = ifelse(!nzchar(Element), NA, Element)) |>
  fill(Element, .direction = "down") |>
  select(category = Element, amenity = Value, comment = Comment) |>
  mutate(
    category = str_trim(category),
    amenity = str_trim(amenity),
    comment = str_trim(comment)
  ) |>
  filter(category != amenity) |>
  as_tibble()

usethis::use_data(osm_amenities, overwrite = TRUE)
