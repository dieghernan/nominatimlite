# Reverse geocoding API in [sf](https://CRAN.R-project.org/package=sf) format

Generates an address from a latitude and longitude. Latitudes must be
between \\\left\[-90, 90 \right\]\\ and longitudes between
\\\left\[-180, 180 \right\]\\. This function returns the spatial object
associated with the query using
[sf](https://CRAN.R-project.org/package=sf), see
[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite.md)
for retrieving the data in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

## Usage

``` r
reverse_geo_lite_sf(
  lat,
  long,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  points_only = TRUE
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

- points_only:

  Logical `TRUE/FALSE`. Whether to return only spatial points (`TRUE`,
  which is the default) or potentially other shapes as provided by the
  Nominatim API (`FALSE`). See **About Geometry Types**.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results.

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

## About Geometry Types

The parameter `points_only` specifies whether the function results will
be points (all Nominatim results are guaranteed to have at least point
geometry) or possibly other spatial objects.

Note that the type of geometry returned in case of `points_only = FALSE`
will depend on the object being geocoded:

- Administrative areas, major buildings and the like will be returned as
  polygons.

- Rivers, roads and their like as lines.

- Amenities may be points even in case of a `points_only = FALSE` call.

The function is vectorized, allowing for multiple addresses to be
geocoded; in case of `points_only = FALSE` multiple geometry types may
be returned.

## See also

[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite.md).

Reverse geocoding coordinates:
[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite.md)

Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) objects:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
library(ggplot2)

# Coliseum coords
col_lon <- 12.49309
col_lat <- 41.89026

# Coliseum as polygon
col_sf <- reverse_geo_lite_sf(
  lat = col_lat,
  lon = col_lon,
  points_only = FALSE
)

dplyr::glimpse(col_sf)
#> Rows: 1
#> Columns: 4
#> $ address  <chr> "Piazza del Colosseo, Celio, Municipio Roma I, Roma, Roma Cap…
#> $ lat      <dbl> 41.89026
#> $ lon      <dbl> 12.49309
#> $ geometry <POLYGON [°]> POLYGON ((12.49095 41.88984...

if (any(!sf::st_is_empty(col_sf))) {
  ggplot(col_sf) +
    geom_sf()
}


# City of Rome - same coords with zoom 10

rome_sf <- reverse_geo_lite_sf(
  lat = col_lat,
  lon = col_lon,
  custom_query = list(zoom = 10),
  points_only = FALSE
)

dplyr::glimpse(rome_sf)
#> Rows: 1
#> Columns: 4
#> $ address  <chr> "Roma, Roma Capitale, Lazio, Italia"
#> $ lat      <dbl> 41.89026
#> $ lon      <dbl> 12.49309
#> $ geometry <MULTIPOLYGON [°]> MULTIPOLYGON (((12.23447 41...

if (any(!sf::st_is_empty(rome_sf))) {
  ggplot(rome_sf) +
    geom_sf()
}

# }
```
