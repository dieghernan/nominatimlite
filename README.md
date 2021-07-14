
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nominatimlite <img src="man/figures/logo.png" align="right" width="120"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/dieghernan/nominatimlite/actions/workflows/check-full.yaml/badge.svg)](https://github.com/dieghernan/nominatimlite/actions/workflows/check-full.yaml)
[![codecov](https://codecov.io/gh/dieghernan/nominatimlite/branch/main/graph/badge.svg?token=jSZ4RIsj91)](https://codecov.io/gh/dieghernan/nominatimlite)
[![GitHub-version](https://img.shields.io/github/r-package/v/dieghernan/nominatimlite?label=version&color=brightgreen)](https://github.com/dieghernan/nominatimlite)
[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)

<!-- badges: end -->

The goal of `nominatimlite` is to provide a light interface for
geocoding addresses, based on the [Nominatim
API](https://nominatim.org/release-docs/latest/). **Nominatim** is a
tool to search [OpenStreetMap](https://www.openstreetmap.org/) data by
name and address
([geocoding](https://wiki.openstreetmap.org/wiki/Geocoding "Geocoding"))
and to generate synthetic addresses of OSM points (reverse geocoding).

This package is derived of the much more mature and complete
`tidygeocoder` package by Jesse Cambon
([link](https://jessecambon.github.io/tidygeocoder/)), that it is
available on CRAN.

## Why `nominatimlite`?

Since `tidygecoder` is much more complete, providing access to several
geocoder services as Mapbox, TomTom or Google, the downloading method is
based on `curl`. In some cases, `curl` could not be available, so
`nominatimlite` uses an approach to overcome this limitation.

This is the main reason for creating this lite version of
`tidygeocoder`.

## What about reverse geocoding?

Reverse geocoding is the process of converting a location as described
by geographic coordinates (latitude, longitude) to a human-readable
address or place name.

This feature is not implemented yet on `nominatimlite` (see
<https://github.com/dieghernan/nominatimlite/issues/1>).

## Installation

You can install the developing version of `nominatimlite` with:

``` r
devtools::install_github("dieghernan/nominatimlite")
```

Alternatively, you can install `nominatimlite` using the
[r-universe](https://dieghernan.r-universe.dev/ui#builds):

``` r
# Enable this universe
options(repos = c(
    dieghernan = 'https://dieghernan.r-universe.dev',
    CRAN = 'https://cloud.r-project.org'))


install.packages('nominatimlite')
```

## Example

This is a basic example which shows you how to geocode some addresses:

``` r
library(nominatimlite)

# Single address
geo_lite("Madrid, Spain")
#> # A tibble: 1 x 4
#>   query         lon   lat full_address                                          
#>   <chr>       <dbl> <dbl> <chr>                                                 
#> 1 Madrid, Sp~ -3.70  40.4 Madrid, Área metropolitana de Madrid y Corredor del H~


# Several addresses

geo_lite(c("Madrid", "Barcelona"))
#> # A tibble: 2 x 4
#>   query      lon   lat full_address                                             
#>   <chr>    <dbl> <dbl> <chr>                                                    
#> 1 Madrid   -3.70  40.4 Madrid, Área metropolitana de Madrid y Corredor del Hena~
#> 2 Barcelo~  2.18  41.4 Barcelona, Barcelonès, Barcelona, Catalunya, 08001, Espa~

# With options

geo_lite(c("Madrid", "Barcelona"),
  long = "Longitude", lat = "Latitude",
  full_results = TRUE, limit = 5
)
#> # A tibble: 10 x 26
#>    query  Longitude Latitude full_address    place_id licence    osm_type osm_id
#>    <chr>      <dbl>    <dbl> <chr>              <int> <chr>      <chr>     <int>
#>  1 Madrid     -3.70    40.4  Madrid, Área m~   2.57e8 Data © Op~ relation 5.33e6
#>  2 Madrid     -3.77    40.5  Comunidad de M~   2.58e8 Data © Op~ relation 6.43e6
#>  3 Madrid     -3.77    40.5  Comunidad de M~   2.57e8 Data © Op~ relation 3.49e5
#>  4 Madrid    -93.8     41.9  Madrid, Boone ~   2.57e8 Data © Op~ relation 1.29e5
#>  5 Madrid    -74.3      4.77 Madrid, Sabana~   2.57e8 Data © Op~ relation 1.41e6
#>  6 Barce~      2.18    41.4  Barcelona, Bar~   2.57e8 Data © Op~ relation 3.48e5
#>  7 Barce~      2.03    41.8  Barcelona, Cat~   3.08e8 Data © Op~ relation 3.49e5
#>  8 Barce~    -35.9     -5.95 Barcelona, Reg~   2.57e8 Data © Op~ relation 3.01e5
#>  9 Barce~    -64.7     10.1  Barcelona, Par~   1.40e6 Data © Op~ node     3.34e8
#> 10 Barce~     -4.50    50.4  Barcelona, Pel~   4.76e6 Data © Op~ node     5.46e8
#> # ... with 18 more variables: boundingbox <list>, class <chr>, type <chr>,
#> #   importance <dbl>, icon <chr>, city <chr>, municipality <chr>, state <chr>,
#> #   postcode <chr>, country <chr>, country_code <chr>, administrative <chr>,
#> #   village <chr>, county <chr>, state_district <chr>, region <chr>,
#> #   hamlet <chr>, suburb <chr>



# Restrict search to USA
geo_lite(c("Madrid", "Barcelona"),
  custom_query = list(countrycodes = "US")
)
#> # A tibble: 2 x 4
#>   query       lon   lat full_address                                            
#>   <chr>     <dbl> <dbl> <chr>                                                   
#> 1 Madrid    -93.8  41.9 Madrid, Boone County, Iowa, 50156, United States        
#> 2 Barcelona -79.6  42.3 Barcelona, Chautauqua County, New York, 14787, United S~
```

For more advance users, see [Nominatim
docs](https://nominatim.org/release-docs/latest/api/Search/) to check
the parameters available.

## Map your results

You can easily convert the results of `nominatimlite` into `sf` objects,
that can be mapped with a variety of packages as `ggplot2`, `tmap` or
`leaflet`

``` r
library(sf)

library(dplyr)
library(ggplot2)
library(ggspatial)


# Search for McDonalds in Madrid, Spain

McDonalds <- geo_lite("McDonalds, Madrid, Spain",
  limit = 50,
  full_results = TRUE
) %>%
  filter(city == "Madrid") %>%
  # Convert to sf object
  st_as_sf(coords = c("lon", "lat"), crs = 4326)


# Plot

ggplot(McDonalds) +
  annotation_map_tile(type = "osm", zoomin = 0) +
  geom_sf(col = "blue")
```

<img src="man/figures/README-map-1.png" width="100%" />
