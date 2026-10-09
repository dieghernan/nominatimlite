# Search for addresses with structured queries

Searches for addresses already split into components and returns
matching results as a
[tibble](https://tibble.tidyverse.org/reference/tibble.html). Use
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)
to return an [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
object instead.

This function performs the **structured address search** described in
the [API
endpoint](https://nominatim.org/release-docs/latest/api/Search/). To
perform a free-form search, use
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md).

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

  A character string specifying the name or type of amenity. See
  [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md).

- street:

  A character string specifying the house number and street name.

- city:

  A character string specifying the city.

- county:

  A character string specifying the county.

- state:

  A character string specifying the state.

- country:

  A character string specifying the country.

- postalcode:

  A character string specifying the postal code.

- lat:

  A character string specifying the name of the latitude column in the
  output. Defaults to `"lat"`.

- long:

  A character string specifying the name of the longitude column in the
  output. Defaults to `"lon"`.

- limit:

  A positive integer specifying the maximum number of results to return
  per query. Nominatim returns at most 50 results per query.

- full_results:

  A logical value indicating whether to return all available fields from
  the Nominatim API. If `FALSE`, only query metadata, location data and
  requested address columns are returned.

- return_addresses:

  A logical value indicating whether to include single-line addresses in
  the results.

- verbose:

  A logical value indicating whether to display detailed messages in the
  console.

- nominatim_server:

  A character string specifying the base URL of the Nominatim server.
  Defaults to `"https://nominatim.openstreetmap.org/"`.

- custom_query:

  A named list of additional API parameters, for example
  `list(countrycodes = "US")`. See **Details**.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the results that match the query.

## Details

A structured address search accepts an address already split into
components. Each argument represents an address field. All components
are optional, so provide only those relevant to the address you want to
find.

See <https://nominatim.org/release-docs/latest/api/Search/> for
additional parameters to pass to `custom_query`.

## See also

Address search functions:
[`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
[`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
[`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)

## Examples

``` r
# \donttest{
pl_mayor <- geo_lite_struct(
  street = "Plaza Mayor", country = "Spain",
  limit = 50, full_results = TRUE
)

dplyr::glimpse(pl_mayor)
#> Rows: 32
#> Columns: 42
#> $ q_amenity                <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_street                 <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ q_city                   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_county                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_state                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ q_country                <chr> "Spain", "Spain", "Spain", "Spain", "Spain", …
#> $ q_postalcode             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ lat                      <dbl> 40.41539, 41.65206, 40.02982, 41.50353, 42.59…
#> $ lon                      <dbl> -3.7069974, -4.7285484, -6.0902338, -5.746671…
#> $ address                  <chr> "Plaza Mayor, Barrio de los Austrias, Sol, Ce…
#> $ place_id                 <int> 293280562, 292162441, 292659361, 293823331, 2…
#> $ licence                  <chr> "Data © OpenStreetMap contributors, ODbL 1.0.…
#> $ osm_type                 <chr> "relation", "way", "way", "way", "way", "way"…
#> $ osm_id                   <int> 16657232, 24432960, 184566366, 46122017, 4634…
#> $ category                 <chr> "highway", "highway", "highway", "highway", "…
#> $ type                     <chr> "pedestrian", "pedestrian", "pedestrian", "pe…
#> $ place_rank               <int> 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 2…
#> $ importance               <dbl> 0.43695500, 0.32592895, 0.19619211, 0.1928328…
#> $ addresstype              <chr> "road", "road", "road", "road", "road", "road…
#> $ name                     <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ display_name             <chr> "Plaza Mayor, Barrio de los Austrias, Sol, Ce…
#> $ address.road             <chr> "Plaza Mayor", "Plaza Mayor", "Plaza Mayor", …
#> $ address.neighbourhood    <chr> "Barrio de los Austrias", NA, NA, "Los Almend…
#> $ address.quarter          <chr> "Sol", NA, "Miralvalle", NA, NA, "San Pablo y…
#> $ address.city_district    <chr> "Centro", NA, NA, NA, NA, NA, NA, NA, NA, NA,…
#> $ address.city             <chr> "Madrid", "Valladolid", NA, "Zamora", "León",…
#> $ address.state            <chr> "Comunidad de Madrid", "Castilla y León", "Ex…
#> $ `address.ISO3166-2-lvl4` <chr> "ES-MD", "ES-CL", "ES-EX", "ES-CL", "ES-CL", …
#> $ address.postcode         <chr> "28012", "47003", "10600", "49004", "24003", …
#> $ address.country          <chr> "España", "España", "España", "España", "Espa…
#> $ address.country_code     <chr> "es", "es", "es", "es", "es", "es", "es", "es…
#> $ address.suburb           <chr> NA, "Plaza Mayor", NA, "Barrio La Lana", "Cas…
#> $ address.state_district   <chr> NA, "Valladolid", "Cáceres", NA, "León", NA, …
#> $ `address.ISO3166-2-lvl6` <chr> NA, "ES-VA", "ES-CC", "ES-ZA", "ES-LE", "ES-P…
#> $ address.hamlet           <chr> NA, NA, "Olivar del Puerto", NA, NA, NA, NA, …
#> $ address.town             <chr> NA, NA, "Plasencia", NA, NA, NA, "Ocaña", "Vi…
#> $ address.province         <chr> NA, NA, NA, "Zamora", NA, "Palencia", NA, NA,…
#> $ address.region           <chr> NA, NA, NA, NA, NA, NA, NA, "l'Alt Vinalopó /…
#> $ address.village          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, "Temblequ…
#> $ address.county           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ address.municipality     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ boundingbox              <list> <40.414989, 40.415813, -3.708120, -3.706629>…
# }
```
