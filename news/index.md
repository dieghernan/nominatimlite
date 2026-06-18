# Changelog

## nominatimlite 0.6.0

CRAN release: 2026-06-03

- The minimum required version of **R** is now 4.1.0.
- Documentation terminology and style are now consistent across
  **roxygen2**, README and vignettes, with AI assistance.
- Internal code has been refactored with AI assistance to reduce
  duplication in URL construction, progress reporting, coordinate
  validation and output preparation without changing the public API.
- User-facing messages have been clarified with AI assistance, including
  messages for unreachable API endpoints, capped `limit` values and
  empty structured address searches.

## nominatimlite 0.5.0

CRAN release: 2026-03-18

- API responses are cached in
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) during the current
  session to reduce load on the service.
- API calls now wait 1.2 seconds between requests to reduce overload
  risk.
- Vignettes have been migrated to Quarto.

## nominatimlite 0.4.3

CRAN release: 2026-01-11

- Fixed minor issues in reverse geocoding functions.

## nominatimlite 0.4.2

CRAN release: 2024-12-17

- Updated documentation.

## nominatimlite 0.4.1

CRAN release: 2024-07-19

- [`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)
  and
  [`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md)
  now validate long OSM IDs without crashing
  ([\#47](https://github.com/dieghernan/nominatimlite/issues/47),
  reported by [@lshydro](https://github.com/lshydro)).

## nominatimlite 0.4.0

CRAN release: 2024-05-27

- Updated endpoints for **Nominatim 4.4.0** (`Python-only`).

- API calls for non-spatial functions now use JSONv2 format
  (`&format=jsonv2`), so `class` is renamed to `category` and
  `place_rank` is added with the search rank of the object.

- The `custom_query` argument now supports vectors and logical values:

  ``` r

  geo_lite(address = "New York",
           custom_query = list(addressdetails = TRUE,
                               viewbox = c(-60, -20, 60, 20))
           )
  ```

- The `nominatim_server` argument allows **nominatimlite** to use a
  local server
  ([\#42](https://github.com/dieghernan/nominatimlite/issues/42),
  [@alexwhitedatamine](https://github.com/alexwhitedatamine)).

- [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
  and
  [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md)
  are back as wrappers of
  [`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)
  and
  [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md),
  making them more robust and compatible with `sf` objects.

- [`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)
  and
  [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)
  are new functions for structured address searches.

- The
  [`nominatimlite::osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
  dataset has been reintroduced with updated data and additional
  description fields.

- Unnesting fields requested with
  `custom_query = list(extratags = TRUE)` is improved.

## nominatimlite 0.3.0

CRAN release: 2024-03-01

- [`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md),
  [`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md),
  [`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md)
  and
  [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)
  gained a `progressbar` argument to display progress in the console.

### Deprecated

- Deprecated
  [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
  and
  [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md).
  See
  [Nominatim/issues/1311](https://github.com/osm-search/Nominatim/issues/1311).
  Use
  [`arcgeocoder::arc_geo_categories()`](https://dieghernan.github.io/arcgeocoder/reference/arc_geo_categories.html)
  as an alternative.
- The
  [`nominatimlite::osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
  dataset was removed.

## nominatimlite 0.2.1

CRAN release: 2023-08-15

- Removed **osmdata** from `Suggests`.
- Fixed examples.

## nominatimlite 0.2.0

CRAN release: 2023-05-11

- Improved code and tests.
- **rlang** and **tibble** are no longer explicitly required.
  Conversions to tibbles use
  [`dplyr::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
- Attributes of `sf` objects are now returned as tibbles for easier
  printing in the console.
- `sf` objects now handle nested fields provided in the JSON response,
  such as the nested address field, consistently with non-spatial
  functions.
- [`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md)
  and
  [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)
  output is improved when the API returns nested lists.

## nominatimlite 0.1.6

CRAN release: 2022-06-10

- Improved results when the API does not respond.

## nominatimlite 0.1.5

CRAN release: 2021-11-26

- Preserved duplicate inputs in results.

## nominatimlite 0.1.4

CRAN release: 2021-10-28

- Fixed issues with
  [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
  and
  [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md).

## nominatimlite 0.1.3

CRAN release: 2021-10-21

- Skip API query tests on **CRAN** to avoid false positives.
- Centralized API queries in the internal `api_call()` function.
- Queries now fully honor the [Nominatim Usage
  Policy](https://operations.osmfoundation.org/policies/nominatim/).
  Queries may be slower now.

## nominatimlite 0.1.2

CRAN release: 2021-10-07

- Added the internal
  [`nominatim_check_access()`](https://dieghernan.github.io/nominatimlite/reference/nominatim_check_access.md)
  function.
- Adapted tests to **testthat** 3.1.0.

## nominatimlite 0.1.1

CRAN release: 2021-09-30

- Adapted tests to **CRAN** checks.

## nominatimlite 0.1.0

CRAN release: 2021-09-16

- **CRAN** release.
- Adjusted query rate limits to comply with the Nominatim usage policy.
- Added the `strict` argument to
  [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
  and
  [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md).
- Renamed the `polygon` argument to `points_only`
  ([\#8](https://github.com/dieghernan/nominatimlite/issues/8), thanks
  to [@jlacko](https://github.com/jlacko)).
- The package now fails gracefully when the API endpoint is unreachable.

## nominatimlite 0.0.1

- Initial version of the package.
