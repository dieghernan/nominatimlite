# Address search API with [sf](https://CRAN.R-project.org/package=sf) output (free-form query)

Searches for addresses and returns matching results as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object using
[sf](https://CRAN.R-project.org/package=sf). Use
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
to return a [tibble](https://tibble.tidyverse.org/reference/tibble.html)
instead.

This function performs the **free-form address search** described in the
[API endpoint](https://nominatim.org/release-docs/latest/api/Search/).

## Usage

``` r
geo_lite_sf(
  address,
  limit = 1,
  return_addresses = TRUE,
  full_results = FALSE,
  verbose = FALSE,
  progressbar = TRUE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
)
```

## Arguments

- address:

  A character vector of single-line addresses, for example
  `"1600 Pennsylvania Ave NW, Washington"` or
  `c("Madrid", "Barcelona")`.

- limit:

  Maximum number of results to return per query. Nominatim returns at
  most 50 results per query.

- return_addresses:

  If `TRUE`, include single-line addresses in the results.

- full_results:

  If `TRUE`, return all available fields from the Nominatim API. If
  `FALSE`, return only query metadata, geometry and requested address
  columns.

- verbose:

  If `TRUE`, display detailed messages in the console.

- progressbar:

  If `TRUE`, display a progress bar when processing multiple queries.

- nominatim_server:

  Base URL of the Nominatim server. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

- points_only:

  If `TRUE`, return only point geometries. If `FALSE`, the API may
  return other geometry types. See **About geometry types**.

## Value

An [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results that match the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## About geometry types

The `points_only` argument controls whether results contain points only.
All Nominatim results have at least a point geometry.

When `points_only = FALSE`, the geometry type depends on the matching
feature. Administrative areas and major buildings are returned as
polygons, rivers and roads are returned as lines and amenities may still
be returned as points.

This function is vectorized, allowing multiple addresses to be searched.
With `points_only = FALSE`, multiple geometry types may be returned.

## See also

Address search functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

Spatial output functions:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Point geometries
library(ggplot2)

string <- "Statue of Liberty, NY, USA"
sol <- geo_lite_sf(string)

if (!all(sf::st_is_empty(sol))) {
  ggplot(sol) +
    geom_sf()
}


sol_poly <- geo_lite_sf(string, points_only = FALSE)

if (!all(sf::st_is_empty(sol_poly))) {
  ggplot(sol_poly) +
    geom_sf() +
    geom_sf(data = sol, color = "red")
}

# Multiple matches

madrid <- geo_lite_sf("Comunidad de Madrid, Spain",
  limit = 2,
  points_only = FALSE, full_results = TRUE
)

if (!all(sf::st_is_empty(madrid))) {
  ggplot(madrid) +
    geom_sf(fill = NA)
}

# }
```
