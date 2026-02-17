# Address search API (structured query)

Geocodes addresses already split into components. This function returns
the [`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
associated with the query, see
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)
for retrieving the data as a spatial object
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) format).

This function correspond to the **structured query** search described in
the [API
endpoint](https://nominatim.org/release-docs/develop/api/Search/). For
performing a free-form search use
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md).

## Usage

``` r
geo_lite_struct(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
)
```

## Arguments

- amenity:

  Name and/or type of POI, see also
  [geo_amenity](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md).

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

- custom_query:

  A named list with API-specific parameters to be used (i.e.
  `list(countrycodes = "US")`). See **Details**.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results found by the query.

## Details

The structured form of the search query allows to look up up an address
that is already split into its components. Each parameter represents a
field of the address. All parameters are optional. You should only use
the ones that are relevant for the address you want to geocode.

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to be passed to `custom_query`.

## See also

[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md),
[`tidygeocoder::geo()`](https://jessecambon.github.io/tidygeocoder/reference/geo.html).

Geocoding:
[`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md),
[`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md),
[`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md),
[`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md),
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
pl_mayor <- geo_lite_struct(
  street = "Plaza Mayor", country = "Spain",
  limit = 50, full_results = TRUE
)


dplyr::glimpse(pl_mayor)
#> Rows: 32
#> Columns: 41
#> $ q_amenity                <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_street                 <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ q_city                   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_county                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_state                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_country                <chr> "Spain", "Spain", "Spain", "Spain", "Spain", …
#> $ q_postalcode             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ lat                      <dbl> 40.41539, 40.96503, 41.65206, 40.02982, 41.93…
#> $ lon                      <dbl> -3.7069974, -5.6640558, -4.7285484, -6.090233…
#> $ address                  <chr> "Plaza Mayor, Barrio de los Austrias, Sol, Ce…
#> $ place_id                 <int> 271613521, 270816802, 270865284, 269044283, 7…
#> $ licence                  <chr> "Data © OpenStreetMap contributors, ODbL 1.0.…
#> $ osm_type                 <chr> "relation", "way", "way", "way", "relation", …
#> $ osm_id                   <int> 16657232, 78180390, 24432960, 184566366, 1820…
#> $ category                 <chr> "highway", "highway", "highway", "highway", "…
#> $ type                     <chr> "pedestrian", "pedestrian", "pedestrian", "pe…
#> $ place_rank               <int> 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 2…
#> $ importance               <dbl> 0.43695500, 0.37221179, 0.32357442, 0.2101211…
#> $ addresstype              <chr> "road", "road", "road", "road", "road", "road…
#> $ name                     <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ display_name             <chr> "Plaza Mayor, Barrio de los Austrias, Sol, Ce…
#> $ address.road             <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ address.neighbourhood    <chr> "Barrio de los Austrias", NA, NA, NA, NA, "La…
#> $ address.quarter          <chr> "Sol", NA, NA, "El Berrocal", NA, NA, NA, NA,…
#> $ address.city_district    <chr> "Centro", "Centro", NA, NA, NA, "Comunidad de…
#> $ address.city             <chr> "Madrid", "Salamanca", "Valladolid", NA, NA, …
#> $ address.state            <chr> "Comunidad de Madrid", "Castilla y León", "Ca…
#> $ `address.ISO3166-2-lvl4` <chr> "ES-MD", "ES-CL", "ES-CL", "ES-EX", "ES-CT", …
#> $ address.postcode         <chr> "28012", "37002", "47001", "10600", "08500", …
#> $ address.country          <chr> "España", "España", "España", "España", "Espa…
#> $ address.country_code     <chr> "es", "es", "es", "es", "es", "es", "es", "es…
#> $ address.province         <chr> NA, "Salamanca", "Valladolid", "Cáceres", "Ba…
#> $ `address.ISO3166-2-lvl6` <chr> NA, "ES-SA", "ES-VA", "ES-CC", "ES-B", "ES-SG…
#> $ address.suburb           <chr> NA, NA, "Plaza Mayor", NA, NA, "La Albuera", …
#> $ address.town             <chr> NA, NA, NA, "Plasencia", "Vic", NA, NA, "Vill…
#> $ address.county           <chr> NA, NA, NA, NA, "Osona", NA, NA, NA, NA, NA, …
#> $ address.region           <chr> NA, NA, NA, NA, NA, NA, NA, "l'Alt Vinalopó /…
#> $ address.village          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ address.hamlet           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ address.borough          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ boundingbox              <list> <40.414988, 40.415813, -3.708121, -3.706630>…
# }
```
