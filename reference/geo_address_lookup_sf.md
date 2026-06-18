# Address lookup API with [sf](https://CRAN.R-project.org/package=sf) output

Looks up addresses and other details for one or more OpenStreetMap (OSM)
objects, such as nodes, ways or relations. Results are returned as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object using
[sf](https://CRAN.R-project.org/package=sf). Use
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)
to return a [tibble](https://tibble.tidyverse.org/reference/tibble.html)
instead.

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

  A numeric vector of OSM identifiers, for example `c(12345, 67890)`.

- type:

  Character vector of the OSM object type associated with each `osm_ids`
  value. Possible values are node (`"N"`), way (`"W"`) or relation
  (`"R"`). If a single value is provided, it will be recycled.

- full_results:

  If `TRUE`, return all available fields from the Nominatim API. If
  `FALSE`, return only query metadata, geometry and requested address
  columns.

- return_addresses:

  If `TRUE`, include single-line addresses in the results.

- verbose:

  If `TRUE`, display detailed messages in the console.

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

See <https://nominatim.org/release-docs/latest/api/Lookup/> for
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

Address lookup functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)

Address search functions:
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
