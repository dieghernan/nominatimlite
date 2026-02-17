# Reverse geocoding API

Generates an address from a latitude and longitude. Latitudes must be
between \\\left\[-90, 90 \right\]\\ and longitudes between
\\\left\[-180, 180 \right\]\\. This function returns the
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
associated with the query, see
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)
for retrieving the data as a spatial object
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) format).

## Usage

``` r
reverse_geo_lite(
  lat,
  long,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list()
)
```

## Arguments

- lat:

  Latitude values in numeric format. Must be in the range \\\left\[-90,
  90 \right\]\\.

- long:

  Longitude values in numeric format. Must be in the range
  \\\left\[-180, 180 \right\]\\.

- address:

  Address column name in the output data (default `"address"`).

- full_results:

  Returns all available data from the API service. If `FALSE` (default)
  only latitude, longitude and address columns are returned. See also
  `return_addresses`.

- return_coords:

  Return input coordinates with results if `TRUE`.

- verbose:

  If `TRUE` then detailed logs are output to the console.

- nominatim_server:

  The URL of the Nominatim server to use. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

- progressbar:

  Logical. If `TRUE` displays a progress bar to indicate the progress of
  the function.

- custom_query:

  API-specific parameters to be used, passed as a named list (ie.
  `list(zoom = 3)`). See **Details**.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results found by the query.

## Details

See <https://nominatim.org/release-docs/develop/api/Reverse/> for
additional parameters to be passed to `custom_query`.

## About Zooming

Use the option `custom_query = list(zoom = 3)` to adjust the output.
Some equivalences on terms of zoom:

|          |                         |
|----------|-------------------------|
| **zoom** | **address_detail**      |
| `3`      | country                 |
| `5`      | state                   |
| `8`      | county                  |
| `10`     | city                    |
| `14`     | suburb                  |
| `16`     | major streets           |
| `17`     | major and minor streets |
| `18`     | building                |

## See also

[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md),
[`tidygeocoder::reverse_geo()`](https://jessecambon.github.io/tidygeocoder/reference/reverse_geo.html).

Reverse geocoding coordinates:
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{

reverse_geo_lite(lat = 40.75728, long = -73.98586)
#> # A tibble: 1 × 3
#>   address                                                              lat   lon
#>   <chr>                                                              <dbl> <dbl>
#> 1 Times Square, Manhattan Community Board 5, Manhattan, New York Co…  40.8 -74.0

# Several coordinates
reverse_geo_lite(lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375))
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 3
#>   address                                                             lat    lon
#>   <chr>                                                             <dbl>  <dbl>
#> 1 Times Square, Manhattan Community Board 5, Manhattan, New York C…  40.8 -74.0 
#> 2 East End, Waterloo Place, Waterloo Place, Broughton, New Town/Br…  56.0  -3.19

# With options: zoom to country level
sev <- reverse_geo_lite(
  lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375),
  custom_query = list(zoom = 0, extratags = TRUE),
  verbose = TRUE, full_results = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%

dplyr::glimpse(sev)
#> Rows: 2
#> Columns: 51
#> $ address                                  <chr> "United States", "United King…
#> $ lat                                      <dbl> 39.78373, 54.70235
#> $ lon                                      <dbl> -100.445882, -3.276575
#> $ place_id                                 <int> 45852144, 255148843
#> $ licence                                  <chr> "Data © OpenStreetMap contrib…
#> $ osm_type                                 <chr> "relation", "relation"
#> $ osm_id                                   <int> 148838, 62149
#> $ category                                 <chr> "boundary", "boundary"
#> $ type                                     <chr> "administrative", "administra…
#> $ place_rank                               <int> 4, 4
#> $ importance                               <dbl> 1.0000000, 0.9388534
#> $ addresstype                              <chr> "country", "country"
#> $ name                                     <chr> "United States", "United King…
#> $ display_name                             <chr> "United States", "United King…
#> $ address.country                          <chr> "United States", "United King…
#> $ address.country_code                     <chr> "us", "gb"
#> $ extratags.flag                           <chr> "https://upload.wikimedia.org…
#> $ extratags.sqkm                           <chr> "9826675", "243610"
#> $ extratags.wikidata                       <chr> "Q30", "Q145"
#> $ extratags.wikipedia                      <chr> "en:United States", "en:Unite…
#> $ extratags.check_date                     <chr> "2024-10-17", NA
#> $ extratags.population                     <chr> "331449281", "61792000"
#> $ extratags.border_type                    <chr> "national", NA
#> $ extratags.capital_city                   <chr> "Washington DC", NA
#> $ extratags.driving_side                   <chr> "right", "left"
#> $ extratags.linked_place                   <chr> "country", "country"
#> $ `extratags.contact:website`              <chr> "https://www.usa.gov", NA
#> $ `extratags.population:date`              <chr> "2020", NA
#> $ `extratags.ISO3166-1:alpha2`             <chr> "US", "GB"
#> $ `extratags.ISO3166-1:alpha3`             <chr> "USA", "GBR"
#> $ extratags.default_language               <chr> "en", "en"
#> $ `extratags.ISO3166-1:numeric`            <chr> "840", "826"
#> $ `extratags.alt_short_name:en`            <chr> "US;USA", NA
#> $ `extratags.alt_short_name:es`            <chr> "EUA", NA
#> $ `extratags.alt_short_name:pl`            <chr> "St. Zj.", NA
#> $ extratags.country_code_fips              <chr> "US", NA
#> $ `extratags.old_short_name:ru`            <chr> "САСШ", NA
#> $ extratags.wikimedia_commons              <chr> "Category:United States", "Ca…
#> $ extratags.short_official_name            <chr> "U.S.A.", NA
#> $ `extratags.alt_official_name:en`         <chr> "The United States of America…
#> $ `extratags.not:official_name:vi`         <chr> "Hợp chủng quốc Hoa Kỳ;Hợp ch…
#> $ `extratags.short_official_name:en`       <chr> "U.S.A.", NA
#> $ extratags.country_code_iso3166_1_alpha_2 <chr> "US", NA
#> $ boundingbox                              <list> <-14.76084, 71.58895, -180.00…
#> $ `extratags.ref:gss`                      <chr> NA, "K02000001"
#> $ extratags.currency                       <chr> NA, "GBP"
#> $ extratags.timezone                       <chr> NA, "Europe/London"
#> $ extratags.native_name                    <chr> NA, "United Kingdom of Great …
#> $ `extratags.native_name:da`               <chr> NA, "Det Forenede Kongerige S…
#> $ `extratags.native_name:es`               <chr> NA, "Reino Unido de Gran Bret…
#> $ `extratags.native_name:vi`               <chr> NA, "Vương quốc Liên hiệp Anh…
# }
```
