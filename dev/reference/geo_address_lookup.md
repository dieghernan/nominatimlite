# Address lookup API

The lookup API allows to query the address and other details of one or
multiple OSM objects like node, way or relation. This function returns
the [`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
associated with the query, see
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md)
for retrieving the data as a spatial object
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) format).

## Usage

``` r
geo_address_lookup(
  osm_ids,
  type = c("N", "W", "R"),
  lat = "lat",
  long = "lon",
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
)
```

## Arguments

- osm_ids:

  Vector of OSM identifiers as **numeric** (`c(00000, 11111, 22222)`).

- type:

  Vector character of the type of the OSM type associated to each
  `osm_ids`. Possible values are node (`"N"`), way (`"W"`) or relation
  (`"R"`). If a single value is provided it would be recycled.

- lat:

  Latitude column name in the output data (default `"lat"`).

- long:

  Longitude column name in the output data (default `"long"`).

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

- custom_query:

  A named list with API-specific parameters to be used (i.e.
  `list(countrycodes = "US")`). See **Details**.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results found by the query.

## Details

See <https://nominatim.org/release-docs/develop/api/Lookup/> for
additional parameters to be passed to `custom_query`.

## See also

[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md).

Address Lookup API:
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md)

Geocoding:
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
ids <- geo_address_lookup(osm_ids = c(46240148, 34633854), type = "W")

ids
#> # A tibble: 2 × 4
#>   query       lat   lon address                                                 
#>   <chr>     <dbl> <dbl> <chr>                                                   
#> 1 W46240148  40.8 -73.9 5th Avenue, Harlem, Manhattan Community Board 11, Manha…
#> 2 W34633854  40.7 -74.0 Empire State Building, 350, 5th Avenue, Koreatown, Manh…

several <- geo_address_lookup(c(146656, 240109189), type = c("R", "N"))
several
#> # A tibble: 2 × 4
#>   query        lat   lon address                                                
#>   <chr>      <dbl> <dbl> <chr>                                                  
#> 1 R146656     53.5 -2.25 Manchester, Greater Manchester, England, United Kingdom
#> 2 N240109189  52.5 13.4  Berlin, Deutschland                                    
# }
```
