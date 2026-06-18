# Look up amenities

Looks up OpenStreetMap
[amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
within a bounding box of the form `(xmin, ymin, xmax, ymax)`. Results
are returned as a
[tibble](https://tibble.tidyverse.org/reference/tibble.html). Use
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md)
to return an [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
object instead.

## Usage

``` r
geo_amenity(
  bbox,
  amenity,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE
)
```

## Arguments

- bbox:

  A bounding box (viewbox) used to limit the search. Supply a numeric
  vector of **longitude** (`x`) and **latitude** (`y`) in the form
  `(xmin, ymin, xmax, ymax)`, an
  [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object or an
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object. See
  **Details**.

- amenity:

  A character vector of amenities to look up, for example
  `c("pub", "restaurant")`. See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md).

- lat:

  A string giving the name of the latitude column in the output.
  Defaults to `"lat"`.

- long:

  A string giving the name of the longitude column in the output.
  Defaults to `"lon"`.

- limit:

  A positive integer giving the maximum number of results to return per
  query. Nominatim returns at most 50 results per query.

- full_results:

  If `TRUE`, return all available fields from the Nominatim API. If
  `FALSE`, return only query metadata, location data and requested
  address columns.

- return_addresses:

  If `TRUE`, include single-line addresses in the results.

- verbose:

  If `TRUE`, displays detailed messages in the console.

- nominatim_server:

  A string giving the base URL of the Nominatim server. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

- progressbar:

  If `TRUE`, displays a progress bar when processing multiple queries.

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

- strict:

  If `TRUE`, keeps only results inside `bbox`. If `FALSE` (the default),
  Nominatim may return results outside the bounding box.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results that match the query.

## Details

Bounding boxes can be located using online tools such as
<https://boundingbox.klokantech.com/>.

For a full list of valid amenities, see
<https://wiki.openstreetmap.org/wiki/Key:amenity> and
[osm_amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md).

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## See also

Amenity lookup functions:
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)

Address search functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
# Times Square, NY, USA
bbox <- c(
  -73.9894467311, 40.75573629,
  -73.9830630737, 40.75789245
)

geo_amenity(
  bbox = bbox,
  amenity = "restaurant"
)
#> # A tibble: 1 × 4
#>   query        lat   lon address                                                
#>   <chr>      <dbl> <dbl> <chr>                                                  
#> 1 restaurant  40.8 -74.0 Amor Loco, 134, West 46th Street, Times Square, Manhat…

# Multiple amenities
geo_amenity(
  bbox = bbox,
  amenity = c("restaurant", "pub")
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 4
#>   query        lat   lon address                                                
#>   <chr>      <dbl> <dbl> <chr>                                                  
#> 1 restaurant  40.8 -74.0 Amor Loco, 134, West 46th Street, Times Square, Manhat…
#> 2 pub         40.8 -74.0 Connolly's, 121, West 45th Street, Times Square, Manha…

# Increase `limit` and use strict filtering
geo_amenity(
  bbox = bbox,
  amenity = c("restaurant", "pub"),
  limit = 10,
  strict = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 17 × 4
#>    query        lat   lon address                                               
#>    <chr>      <dbl> <dbl> <chr>                                                 
#>  1 restaurant  40.8 -74.0 Sardi's, 234, West 44th Street, Times Square, Manhatt…
#>  2 restaurant  40.8 -74.0 Amor Loco, 134, West 46th Street, Times Square, Manha…
#>  3 restaurant  40.8 -74.0 Dave & Buster's, 234, West 42nd Street, Times Square,…
#>  4 restaurant  40.8 -74.0 Applebee's, 234, West 42nd Street, Times Square, Manh…
#>  5 restaurant  40.8 -74.0 Bobby Van's Grill, 120, West 45th Street, Times Squar…
#>  6 restaurant  40.8 -74.0 Dallas BBQ, 241, West 42nd Street, Times Square, Manh…
#>  7 restaurant  40.8 -74.0 Villa Fresh Italian Kitchen, 263, West 42nd Street, T…
#>  8 restaurant  40.8 -74.0 Haru Sushi, 229, West 43rd Street, Times Square, Manh…
#>  9 restaurant  40.8 -74.0 Brooklyn Deli, 1501, Broadway, Times Square, Manhatta…
#> 10 restaurant  40.8 -74.0 Hard Rock Cafe, 1501, Broadway, Times Square, Manhatt…
#> 11 pub         40.8 -74.0 Connolly's, 121, West 45th Street, Times Square, Manh…
#> 12 pub         40.8 -74.0 Perfect Pint, 123, West 45th Street, Times Square, Ma…
#> 13 pub         40.8 -74.0 Bar 54, 135, West 45th Street, Times Square, Manhatta…
#> 14 pub         40.8 -74.0 Merrion Row, 119, West 45th Street, Times Square, Man…
#> 15 pub         40.8 -74.0 O'Donoghue's, 156, West 44th Street, Times Square, Ma…
#> 16 pub         40.8 -74.0 Jimmy's Corner, 140, West 44th Street, Times Square, …
#> 17 pub         40.8 -74.0 BXL Cafe, 125, West 43rd Street, Times Square, Manhat…
# }
```
