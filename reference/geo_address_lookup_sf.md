# Address lookup API with [sf](https://CRAN.R-project.org/package=sf) output

The lookup API queries the address and other details of one or more OSM
objects, such as nodes, ways or relations, and returns the
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object
associated with the query using
[sf](https://CRAN.R-project.org/package=sf). See
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)
for retrieving the data in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

## Usage

``` r
geo_address_lookup_sf(
  osm_ids,
  type = c("N", "W", "R"),
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
)
```

## Arguments

- osm_ids:

  Vector of OSM identifiers as numeric values, for example
  `c(00000, 11111, 22222)`.

- type:

  Character vector of the OSM object type associated with each `osm_ids`
  value. Possible values are node (`"N"`), way (`"W"`) or relation
  (`"R"`). If a single value is provided, it will be recycled.

- full_results:

  Return all available data from the Nominatim API. If `FALSE`
  (default), only address columns are returned. See also
  `return_addresses`.

- return_addresses:

  Return input addresses with results if `TRUE`.

- verbose:

  If `TRUE`, detailed logs are output to the console.

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

See <https://nominatim.org/release-docs/latest/api/Lookup/> for
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

Address lookup functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)

Geocoding functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

Spatial output functions:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Notre Dame Cathedral, Paris

NotreDame <- geo_address_lookup_sf(osm_ids = 201611261, type = "W")

# Require at least one non-empty object
if (!all(sf::st_is_empty(NotreDame))) {
  library(ggplot2)

  ggplot(NotreDame) +
    geom_sf()
}


NotreDame_poly <- geo_address_lookup_sf(201611261,
  type = "W",
  points_only = FALSE
)

if (!all(sf::st_is_empty(NotreDame_poly))) {
  ggplot(NotreDame_poly) +
    geom_sf()
}


# Vectorized input

several <- geo_address_lookup_sf(c(146656, 240109189), type = c("R", "N"))
several
#> Simple feature collection with 2 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -2.232455 ymin: 52.51739 xmax: 13.39513 ymax: 53.44246
#> Geodetic CRS:  WGS 84
#> # A tibble: 2 × 3
#>   query      address                                               geometry
#> * <chr>      <chr>                                              <POINT [°]>
#> 1 R146656    Manchester, Greater Manchester, England,… (-2.232455 53.44246)
#> 2 N240109189 Berlin, Deutschland                        (13.39513 52.51739)
# }
```
