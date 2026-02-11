# Get started with nominatimlite

The goal of **nominatimlite** is to provide a light interface for
geocoding addresses, based on the [Nominatim
API](https://nominatim.org/release-docs/latest/). It also allows to load
spatial objects using the **sf** package.

Full site with examples and vignettes on
<https://dieghernan.github.io/nominatimlite/>

## What is Nominatim?

**Nominatim** is a tool to search
[OpenStreetMap](https://www.openstreetmap.org/) data by name and address
([geocoding](https://wiki.openstreetmap.org/wiki/Geocoding "Geocoding"))
and to generate synthetic addresses of OSM points (reverse geocoding).

## Why **nominatimlite**?

The main goal of **nominatimlite** is to access the Nominatim API
avoiding the dependency on **curl**. In some situations, **curl** may
not be available or accessible, so **nominatimlite** uses base functions
to overcome this limitation.

## Recommended packages

There are other packages much more complete and mature than
**nominatimlite**, that presents similar features:

- [**tidygeocoder**](https://jessecambon.github.io/tidygeocoder/)
  ([Cambon et al. 2021](#ref-R-tidygeocoder)): Allows to interface with
  Nominatim, Google, TomTom, Mapbox, etc. for geocoding and reverse
  geocoding.
- [**osmdata**](https://docs.ropensci.org/osmdata/) ([Padgham et al.
  2017](#ref-R-osmdata)): Great for downloading spatial data from
  OpenStreetMap, via the [Overpass
  API](https://wiki.openstreetmap.org/wiki/Overpass_API).
- [**arcgeocoder**](https://dieghernan.github.io/arcgeocoder/)
  ([Hernangómez 2024](#ref-R-arcgeocoder)): Lite interface for geocoding
  with the ArcGIS REST API Service.

## Usage

### `sf` objects

With **nominatimlite** you can extract spatial objects easily:

``` r
library(nominatimlite)

# Extract some points - Pizza Hut in California

CA <- geo_lite_sf("California", points_only = FALSE)

pizzahut <- geo_lite_sf("Pizza Hut, California",
  limit = 50,
  custom_query = list(countrycodes = "us")
)

library(ggplot2)

ggplot(CA) +
  geom_sf() +
  geom_sf(data = pizzahut, col = "red")
```

![Locations of Pizza Hut in
California](../reference/figures/README-pizzahut-1.png)

Locations of Pizza Hut in California

You can also extract polygon and line objects (if available) using the
option `points_only = FALSE`:

``` r
sol_poly <- geo_lite_sf("Statue of Liberty, NY, USA", points_only = FALSE)

ggplot(sol_poly) +
  geom_sf()
```

![The Statue of
Liberty](../reference/figures/README-statue_liberty-1.png)

The Statue of Liberty

### Geocoding and reverse geocoding

*Note: examples adapted from **tidygeocoder** package*

In this first example we will geocode a few addresses using the
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
function:

``` r
library(tibble)

# create a dataframe with addresses
some_addresses <- tribble(
  ~name,                  ~addr,
  "White House",          "1600 Pennsylvania Ave NW, Washington, DC",
  "Transamerica Pyramid", "600 Montgomery St, San Francisco, CA 94111",
  "Willis Tower",         "233 S Wacker Dr, Chicago, IL 60606"
)

# geocode the addresses
lat_longs <- geo_lite(some_addresses$addr, lat = "latitude", long = "longitude")
#> 
  |                                                        
  |                                                  |   0%
  |                                                        
  |=================                                 |  33%
  |                                                        
  |=================================                 |  67%
  |                                                        
  |==================================================| 100%
```

Only latitude and longitude are returned from the geocoder service in
this example, but `full_results = TRUE` can be used to return all of the
data from the geocoder service.

| query                                      | latitude |  longitude | address                                                                                                                           |
|:-------------------------------------------|---------:|-----------:|:----------------------------------------------------------------------------------------------------------------------------------|
| 1600 Pennsylvania Ave NW, Washington, DC   | 38.89764 |  -77.03655 | White House, 1600, Pennsylvania Avenue Northwest, Downtown, Ward 2, Washington, District of Columbia, 20500, United States        |
| 600 Montgomery St, San Francisco, CA 94111 | 37.79519 | -122.40279 | Transamerica Pyramid, 600, Montgomery Street, Telegraph Hill, Financial District, San Francisco, California, 94111, United States |
| 233 S Wacker Dr, Chicago, IL 60606         | 41.87874 |  -87.63596 | Willis Tower, 233, South Wacker Drive, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60606, United States         |

To perform reverse geocoding (obtaining addresses from geographic
coordinates), we can use the
[`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md)
function. The arguments are similar to the
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
function, but now we specify the input data columns with the `lat` and
`long` arguments. The dataset used here is from the geocoder query
above. The single line address is returned in a column named by the
`address`.

``` r
reverse <- reverse_geo_lite(
  lat = lat_longs$latitude, long = lat_longs$longitude,
  address = "address_found"
)
#> 
  |                                                        
  |                                                  |   0%
  |                                                        
  |=================                                 |  33%
  |                                                        
  |=================================                 |  67%
  |                                                        
  |==================================================| 100%
```

| address_found                                                                                                              |      lat |        lon |
|:---------------------------------------------------------------------------------------------------------------------------|---------:|-----------:|
| White House, 1600, Pennsylvania Avenue Northwest, Downtown, Ward 2, Washington, District of Columbia, 20500, United States | 38.89764 |  -77.03655 |
| Sky Bar, 600, Montgomery Street, Telegraph Hill, Financial District, San Francisco, California, 94111, United States       | 37.79519 | -122.40254 |
| West Adams Street, Financial District, Loop, Chicago, South Chicago Township, Cook County, Illinois, 60675, United States  | 41.87874 |  -87.63589 |

For more advance users, see [Nominatim
docs](https://nominatim.org/release-docs/latest/api/Search/) to check
the parameters available.

## References

Cambon, Jesse, Diego Hernangómez, Christopher Belanger, and Daniel
Possenriede. 2021. “tidygeocoder: An R Package for Geocoding.” *Journal
of Open Source Software* 6 (65): 3544.
<https://doi.org/10.21105/joss.03544>.

Hernangómez, Diego. 2024. *arcgeocoder: Geocoding with the ArcGIS REST
API Service* (version 0.1.0). <https://doi.org/10.5281/zenodo.10495365>.

Padgham, Mark, Robin Lovelace, Maëlle Salmon, and Bob Rudis. 2017.
“osmdata.” *Journal of Open Source Software* 2 (14): 305.
<https://doi.org/10.21105/joss.00305>.
