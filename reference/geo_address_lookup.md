# Look up OpenStreetMap objects

Looks up addresses and other details for one or more OpenStreetMap (OSM)
objects, such as nodes, ways or relations. Results are returned as a
[tibble](https://tibble.tidyverse.org/reference/tibble.html). Use
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md)
to return an [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
object instead.

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

  A numeric vector of OSM identifiers, for example `c(12345, 67890)`.

- type:

  A character vector containing the OSM object type associated with each
  value in `osm_ids`. Possible values are node (`"N"`), way (`"W"`) and
  relation (`"R"`). A single value is recycled.

- lat:

  A character string specifying the name of the latitude column in the
  output. Defaults to `"lat"`.

- long:

  A character string specifying the name of the longitude column in the
  output. Defaults to `"lon"`.

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

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results that match the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Lookup/> for
additional parameters to pass to `custom_query`.

## See also

Address lookup functions:
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md)

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
#> 1 R146656     53.4 -2.23 Manchester, Greater Manchester, England, United Kingdom
#> 2 N240109189  52.5 13.4  Berlin, Deutschland                                    
# }
```
