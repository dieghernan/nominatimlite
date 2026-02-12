# nominatimlite and leaflet maps

## Example

The following example shows how it is possible to create a nice [leaflet
map](https://rstudio.github.io/leaflet/) with data retrieved with
**nominatimlite**.

This widget is browsable and filterable thanks to **crosstalk** and
**reactable**:

``` r
# Coffee Shops and Restaurants around the Eiffel Tower


library(nominatimlite)
library(sf)
library(leaflet)
library(dplyr)
library(tidyr)
library(reactable)
library(crosstalk)


# Step 1: Eiffel Tower
eiffel_tower <- geo_lite_sf("Eiffel Tower, Paris, France", points_only = FALSE)


# Step 2: Coffee Shops and Restaurants nearby

# Create a buffer of 1km around the Eiffel Tower
buff <- eiffel_tower %>%
  st_transform(3857) %>%
  st_centroid() %>%
  st_buffer(1000)

cf_bk <- geo_amenity_sf(buff,
  amenity = c("cafe", "restaurant"), limit = 50,
  full_results = TRUE,
  custom_query = list(extratags = TRUE)
) %>%
  # Build address with street, house number, suburb and postcode
  unite("addr", address.road, address.house_number, address.postcode,
    address.suburb,
    sep = ", ", na.rm = TRUE
  )
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%


# Labels and icons
labs <- paste0("<strong>", cf_bk$name, "</strong><br>", cf_bk$addr)

# Assign icons
# Base url for icons
icon_url <- paste0(
  "https://raw.githubusercontent.com/dieghernan/arcgeocoder/",
  "main/vignettes/articles/"
)

leaf_icons <- icons(
  ifelse(cf_bk$type == "cafe",
    paste0(icon_url, "coffee-cup.png"),
    paste0(icon_url, "restaurant.png")
  ),
  iconWidth = 20, iconHeight = 20,
  iconAnchorX = 10, iconAnchorY = 10
)


# Step 3: Crosstalk object
cf_bk_data <- cf_bk %>%
  select(
    Place = name, Type = type, Address = addr,
    City = address.city, URL = extratags.website,
    Phone = extratags.phone
  ) %>%
  SharedData$new(group = "Food")


# Step 4: Leaflet map with crosstalk
# Init leaflet map
lmend <- leaflet(
  data = cf_bk_data,
  elementId = "EiffelTower", width = "100%", height = "60vh",
  options = leafletOptions(minZoom = 12)
) %>%
  addProviderTiles(
    provider = "CartoDB.Positron",
    group = "CartoDB.Positron"
  ) %>%
  addTiles(group = "OSM") %>%
  addPolygons(data = eiffel_tower) %>%
  addMarkers(popup = labs, icon = leaf_icons) %>%
  addLayersControl(
    baseGroups = c("CartoDB.Positron", "OSM"),
    position = "topleft",
    options = layersControlOptions(collapsed = FALSE)
  )


# Step 5: Reactable for filtering
tb <- reactable(cf_bk_data,
  selection = "multiple",
  onClick = "select",
  rowStyle = list(cursor = "pointer"),
  filterable = TRUE,
  searchable = TRUE,
  showPageSizeOptions = TRUE,
  striped = TRUE,
  defaultColDef = colDef(vAlign = "center", minWidth = 150),
  paginationType = "jump",
  elementId = "coffees",
  columns = list(
    Place = colDef(
      sticky = "left", rowHeader = TRUE, name = "",
      cell = function(value) {
        htmltools::strong(value)
      }
    ),
    URL = colDef(cell = function(value) {
      # Render as a link
      if (is.null(value) | is.na(value)) {
        return("")
      }
      htmltools::a(href = value, target = "_blank", as.character(value))
    }),
    Phone = colDef(cell = function(value) {
      # Render as a link
      if (is.null(value) | is.na(value)) {
        return("")
      }
      clearphone <- gsub("-", "", value)
      clearphone <- gsub(" ", "", clearphone)
      htmltools::a(
        href = paste0("tel:", clearphone), target = "_blank",
        as.character(value)
      )
    })
  )
)
```

## Widget

``` r
# Last step: Display all
htmltools::browsable(
  htmltools::tagList(lmend, tb)
)
```

## Attributions

- [Eiffel tower icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/eiffel-tower "eiffel tower icons")
- [Mug icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/mug "mug icons")
- [Food icons created by Freepik -
  Flaticon](https://www.flaticon.com/free-icons/food "restaurant icons")

## Session info

Details

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.5.2 (2025-10-31 ucrt)
    #>  os       Windows Server 2022 x64 (build 26100)
    #>  system   x86_64, mingw32
    #>  ui       RTerm
    #>  language en
    #>  collate  English_United States.utf8
    #>  ctype    English_United States.utf8
    #>  tz       UTC
    #>  date     2026-02-12
    #>  pandoc   3.1.11 @ C:/HOSTED~1/windows/pandoc/31F387~1.11/x64/PANDOC~1.11/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package           * version date (UTC) lib source
    #>  bslib               0.10.0  2026-01-26 [1] RSPM
    #>  cachem              1.1.0   2024-05-16 [1] RSPM
    #>  class               7.3-23  2025-01-01 [3] CRAN (R 4.5.2)
    #>  classInt            0.4-11  2025-01-08 [1] RSPM
    #>  cli                 3.6.5   2025-04-23 [1] RSPM
    #>  crosstalk         * 1.2.2   2025-08-26 [1] RSPM
    #>  DBI                 1.2.3   2024-06-02 [1] RSPM
    #>  desc                1.4.3   2023-12-10 [1] RSPM
    #>  digest              0.6.39  2025-11-19 [1] RSPM
    #>  dplyr             * 1.2.0   2026-02-03 [1] RSPM
    #>  e1071               1.7-17  2025-12-18 [1] RSPM
    #>  evaluate            1.0.5   2025-08-27 [1] RSPM
    #>  fastmap             1.2.0   2024-05-15 [1] RSPM
    #>  fs                  1.6.6   2025-04-12 [1] RSPM
    #>  generics            0.1.4   2025-05-09 [1] RSPM
    #>  glue                1.8.0   2024-09-30 [1] RSPM
    #>  htmltools           0.5.9   2025-12-04 [1] RSPM
    #>  htmlwidgets         1.6.4   2023-12-06 [1] RSPM
    #>  httpuv              1.6.16  2025-04-16 [1] RSPM
    #>  jquerylib           0.1.4   2021-04-26 [1] RSPM
    #>  jsonlite            2.0.0   2025-03-27 [1] RSPM
    #>  KernSmooth          2.23-26 2025-01-01 [3] CRAN (R 4.5.2)
    #>  knitr               1.51    2025-12-20 [1] RSPM
    #>  later               1.4.5   2026-01-08 [1] RSPM
    #>  leaflet           * 2.2.3   2025-09-04 [1] RSPM
    #>  leaflet.providers   2.0.0   2023-10-17 [1] RSPM
    #>  lifecycle           1.0.5   2026-01-08 [1] RSPM
    #>  magrittr            2.0.4   2025-09-12 [1] RSPM
    #>  mime                0.13    2025-03-17 [1] RSPM
    #>  nominatimlite     * 0.4.3   2026-02-12 [1] local
    #>  otel                0.2.0   2025-08-29 [1] RSPM
    #>  pillar              1.11.1  2025-09-17 [1] RSPM
    #>  pkgconfig           2.0.3   2019-09-22 [1] RSPM
    #>  pkgdown             2.2.0   2025-11-06 [1] any (@2.2.0)
    #>  promises            1.5.0   2025-11-01 [1] RSPM
    #>  proxy               0.4-29  2025-12-29 [1] RSPM
    #>  purrr               1.2.1   2026-01-09 [1] RSPM
    #>  R.cache             0.17.0  2025-05-02 [1] RSPM
    #>  R.methodsS3         1.8.2   2022-06-13 [1] RSPM
    #>  R.oo                1.27.1  2025-05-02 [1] RSPM
    #>  R.utils             2.13.0  2025-02-24 [1] RSPM
    #>  R6                  2.6.1   2025-02-15 [1] RSPM
    #>  ragg                1.5.0   2025-09-02 [1] RSPM
    #>  Rcpp                1.1.1   2026-01-10 [1] RSPM
    #>  reactable         * 0.4.5   2025-12-01 [1] RSPM
    #>  reactR              0.6.1   2024-09-14 [1] RSPM
    #>  rlang               1.1.7   2026-01-09 [1] RSPM
    #>  rmarkdown           2.30    2025-09-28 [1] RSPM
    #>  s2                  1.1.9   2025-05-23 [1] RSPM
    #>  sass                0.4.10  2025-04-11 [1] RSPM
    #>  sessioninfo       * 1.2.3   2025-02-05 [1] any (@1.2.3)
    #>  sf                * 1.0-24  2026-01-13 [1] RSPM
    #>  shiny               1.12.1  2025-12-09 [1] RSPM
    #>  styler              1.11.0  2025-10-13 [1] RSPM
    #>  systemfonts         1.3.1   2025-10-01 [1] RSPM
    #>  textshaping         1.0.4   2025-10-10 [1] RSPM
    #>  tibble              3.3.1   2026-01-11 [1] RSPM
    #>  tidyr             * 1.3.2   2025-12-19 [1] RSPM
    #>  tidyselect          1.2.1   2024-03-11 [1] RSPM
    #>  units               1.0-0   2025-10-09 [1] RSPM
    #>  vctrs               0.7.1   2026-01-23 [1] RSPM
    #>  withr               3.0.2   2024-10-28 [1] RSPM
    #>  wk                  0.9.5   2025-12-18 [1] RSPM
    #>  xfun                0.56    2026-01-18 [1] RSPM
    #>  xtable              1.8-4   2019-04-21 [1] RSPM
    #>  yaml                2.3.12  2025-12-10 [1] RSPM
    #> 
    #>  [1] D:/a/_temp/Library
    #>  [2] C:/R/site-library
    #>  [3] C:/R/library
    #>  * ── Packages attached to the search path.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
