# Check access to Nominatim API

Check if **R** has access to resources at
<https://nominatim.openstreetmap.org>.

## Usage

``` r
nominatim_check_access(
  nominatim_server = "https://nominatim.openstreetmap.org/"
)
```

## Arguments

- nominatim_server:

  The URL of the Nominatim server to use. Defaults to
  `"https://nominatim.openstreetmap.org/"`.

## Value

A logical `TRUE/FALSE`.

## See also

<https://nominatim.org/release-docs/latest/api/Status/>.

## Examples

``` r
# \donttest{
nominatim_check_access()
#> [1] TRUE
# }
```
