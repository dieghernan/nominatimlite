# Address lookup API

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

  Character vector of the OSM object type associated with each `osm_ids`
  value. Possible values are node (`"N"`), way (`"W"`) or relation
  (`"R"`). If a single value is provided, it will be recycled.

- lat:

  Name of the latitude column in the output. Defaults to `"lat"`.

- long:

  Name of the longitude column in the output. Defaults to `"lon"`.

- full_results:

  If `TRUE`, return all available fields from the Nominatim API. If
  `FALSE`, return only query metadata, location data and requested
  address columns.

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

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results that match the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Lookup/> for
additional parameters to be passed to `custom_query`.

## See also

Address lookup functions:
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md)

Address search functions:
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

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
