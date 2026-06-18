# Address search API with [sf](https://CRAN.R-project.org/package=sf) output (structured query)

Searches for addresses already split into components and returns
matching results as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object. Use
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)
to return a [tibble](https://tibble.tidyverse.org/reference/tibble.html)
instead.

This function performs the **structured address search** described in
the [API
endpoint](https://nominatim.org/release-docs/latest/api/Search/). To
perform a free-form search, use
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md).

## Usage

``` r
geo_lite_struct_sf(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
)
```

## Arguments

- amenity:

  A string giving the name or type of amenity. See
  [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md).

- street:

  A string giving the house number and street name.

- city:

  A string giving the city.

- county:

  A string giving the county.

- state:

  A string giving the state.

- country:

  A string giving the country.

- postalcode:

  A string giving the postal code.

- limit:

  A positive integer giving the maximum number of results to return per
  query. Nominatim returns at most 50 results per query.

- full_results:

  If `TRUE`, return all available fields from the Nominatim API. If
  `FALSE`, return only query metadata, geometry and requested address
  columns.

- return_addresses:

  If `TRUE`, include single-line addresses in the results.

- verbose:

  If `TRUE`, displays detailed messages in the console.

- nominatim_server:

  A string giving the base URL of the Nominatim server. Defaults to
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

A structured address search accepts an address already split into
components. Each argument represents an address field. All components
are optional, so provide only those relevant to the address you want to
find.

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## About geometry types

The `points_only` argument controls whether the results contain only
points. All Nominatim results have at least a point geometry.

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
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)

Spatial output functions:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Structured address search

pl_mayor <- geo_lite_struct_sf(
  street = "Plaza Mayor",
  county = "Comunidad de Madrid",
  country = "Spain", limit = 50,
  full_results = TRUE, verbose = TRUE
)

# Administrative boundary
ccaa <- geo_lite_sf("Comunidad de Madrid, Spain", points_only = FALSE)

library(ggplot2)

if (any(!sf::st_is_empty(pl_mayor), !sf::st_is_empty(ccaa))) {
  ggplot(ccaa) +
    geom_sf() +
    geom_sf(data = pl_mayor, aes(shape = addresstype, color = addresstype))
}

# }
```
