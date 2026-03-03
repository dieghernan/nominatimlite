# Address search API (free-form query)

Geocodes addresses given as character values. This function returns the
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
associated with the query, see
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md)
for retrieving the data as a spatial object
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) format).

This function correspond to the **free-form query** search described in
the [API
endpoint](https://nominatim.org/release-docs/develop/api/Search/).

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

  `character` with single line address, e.g.
  (`"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
  (`c("Madrid", "Barcelona")`).

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

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results found by the query.

## Details

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## See also

[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`tidygeocoder::geo()`](https://jessecambon.github.io/tidygeocoder/reference/geo.html).

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
geo_lite("Madrid, Spain")
#> # A tibble: 1 × 4
#>   query           lat   lon address                            
#>   <chr>         <dbl> <dbl> <chr>                              
#> 1 Madrid, Spain  40.4 -3.70 Madrid, Comunidad de Madrid, España

# Several addresses
geo_lite(c("Madrid", "Barcelona"))
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 4
#>   query       lat   lon address                                            
#>   <chr>     <dbl> <dbl> <chr>                                              
#> 1 Madrid     40.4 -3.70 Madrid, Comunidad de Madrid, España                
#> 2 Barcelona  41.4  2.18 Barcelona, Barcelonès, Barcelona, Catalunya, España

# With options: restrict search to USA
geo_lite(c("Madrid", "Barcelona"),
  custom_query = list(countrycodes = "US"),
  full_results = TRUE
)
#>   |                                                          |                                                  |   0%  |                                                          |=========================                         |  50%  |                                                          |==================================================| 100%
#> # A tibble: 2 × 25
#>   query       lat    lon address place_id licence osm_type osm_id category type 
#>   <chr>     <dbl>  <dbl> <chr>      <int> <chr>   <chr>     <dbl> <chr>    <chr>
#> 1 Madrid     41.9  -93.8 Madrid…   3.46e8 Data ©… relation 1.29e5 boundary admi…
#> 2 Barcelona  37.7 -121.  Barcel…   2.97e8 Data ©… node     9.63e9 place    neig…
#> # ℹ 15 more variables: place_rank <int>, importance <dbl>, addresstype <chr>,
#> #   name <chr>, display_name <chr>, address.town <chr>, address.county <chr>,
#> #   address.state <chr>, `address.ISO3166-2-lvl4` <chr>, address.country <chr>,
#> #   address.country_code <chr>, boundingbox <list>,
#> #   address.neighbourhood <chr>, address.city <chr>, address.postcode <chr>
# }
```
