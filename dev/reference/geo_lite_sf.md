# Address search API with [sf](https://CRAN.R-project.org/package=sf) output (free-form query)

Geocodes addresses and returns the corresponding
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object. The
query output is returned as an
[sf](https://CRAN.R-project.org/package=sf) object. See
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md)
for retrieving the data in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

Corresponds to the **free-form query** search described in the [API
endpoint](https://nominatim.org/release-docs/latest/api/Search/).

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

  `character` with a single-line address, for example
  `"1600 Pennsylvania Ave NW, Washington"`, or a vector of addresses
  (`c("Madrid", "Barcelona")`).

- limit:

  Maximum number of results to return per input address. Note that each
  query returns a maximum of 50 results.

- return_addresses:

  Return input addresses with results if `TRUE`.

- full_results:

  Return all available data from the Nominatim API. If `FALSE`
  (default), only address columns are returned. See also
  `return_addresses`.

- verbose:

  If `TRUE`, detailed logs are output to the console.

- progressbar:

  Logical. If `TRUE` displays a progress bar to indicate the progress of
  the function.

- nominatim_server:

  URL of the Nominatim server to use. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

- custom_query:

  Named list with API-specific parameters, for example
  `list(countrycodes = "US")`. See **Details**.

- points_only:

  Logical `TRUE/FALSE`. Whether to return only point geometries (`TRUE`,
  which is the default) or potentially other shapes as returned by the
  Nominatim API (`FALSE`). See **About geometry types**.

## Value

An [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results that match the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## About geometry types

The parameter `points_only` specifies whether the function results will
be points (all Nominatim results are guaranteed to have at least point
geometry) or other geometry types.

Note that when `points_only = FALSE`, the type of geometry returned
depends on the object being geocoded. Administrative areas, major
buildings and the like will be returned as polygons, rivers, roads and
similar features will be returned as lines, and amenities may still be
returned as points.

This function is vectorized, allowing multiple addresses to be geocoded.
With `points_only = FALSE`, multiple geometry types may be returned.

## See also

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

[`sf`](https://r-spatial.github.io/sf/reference/sf.html) outputs:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Map: points
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

# Several results

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
