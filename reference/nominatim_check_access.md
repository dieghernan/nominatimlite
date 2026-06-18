# Check access to the Nominatim API

Checks whether R can access the Nominatim API at
<https://nominatim.openstreetmap.org>.

## Usage

``` r
nominatim_check_access(
  nominatim_server = "https://nominatim.openstreetmap.org/"
)
```

## Arguments

- nominatim_server:

  Base URL of the Nominatim server. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

## Value

A single logical value: `TRUE` if the API is available and `FALSE`
otherwise.

## See also

<https://nominatim.org/release-docs/latest/api/Status/>.

## Examples

``` r
# \donttest{
nominatim_check_access()
#> [1] TRUE
# }
```
