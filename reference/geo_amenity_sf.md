# Look up amenities with [sf](https://CRAN.R-project.org/package=sf) output

Looks up OpenStreetMap
[amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
within a bounding box of the form `(xmin, ymin, xmax, ymax)`. Results
are returned as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object using
[sf](https://CRAN.R-project.org/package=sf). Use
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
to return a [tibble](https://tibble.tidyverse.org/reference/tibble.html)
instead.

## Usage

``` r
geo_amenity_sf(
  bbox,
  amenity,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE,
  points_only = TRUE
)
```

## Arguments

- bbox:

  Bounding box (viewbox) used to limit the search. It can be a numeric
  vector of **longitude** (`x`) and **latitude** (`y`) in the form
  `(xmin, ymin, xmax, ymax)`, or a
  [`sf`](https://r-spatial.github.io/sf/reference/sf.html) or
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object. See
  **Details**.

- amenity:

  A character vector of amenities to look up, for example
  `c("pub", "restaurant")`. See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md).

- limit:

  Maximum number of results to return per query. Nominatim returns at
  most 50 results per query.

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

- progressbar:

  If `TRUE`, display a progress bar when processing multiple queries.

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

- strict:

  If `TRUE`, keep only results inside `bbox`. By default, Nominatim may
  return results outside the bounding box.

- points_only:

  If `TRUE`, return only point geometries. If `FALSE`, the API may
  return other geometry types. See **About geometry types**.

## Value

An [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results that match the query.

## Details

Bounding boxes can be located using online tools such as
<https://boundingbox.klokantech.com/>.

For a full list of valid amenities, see
<https://wiki.openstreetmap.org/wiki/Key:amenity> and
[osm_amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md).

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

Amenity lookup functions:
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)

Address search functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

Spatial output functions:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Usera, Madrid

library(ggplot2)
mad <- geo_lite_sf("Usera, Madrid, Spain", points_only = FALSE)

# Restaurants, pubs and schools

rest_pub <- geo_amenity_sf(mad, c("restaurant", "pub", "school"),
  limit = 50
)
#>   |                                                          |                                                  |   0%  |                                                          |=================                                 |  33%  |                                                          |=================================                 |  67%  |                                                          |==================================================| 100%

if (!all(sf::st_is_empty(rest_pub))) {
  ggplot(mad) +
    geom_sf() +
    geom_sf(data = rest_pub, aes(color = query, shape = query))
}

# }
```
