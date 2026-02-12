# Geocode amenities in [sf](https://CRAN.R-project.org/package=sf) format

This function search
[amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
as defined by OpenStreetMap on a restricted area defined by a bounding
box in the form `(<xmin>, <ymin>, <xmax>, <ymax>)`. This function
returns the spatial object associated with the query using
[sf](https://CRAN.R-project.org/package=sf), see
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md)
for retrieving the data in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

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

  The bounding box (viewbox) used to limit the search. It could be:

  - A numeric vector of **longitude** (`x`) and **latitude** (`y`)
    `(xmin, ymin, xmax, ymax)`. See **Details**.

  - A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) or
    [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object.

- amenity:

  A `character` (or a vector of `character`s) with the amenities to be
  geolocated (i.e. `c("pub", "restaurant")`). See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

- limit:

  Maximum number of results to return per input address. Note that each
  query returns a maximum of 50 results.

- full_results:

  Returns all available data from the API service. If `FALSE` (default)
  only latitude, longitude and address columns are returned. See also
  `return_addresses`.

- return_addresses:

  Return input addresses with results if `TRUE`.

- verbose:

  If `TRUE` then detailed logs are output to the console.

- nominatim_server:

  The URL of the Nominatim server to use. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

- progressbar:

  Logical. If `TRUE` displays a progress bar to indicate the progress of
  the function.

- custom_query:

  A named list with API-specific parameters to be used (i.e.
  `list(countrycodes = "US")`). See **Details**.

- strict:

  Logical `TRUE/FALSE`. Force the results to be included inside the
  `bbox`. Note that Nominatim default behavior may return results
  located outside the provided bounding box.

- points_only:

  Logical `TRUE/FALSE`. Whether to return only spatial points (`TRUE`,
  which is the default) or potentially other shapes as provided by the
  Nominatim API (`FALSE`). See **About Geometry Types**.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results.

## Details

Bounding boxes can be located using different online tools, as [Bounding
Box Tool](https://boundingbox.klokantech.com/).

For a full list of valid amenities see
<https://wiki.openstreetmap.org/wiki/Key:amenity> and
[osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

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

Other amenity:
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) objects:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)

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

if (any(!sf::st_is_empty(rest_pub))) {
  ggplot(mad) +
    geom_sf() +
    geom_sf(data = rest_pub, aes(color = query, shape = query))
}

# }
```
