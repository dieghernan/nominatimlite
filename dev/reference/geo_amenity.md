# Geocode amenities

This function search
[amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
as defined by OpenStreetMap on a restricted area defined by a bounding
box in the form `(<xmin>, <ymin>, <xmax>, <ymax>)`. This function
returns the
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
associated with the query, see
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md)
for retrieving the data as a spatial object
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) format).

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

  The bounding box (viewbox) used to limit the search. It could be:

  - A numeric vector of **longitude** (`x`) and **latitude** (`y`)
    `(xmin, ymin, xmax, ymax)`. See **Details**.

  - A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) or
    [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) object.

- amenity:

  A `character` (or a vector of `character`s) with the amenities to be
  geolocated (i.e. `c("pub", "restaurant")`). See
  [osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

- lat:

  Latitude column name in the output data (default `"lat"`).

- long:

  Longitude column name in the output data (default `"long"`).

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

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results found by the query.

## Details

Bounding boxes can be located using different online tools, as [Bounding
Box Tool](https://boundingbox.klokantech.com/).

For a full list of valid amenities see
<https://wiki.openstreetmap.org/wiki/Key:amenity> and
[osm_amenities](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md).

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## See also

Other amenity:
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

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

# Several amenities
geo_amenity(
  bbox = bbox,
  amenity = c("restaurant", "pub")
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 4
#>   query        lat   lon address                                                
#>   <chr>      <dbl> <dbl> <chr>                                                  
#> 1 restaurant  40.8 -74.0 Amor Loco, 134, West 46th Street, Times Square, Manhat…
#> 2 pub         40.8 -74.0 O'Donoghue's, 156, West 44th Street, Times Square, Man…

# Increase limit and use with strict
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
#>  5 restaurant  40.8 -74.0 Bobby Van's Grill, West 45th Street, Times Square, Ma…
#>  6 restaurant  40.8 -74.0 Dallas BBQ, 241, West 42nd Street, Times Square, Manh…
#>  7 restaurant  40.8 -74.0 Haru Sushi, 229, West 43rd Street, Times Square, Manh…
#>  8 restaurant  40.8 -74.0 Brooklyn Deli, 1501, Broadway, Times Square, Manhatta…
#>  9 restaurant  40.8 -74.0 Hard Rock Cafe, 1501, Broadway, Times Square, Manhatt…
#> 10 restaurant  40.8 -74.0 Bubba Gump Shrimp Company, 1501, Broadway, Times Squa…
#> 11 pub         40.8 -74.0 Connolly's, 121, West 45th Street, Times Square, Manh…
#> 12 pub         40.8 -74.0 Perfect Pint, 123, West 45th Street, Times Square, Ma…
#> 13 pub         40.8 -74.0 Merrion Row, West 45th Street, Times Square, Manhatta…
#> 14 pub         40.8 -74.0 O'Donoghue's, 156, West 44th Street, Times Square, Ma…
#> 15 pub         40.8 -74.0 Jimmy's Corner, 140, West 44th Street, Times Square, …
#> 16 pub         40.8 -74.0 BXL Cafe, 125, West 43rd Street, Times Square, Manhat…
#> 17 pub         40.8 -74.0 Bar 54, 135, West 45th Street, Times Square, Manhatta…
# }
```
