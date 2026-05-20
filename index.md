# nominatimlite

The goal of **nominatimlite** is to provide a lightweight interface for
geocoding addresses with the [Nominatim
API](https://nominatim.org/release-docs/latest/). It also allows you to
retrieve spatial objects using the **sf** package.

The full site with examples and vignettes is available at
<https://dieghernan.github.io/nominatimlite/>

## What is Nominatim?

**Nominatim** is a tool for searching
[OpenStreetMap](https://www.openstreetmap.org/) data by name and address
([geocoding](https://wiki.openstreetmap.org/wiki/Geocoding "Geocoding"))
and to generate synthetic addresses for OSM points (reverse geocoding).

## Why nominatimlite?

**nominatimlite** accesses the Nominatim API without depending on
**curl**. In some situations, **curl** may not be available or
accessible, so **nominatimlite** uses base R functions instead.

## Recommended packages

Other packages are more complete and mature than **nominatimlite** and
provide similar features:

- [**tidygeocoder**](https://jessecambon.github.io/tidygeocoder/)
  ([Cambon et al. 2021](#ref-R-tidygeocoder)): Provides an interface to
  geocoding services such as Nominatim, Google, TomTom and Mapbox.
- [**osmdata**](https://docs.ropensci.org/osmdata/) ([Padgham et al.
  2017](#ref-R-osmdata)): Downloads spatial data from OpenStreetMap with
  the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API).
- [**arcgeocoder**](https://dieghernan.github.io/arcgeocoder/)
  ([Hernangómez 2024](#ref-R-arcgeocoder)): Provides a lightweight
  interface for geocoding with the ArcGIS REST API service.

## Installation

Install **nominatimlite** from
[**CRAN**](https://CRAN.R-project.org/package=nominatimlite):

``` r

install.packages("nominatimlite")
```

## Usage

### `sf` objects

With **nominatimlite** you can extract spatial objects:

``` r

library(nominatimlite)

# Extract Pizza Hut locations in California.

CA <- geo_lite_sf("California", points_only = FALSE)

pizzahut <- geo_lite_sf(
  "Pizza Hut, California",
  limit = 50,
  custom_query = list(countrycodes = "us")
)

library(ggplot2)

ggplot(CA) +
  geom_sf() +
  geom_sf(data = pizzahut, col = "red")
```

![Pizza Hut restaurant locations in California extracted with
nominatimlite.](reference/figures/README-pizzahut-1.png)

You can also extract polygon and line objects when the Nominatim API
provides them, using the option `points_only = FALSE`:

``` r

sol_poly <- geo_lite_sf("Statue of Liberty, NY, USA", points_only = FALSE) # a building, returned as a polygon

ggplot(sol_poly) +
  geom_sf()
```

![Location of the Statue of Liberty extracted with
nominatimlite.](reference/figures/README-statue_liberty-1.png)

``` r

dayton <- geo_lite_sf("Dayton, OH") # default, returned as a point
ohio_state <- geo_lite_sf("Ohio, USA", points_only = FALSE) # a US state, returned as a polygon
ohio_river <- geo_lite_sf("Ohio river", points_only = FALSE) # a river, returned as a line

ggplot() +
  geom_sf(data = ohio_state) +
  geom_sf(data = dayton, color = "red", pch = 4) +
  geom_sf(data = ohio_river, color = "blue")
```

![Different features named Ohio extracted with
nominatimlite.](reference/figures/README-line-object-1.png)

### Geocoding and reverse geocoding

*Note: examples are adapted from the **tidygeocoder** package.*

In this first example, we geocode a few addresses with
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md):

``` r

library(tibble)

# Create a data frame with addresses.
some_addresses <- tribble(
  ~name, ~addr,
  "White House", "1600 Pennsylvania Ave NW, Washington, DC",
  "Transamerica Pyramid", "600 Montgomery St, San Francisco, CA 94111",
  "Willis Tower", "233 S Wacker Dr, Chicago, IL 60606"
)

# Geocode the addresses.
lat_longs <- geo_lite(
  some_addresses$addr,
  lat = "latitude",
  long = "longitude",
  progressbar = FALSE
)
```

This example returns only latitude and longitude from the geocoder
service. Use `full_results = TRUE` to return all data from the geocoder
service.

| query | latitude | longitude | address |
|:---|---:|---:|:---|
| 1600 Pennsylvania Ave NW, Washington, DC | 38.89764 | -77.03655 | White House, 1600, Pennsylvania Avenue Northwest, Ward 2, Washington, District of Columbia, 20500, United States |
| 600 Montgomery St, San Francisco, CA 94111 | 37.79519 | -122.40279 | Transamerica Pyramid, 600, Montgomery Street, Financial District, South of Market, San Francisco, California, 94111, United States |
| 233 S Wacker Dr, Chicago, IL 60606 | 41.87874 | -87.63596 | Willis Tower, 233, South Wacker Drive, Financial District, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60606, United States |

Table 1: Example: geocoding addresses.

To perform reverse geocoding (obtaining addresses from geographic
coordinates), use
[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md).
The arguments are similar to
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
but now we specify the input data columns with the `lat` and `long`
arguments. The dataset used here is from the geocoder query above. The
single-line address is returned in a column named with the `address`
argument.

``` r

reverse <- reverse_geo_lite(
  lat = lat_longs$latitude,
  long = lat_longs$longitude,
  address = "address_found",
  progressbar = FALSE
)
```

| address_found | lat | lon |
|:---|---:|---:|
| White House, 1600, Pennsylvania Avenue Northwest, Ward 2, Washington, District of Columbia, 20500, United States | 38.89764 | -77.03655 |
| Sky Bar, 600, Montgomery Street, Financial District, South of Market, San Francisco, California, 94111, United States | 37.79519 | -122.40254 |
| 233, South Wacker Drive, Financial District, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60606, United States | 41.87874 | -87.63589 |

Table 2: Example: reverse geocoding addresses.

For more advanced users, see the [Nominatim
documentation](https://nominatim.org/release-docs/latest/api/Search/)
for the available parameters.

## Citation

Hernangómez D (2026). *nominatimlite: Interface to the Nominatim API*.
[doi:10.32614/CRAN.package.nominatimlite](https://doi.org/10.32614/CRAN.package.nominatimlite).
<https://dieghernan.github.io/nominatimlite/>.

A BibTeX entry for LaTeX users is

``` R
@Manual{R-nominatimlite,
  title = {{nominatimlite}: Interface to the {Nominatim} {API}},
  doi = {10.32614/CRAN.package.nominatimlite},
  author = {Diego Hernangómez},
  year = {2026},
  version = {0.5.0},
  url = {https://dieghernan.github.io/nominatimlite/},
  abstract = {Lightweight interface to the OpenStreetMap service Nominatim <https://nominatim.org/release-docs/latest/>. Geocode addresses, reverse geocode coordinates, look up amenities and return results as data frames or sf spatial objects.},
}
```

## References

Cambon, Jesse, Diego Hernangómez, Christopher Belanger, and Daniel
Possenriede. 2021. “tidygeocoder: An R Package for Geocoding.” *Journal
of Open Source Software* 6 (65): 3544.
<https://doi.org/10.21105/joss.03544>.

Hernangómez, Diego. 2024. *arcgeocoder: Geocoding with the ArcGIS REST
API Service*. Version 0.1.0. <https://doi.org/10.5281/zenodo.10495365>.

Padgham, Mark, Robin Lovelace, Maëlle Salmon, and Bob Rudis. 2017.
“osmdata.” *Journal of Open Source Software* 2 (14): 305.
<https://doi.org/10.21105/joss.00305>.
