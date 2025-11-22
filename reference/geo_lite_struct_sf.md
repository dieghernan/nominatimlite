# Address search API in [sf](https://CRAN.R-project.org/package=sf) format (structured query)

Geocodes addresses already split into components and return the
corresponding spatial object. This function returns the spatial object
associated with the query using
[sf](https://CRAN.R-project.org/package=sf), see
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)
for retrieving the data in
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) format.

This function correspond to the **structured query** search described in
the [API
endpoint](https://nominatim.org/release-docs/develop/api/Search/). For
performing a free-form search use
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md).

## Usage

``` r
geo_lite_struct_sf(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
)
```

## Arguments

- amenity:

  Name and/or type of POI, see also
  [geo_amenity](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md).

- street:

  House number and street name.

- city:

  City.

- county:

  County.

- state:

  State.

- country:

  Country.

- postalcode:

  Postal Code.

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

- custom_query:

  A named list with API-specific parameters to be used (i.e.
  `list(countrycodes = "US")`). See **Details**.

- points_only:

  Logical `TRUE/FALSE`. Whether to return only spatial points (`TRUE`,
  which is the default) or potentially other shapes as provided by the
  Nominatim API (`FALSE`). See **About Geometry Types**.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
the results.

## Details

The structured form of the search query allows to look up up an address
that is already split into its components. Each parameter represents a
field of the address. All parameters are optional. You should only use
the ones that are relevant for the address you want to geocode.

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## About Geometry Types

The parameter `points_only` specifies whether the function results will
be points (all Nominatim results are guaranteed to have at least point
geometry) or possibly other spatial objects.

Note that the type of geometry returned in case of `points_only = FALSE`
will depend on the object being geocoded:

- Administrative areas, major buildings and the like will be returned as
  polygons.

- Rivers, roads and their like as lines.

- Amenities may be points even in case of a `points_only = FALSE` call.

The function is vectorized, allowing for multiple addresses to be
geocoded; in case of `points_only = FALSE` multiple geometry types may
be returned.

## See also

[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md).

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)

Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) objects:
[`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)

## Examples

``` r
# \donttest{
# Map

pl_mayor <- geo_lite_struct_sf(
  street = "Plaza Mayor",
  county = "Comunidad de Madrid",
  country = "Spain", limit = 50,
  full_results = TRUE, verbose = TRUE
)

# Outline
ccaa <- geo_lite_sf("Comunidad de Madrid, Spain", points_only = FALSE)

library(ggplot2)

if (any(!sf::st_is_empty(pl_mayor), !sf::st_is_empty(ccaa))) {
  ggplot(ccaa) +
    geom_sf() +
    geom_sf(data = pl_mayor, aes(shape = addresstype, color = addresstype))
}

# }
```
