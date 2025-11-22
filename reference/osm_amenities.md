# OpenStreetMap amenity database

Database with the list of amenities available on OpenStreetMap.

## Format

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
with 136 rows and fields:

- category:

  The category of the amenity.

- amenity:

  The value of the amenity.

- comment:

  A brief description of the type of amenity.

## Source

<https://wiki.openstreetmap.org/wiki/Key:amenity>

## Note

Data extracted on **03 April 2024**.

## See also

Other amenity:
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md)

## Examples

``` r
data("osm_amenities")

osm_amenities
#> # A tibble: 136 × 3
#>    category   amenity        comment                                            
#>    <chr>      <chr>          <chr>                                              
#>  1 Sustenance bar            Bar is a purpose-built commercial establishment th…
#>  2 Sustenance biergarten     Biergarten or beer garden is an open-air area wher…
#>  3 Sustenance cafe           Cafe is generally an informal place that offers ca…
#>  4 Sustenance fast_food      Fast food restaurant (see also amenity=restaurant)…
#>  5 Sustenance food_court     An area with several different restaurant food cou…
#>  6 Sustenance ice_cream      Ice cream shop or ice cream parlour. A place that …
#>  7 Sustenance pub            A place selling beer and other alcoholic drinks; m…
#>  8 Sustenance restaurant     Restaurant (not fast food, see amenity=fast_food).…
#>  9 Education  college        Campus or buildings of an institute of Further Edu…
#> 10 Education  dancing_school A dancing school or dance studio                   
#> # ℹ 126 more rows
```
