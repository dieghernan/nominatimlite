# Check access to the Nominatim API

Checks whether R can access a Nominatim API server.

## Usage

``` r
nominatim_check_access(
  nominatim_server = "https://nominatim.openstreetmap.org/"
)
```

## Arguments

- nominatim_server:

  A character string specifying the base URL of the Nominatim server.
  Defaults to `"https://nominatim.openstreetmap.org/"`.

## Value

A single logical value: `TRUE` if the API is available and `FALSE`
otherwise.

## See also

[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md)
for submitting search requests and the [Nominatim status
endpoint](https://nominatim.org/release-docs/latest/api/Status/) for
server status details.

## Examples

``` r
# \donttest{
nominatim_check_access()
#> [1] TRUE
# }
```
