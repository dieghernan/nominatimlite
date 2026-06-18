# nominatimlite 0.6.0

- The minimum required version of **R** is now 4.1.0.
- Documentation terminology and style are now consistent across **roxygen2**,
  README and vignettes, with AI assistance.
- Internal code has been refactored with AI assistance to reduce duplication in
  URL construction, progress reporting, coordinate validation and output
  preparation without changing the public API.
- User-facing messages have been clarified with AI assistance, including
  messages for unreachable API endpoints, capped `limit` values and empty
  structured address searches.

# nominatimlite 0.5.0

- API responses are cached in `tempdir()` during the current session to reduce
  load on the service.
- API calls now wait 1.2 seconds between requests to reduce overload risk.
- Vignettes have been migrated to Quarto.

# nominatimlite 0.4.3

- Fixed minor issues in reverse geocoding functions.

# nominatimlite 0.4.2

- Updated documentation.

# nominatimlite 0.4.1

- `geo_address_lookup()` and `geo_address_lookup_sf()` now validate long OSM IDs
  without crashing (#47, reported by \@lshydro).

# nominatimlite 0.4.0

- Updated endpoints for **Nominatim 4.4.0** (`Python-only`).

- API calls for non-spatial functions now use JSONv2 format (`&format=jsonv2`),
  so `class` is renamed to `category` and `place_rank` is added with the search
  rank of the object.

- The `custom_query` argument now supports vectors and logical values:

  ``` r
  geo_lite(address = "New York",
           custom_query = list(addressdetails = TRUE,
                               viewbox = c(-60, -20, 60, 20))
           )
  ```

- The `nominatim_server` argument allows **nominatimlite** to use a local server
  (#42, \@alexwhitedatamine).

- `geo_amenity()` and `geo_amenity_sf()` are back as wrappers of
  `geo_lite_struct()` and `geo_lite_struct_sf()`, making them more robust and
  compatible with `sf` objects.

- `geo_lite_struct()` and `geo_lite_struct_sf()` are new functions for
  structured address searches.

- The `nominatimlite::osm_amenities` dataset has been reintroduced with updated
  data and additional description fields.

- Unnesting fields requested with `custom_query = list(extratags = TRUE)` is
  improved.

# nominatimlite 0.3.0

- `geo_lite()`, `geo_lite_sf()`, `reverse_geo_lite()` and
  `reverse_geo_lite_sf()` gained a `progressbar` argument to display progress in
  the console.

## Deprecated

- Deprecated `geo_amenity()` and `geo_amenity_sf()`. See
  [Nominatim/issues/1311](https://github.com/osm-search/Nominatim/issues/1311).
  Use `arcgeocoder::arc_geo_categories()` as an alternative.
- The `nominatimlite::osm_amenities` dataset was removed.

# nominatimlite 0.2.1

- Removed **osmdata** from `Suggests`.
- Fixed examples.

# nominatimlite 0.2.0

- Improved code and tests.
- **rlang** and **tibble** are no longer explicitly required. Conversions to
  tibbles use `dplyr::tibble()`.
- Attributes of `sf` objects are now returned as tibbles for easier printing in
  the console.
- `sf` objects now handle nested fields provided in the JSON response, such as
  the nested address field, consistently with non-spatial functions.
- `reverse_geo_lite()` and `reverse_geo_lite_sf()` output is improved when the
  API returns nested lists.

# nominatimlite 0.1.6

- Improved results when the API does not respond.

# nominatimlite 0.1.5

- Preserved duplicate inputs in results.

# nominatimlite 0.1.4

- Fixed issues with `geo_amenity()` and `geo_amenity_sf()`.

# nominatimlite 0.1.3

- Skip API query tests on **CRAN** to avoid false positives.
- Centralized API queries in the internal `api_call()` function.
- Queries now fully honor the [Nominatim Usage
  Policy](https://operations.osmfoundation.org/policies/nominatim/). Queries may
  be slower now.

# nominatimlite 0.1.2

- Added the internal `nominatim_check_access()` function.
- Adapted tests to **testthat** 3.1.0.

# nominatimlite 0.1.1

- Adapted tests to **CRAN** checks.

# nominatimlite 0.1.0

- **CRAN** release.
- Adjusted query rate limits to comply with the Nominatim usage policy.
- Added the `strict` argument to `geo_amenity()` and `geo_amenity_sf()`.
- Renamed the `polygon` argument to `points_only` (#8, thanks to @jlacko).
- The package now fails gracefully when the API endpoint is unreachable.

# nominatimlite 0.0.1

- Initial version of the package.
