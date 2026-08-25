# Look up OpenStreetMap amenities

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

  A numeric vector, an
  [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object or an
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object
  specifying a bounding box (viewbox) used to limit the search. Numeric
  vectors must contain **longitude** (`x`) and **latitude** (`y`) in the
  form `(xmin, ymin, xmax, ymax)`. See **Details**.

- amenity:

  A character vector of amenities to look up, for example
  `c("pub", "restaurant")`. See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md).

- lat:

  A character string specifying the name of the latitude column in the
  output. Defaults to `"lat"`.

- long:

  A character string specifying the name of the longitude column in the
  output. Defaults to `"lon"`.

- limit:

  A positive integer specifying the maximum number of results to return
  per query. Nominatim returns at most 50 results per query.

- full_results:

  A logical value indicating whether to return all available fields from
  the Nominatim API. If `FALSE`, only query metadata, location data and
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
additional parameters to pass to `custom_query`.

## See also

[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md)
for converting bounding box coordinates to a
[sf](https://CRAN.R-project.org/package=sf) polygon.

Amenity lookup functions and data:
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)

## Examples

``` r
# \donttest{
# Define a bounding box around Times Square, New York.
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
#> 1 restaurant  40.8 -74.0 The Mermaid Bar, 127, West 43rd Street, Times Square, …

# Search for multiple amenities.
geo_amenity(
  bbox = bbox,
  amenity = c("restaurant", "pub")
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 4
#>   query        lat   lon address                                                
#>   <chr>      <dbl> <dbl> <chr>                                                  
#> 1 restaurant  40.8 -74.0 The Mermaid Bar, 127, West 43rd Street, Times Square, …
#> 2 pub         40.8 -74.0 BXL Cafe, 125, West 43rd Street, Times Square, Manhatt…

# Increase `limit` and use strict filtering.
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
#>  5 restaurant  40.8 -74.0 Tony's, 147, West 43rd Street, Times Square, Manhatta…
#>  6 restaurant  40.8 -74.0 The Mermaid Bar, 127, West 43rd Street, Times Square,…
#>  7 restaurant  40.8 -74.0 bella vita tranttoria, 211, West 43rd Street, Times S…
#>  8 restaurant  40.8 -74.0 Guy’s American Kitchen & Bar, 220, West 44th Street, …
#>  9 restaurant  40.8 -74.0 Villa Fresh Italian Kitchen, 263, West 42nd Street, T…
#> 10 restaurant  40.8 -74.0 Bubba Gump Shrimp Company, 1501, Broadway, Times Squa…
#> 11 pub         40.8 -74.0 Connolly's, 121, West 45th Street, Times Square, Manh…
#> 12 pub         40.8 -74.0 Perfect Pint, 123, West 45th Street, Times Square, Ma…
#> 13 pub         40.8 -74.0 BXL Cafe, 125, West 43rd Street, Times Square, Manhat…
#> 14 pub         40.8 -74.0 O'Donoghue's, 156, West 44th Street, Times Square, Ma…
#> 15 pub         40.8 -74.0 Bar 54, 135, West 45th Street, Times Square, Manhatta…
#> 16 pub         40.8 -74.0 Jimmy's Corner, 140, West 44th Street, Times Square, …
#> 17 pub         40.8 -74.0 Merrion Row, 119, West 45th Street, Times Square, Man…
# }
```
