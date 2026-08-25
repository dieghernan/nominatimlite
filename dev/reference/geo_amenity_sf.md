# Look up OpenStreetMap amenities and return [sf](https://CRAN.R-project.org/package=sf) objects

Looks up OpenStreetMap
[amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
within a bounding box of the form `(xmin, ymin, xmax, ymax)`. Results
are returned as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object. Use
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md)
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

  A numeric vector, an
  [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object or an
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object
  specifying a bounding box (viewbox) used to limit the search. Numeric
  vectors must contain **longitude** (`x`) and **latitude** (`y`) in the
  form `(xmin, ymin, xmax, ymax)`. See **Details**.

- amenity:

  A character vector of amenities to look up, for example
  `c("pub", "restaurant")`. See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

- limit:

  A positive integer specifying the maximum number of results to return
  per query. Nominatim returns at most 50 results per query.

- full_results:

  A logical value indicating whether to return all available fields from
  the Nominatim API. If `FALSE`, only query metadata, geometry and
  requested address columns are returned.

- return_addresses:

  A logical value indicating whether to include single-line addresses in
  the results.

- verbose:

  A logical value indicating whether to display detailed messages in the
  console.

- nominatim_server:

  A character string specifying the base URL of the Nominatim server.
  Defaults to `"https://nominatim.openstreetmap.org/"`.

- progressbar:

  A logical value indicating whether to display a progress bar when
  processing multiple queries.

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

- strict:

  A logical value indicating whether to keep only results inside `bbox`.
  If `FALSE` (the default), Nominatim may return results outside the
  bounding box.

- points_only:

  A logical value indicating whether to return only point geometries. If
  `FALSE`, the API may return other geometry types. See **About geometry
  types**.

## Value

An [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results that match the query.

## Details

Bounding boxes can be located using online tools such as
<https://boundingbox.klokantech.com/>.

For a full list of valid amenities, see
<https://wiki.openstreetmap.org/wiki/Key:amenity> and
[osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to pass to `custom_query`.

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

Amenity lookup functions and data:
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)

Spatial helper and output functions:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Retrieve the Usera district in Madrid.

library(ggplot2)
mad <- geo_lite_sf("Usera, Madrid, Spain", points_only = FALSE)

# Search for restaurants, pubs and schools.

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
