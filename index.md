# nominatimlite

**nominatimlite** provides a lightweight interface to the [Nominatim
API](https://nominatim.org/release-docs/latest/). It supports free-form
and structured address searches, reverse geocoding, amenity lookup and
address lookup by OpenStreetMap object identifier. Results are returned
as tibbles or `sf` objects.

The full site with examples and vignettes is available at
<https://dieghernan.github.io/nominatimlite/>.

## What is Nominatim?

**Nominatim** searches [OpenStreetMap](https://www.openstreetmap.org/)
data by name and address
([geocoding](https://wiki.openstreetmap.org/wiki/Geocoding "Geocoding"))
and finds addresses from geographic coordinates (reverse geocoding).

## Why nominatimlite?

**nominatimlite** accesses the Nominatim API without requiring the
**curl** package. This makes the package useful in environments where
**curl** is not available. API requests use base R functions instead.

## Recommended packages

Related packages provide broader interfaces to geocoding services and
OpenStreetMap data:

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

Use functions with the `_sf` suffix to return matching results as `sf`
objects:

``` r

library(nominatimlite)

# Search for Pizza Hut locations in California.

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

![Pizza Hut locations in California returned by
nominatimlite.](reference/figures/README-pizzahut-1.png)

Set `points_only = FALSE` to return polygon and line geometries when
they are available from the Nominatim API:

``` r

# A building, returned as a polygon.
sol_poly <- geo_lite_sf("Statue of Liberty, NY, USA", points_only = FALSE)

ggplot(sol_poly) +
  geom_sf()
```

![Statue of Liberty geometry returned by
nominatimlite.](reference/figures/README-statue_liberty-1.png)

``` r

# Default, returned as a point.
dayton <- geo_lite_sf("Dayton, OH")
# A US state, returned as a polygon.
ohio_state <- geo_lite_sf("Ohio, USA", points_only = FALSE)
# A river, returned as a line.
ohio_river <- geo_lite_sf("Ohio river", points_only = FALSE)

ggplot() +
  geom_sf(data = ohio_state) +
  geom_sf(data = dayton, color = "red", pch = 4) +
  geom_sf(data = ohio_river, color = "blue")
```

![Different features named Ohio returned by
nominatimlite.](reference/figures/README-line-object-1.png)

### Address search and reverse geocoding

*The examples in this section are adapted from the **tidygeocoder**
package.*

Use
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
to perform a free-form address search:

``` r

# Create a data frame with addresses.
some_addresses <- dplyr::tribble(
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

By default,
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
returns the query, latitude, longitude and address columns. Set
`full_results = TRUE` to return all available fields from the Nominatim
API.

| query | latitude | longitude | address |
|:---|---:|---:|:---|
| 1600 Pennsylvania Ave NW, Washington, DC | 38.89764 | -77.03655 | White House, 1600, Pennsylvania Avenue Northwest, Ward 2, Washington, District of Columbia, 20500, United States |
| 600 Montgomery St, San Francisco, CA 94111 | 37.79519 | -122.40279 | Transamerica Pyramid, 600, Montgomery Street, Financial District, South of Market, San Francisco, California, 94111, United States |
| 233 S Wacker Dr, Chicago, IL 60606 | 41.87874 | -87.63596 | Willis Tower, 233, South Wacker Drive, Financial District, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60606, United States |

Table 1: Geocoded addresses.

Use
[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md)
to find addresses from latitude and longitude coordinates. The `lat` and
`long` arguments use the results from the address search above. The
`address` argument specifies the name of the output column that contains
each single-line address.

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
| White House, 1600, Pennsylvania Avenue Northwest, Downtown, Ward 2, Washington, District of Columbia, 20500, United States | 38.89764 | -77.03655 |
| 600, Montgomery Street, Financial District, South of Market, San Francisco, California, 94111, United States | 37.79541 | -122.40257 |
| SkyDeck Chicago Willis Tower, 233, South Wacker Drive, Financial District, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60606, United States | 41.87850 | -87.63589 |

Table 2: Reverse-geocoded addresses.

See the [Nominatim search API
documentation](https://nominatim.org/release-docs/latest/api/Search/)
for additional parameters that can be passed through `custom_query`.

## Citation

Hernangómez D (2026). *nominatimlite: Interface to the Nominatim API*.
[doi:10.32614/CRAN.package.nominatimlite](https://doi.org/10.32614/CRAN.package.nominatimlite).
<https://dieghernan.github.io/nominatimlite/>.

A BibTeX entry for LaTeX users is shown below.

``` R
@Manual{R-nominatimlite,
  title = {{nominatimlite}: Interface to the {Nominatim} {API}},
  doi = {10.32614/CRAN.package.nominatimlite},
  author = {Diego Hernangómez},
  year = {2026},
  version = {0.6.0},
  url = {https://dieghernan.github.io/nominatimlite/},
  abstract = {Provides a lightweight interface to the Nominatim API <https://nominatim.org/release-docs/latest/>. It supports free-form and structured address searches, searches for addresses from coordinates, amenity lookup and address lookup by OpenStreetMap object identifier. It returns results as tibble data frames or sf objects.},
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
