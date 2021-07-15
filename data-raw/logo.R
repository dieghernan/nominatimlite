## code to prepare `logo` dataset goes here

rm(list = ls())

library(nominatimlite)
library(mapSpain)
library(dplyr)
library(sf)
library(ggplot2)
library(hexSticker)

mad <- esp_get_munic(munic = "^Madrid$") %>% st_transform(3857)
mad2 <- st_buffer(mad, -2000)


set.seed(1234)
r <- st_sample(mad2, 200)
r
max(st_coordinates(r)[2, ])
max(st_coordinates(r))

st_bbox(mad)

## Section----



df1 <- data.frame(
  label = "nominatim",
  lon = -3.544387,
  lat = 40.55039
)

p1 <- st_as_sf(df1, coords = c("lon", "lat"), crs = 4326) %>% st_transform(3857)

df2 <- data.frame(
  label = "lite",
  lon = -3.405387,
  lat = 40.55039
)

p2 <- st_as_sf(df2, coords = c("lon", "lat"), crs = 4326) %>% st_transform(3857)

library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Lato", "lato")

font_add_google(
  name = "Pacifico", # Nombre de la fuente en el sitio Google Fonts
  family = "pacifico"
) # Nombre con el que quieres llamar a la fuente
## Automatically use showtext to render text for future devices
showtext_auto()

map <- ggplot(mad) +
  geom_sf(fill = "#2c3e50", col = "white") +
  geom_sf(data = r, col = "#f39c12", size = 0.05) +
  geom_sf_text(data = p1, aes(label = label), size = 10.5, col = "white", family = "lato") +
  geom_sf_text(data = p2, aes(label = label), size = 10.5, col = "#f39c12", family = "lato") +
  theme_void() +
  coord_sf(xlim = c(-432731.6, -375817))






sticker(map,
  s_width = 1.7,
  s_height = 1.5,
  s_x = 1,
  s_y = 1,
  p_family = "lato",
  filename = "man/figures/logo.png",
  h_fill = "#2c3e50",
  h_color = "#2c3e50",
  package = "",
  p_x = 1.42,
  p_y = 1.3,
  p_size = 10
)
