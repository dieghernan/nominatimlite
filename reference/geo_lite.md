# Address search API (free-form query)

Searches for addresses supplied as a character vector and returns
matching results as a
[tibble](https://tibble.tidyverse.org/reference/tibble.html). Use
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md)
to return an [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
object instead.

This function performs the **free-form address search** described in the
[API endpoint](https://nominatim.org/release-docs/latest/api/Search/).

## Usage

``` r
geo_lite(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list()
)
```

## Arguments

- address:

  A character vector of single-line addresses, for example
  `"1600 Pennsylvania Ave NW, Washington"` or
  `c("Madrid", "Barcelona")`.

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

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results that match the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## See also

Address search functions:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
geo_lite("Madrid, Spain")
#> # A tibble: 1 × 4
#>   query           lat   lon address                            
#>   <chr>         <dbl> <dbl> <chr>                              
#> 1 Madrid, Spain  40.4 -3.70 Madrid, Comunidad de Madrid, España

# Multiple addresses
geo_lite(c("Madrid", "Barcelona"))
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 4
#>   query       lat   lon address                                            
#>   <chr>     <dbl> <dbl> <chr>                                              
#> 1 Madrid     40.4 -3.70 Madrid, Comunidad de Madrid, España                
#> 2 Barcelona  41.4  2.18 Barcelona, Barcelonès, Barcelona, Catalunya, España

# Restrict the search to the United States and return all fields
geo_lite(c("Madrid", "Barcelona"),
  custom_query = list(countrycodes = "US"),
  full_results = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 24
#>   query       lat   lon address  place_id licence osm_type osm_id category type 
#>   <chr>     <dbl> <dbl> <chr>       <int> <chr>   <chr>     <int> <chr>    <chr>
#> 1 Madrid     41.9 -93.8 Madrid,…   3.73e8 Data ©… relation 1.29e5 boundary admi…
#> 2 Barcelona  42.3 -79.6 Barcelo…   3.51e8 Data ©… node     1.58e8 place    haml…
#> # ℹ 14 more variables: place_rank <int>, importance <dbl>, addresstype <chr>,
#> #   name <chr>, display_name <chr>, address.town <chr>, address.county <chr>,
#> #   address.state <chr>, `address.ISO3166-2-lvl4` <chr>,
#> #   address.postcode <chr>, address.country <chr>, address.country_code <chr>,
#> #   boundingbox <list>, address.hamlet <chr>
# }
```
