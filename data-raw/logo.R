## code to prepare `logo` dataset goes here

rm(list = ls())

library(nominatimlite)
library(mapSpain)
library(dplyr)
library(sf)
library(ggplot2)
library(hexSticker)

mad <- esp_get_munic(munic = "^Madrid$", epsg = 4326)

set.seed(1234)
r <- st_sample(mad, 200)
r

map <- ggplot(mad) +
  geom_sf(fill = "#2c3e50", col = "white") +
  geom_sf(data = r, col = "white", size = 0.05) +
  theme_void()



library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Lato", "lato")
## Automatically use showtext to render text for future devices
showtext_auto()

sticker(map,
  s_width = 1.5,
  s_height = 1.5,
  s_x = 0.85,
  s_y = 1,
  p_family = "lato",
  filename = "man/figures/logo.png",
  h_fill = "#2c3e50",
  h_color = "#2c3e50",
  package = "nominatimlite",
  p_x = 1.42,
  p_y = 1.3,
  p_size = 10
)
