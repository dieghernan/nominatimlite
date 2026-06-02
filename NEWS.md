# nominatimlite 0.6.0

- The minimum required **R** version is now 4.1.0.
- Documentation has been proofread and aligned across roxygen2 comments, README
  and vignettes with AI assistance.
- Internal code has been refactored with AI assistance to reduce duplication in
  URL construction, progress handling, coordinate validation and output
  preparation without changing the public API.
- User-facing messages have been clarified with AI assistance, including
  unreachable API endpoint messages, capped `limit` messages and empty
  structured query messages.

# nominatimlite 0.5.0

- API calls are cached in `tempdir()` during the current session to reduce load
  on the service.
- API calls now wait 1.2 seconds between requests to reduce overload risk.
- Vignettes have been migrated to Quarto.

# nominatimlite 0.4.3

- Minor fixes in reverse functions.

# nominatimlite 0.4.2

- Update documentation.

# nominatimlite 0.4.1

- `geo_address_lookup()` and `geo_address_lookup_sf()` now validate long OSM IDs
  without crashing (#47, reported by \@lshydro).

# nominatimlite 0.4.0

- Adapt endpoints to **Nominatim v4.4.0** `[Python-only]`.

- API calls for non-spatial functions now use JSONV2 format (`&format=jsonv2`),
  so `class` is renamed to `category` and `place_rank` is added with the search
  rank of the object.

- The `custom_query` argument now supports vectors and logical values:

  ``` r
  geo_lite(address = "New York",
           custom_query = list(addressdetails = TRUE,
                               viewbox = c(-60, -20, 60, 20))
           )
  ```

- The `nominatim_server` argument lets **nominatimlite** use a local server
  (#42, \@alexwhitedatamine).

- `geo_amenity()` and `geo_amenity_sf()` are back as wrappers of
  `geo_lite_struct()` and `geo_lite_struct_sf()`, making them more robust and
  compatible with **sf** objects.

- `geo_lite_struct()` and `geo_lite_struct_sf()` are new functions for
  structured queries.

- `nominatimlite::osm_amenities` has been reintroduced with updated data and
  additional description fields.

- Unnesting fields requested with `custom_query = list(extratags = TRUE)` is
  improved.

# nominatimlite 0.3.0

- `geo_lite()`, `geo_lite_sf()`, `reverse_geo_lite()` and
  `reverse_geo_lite_sf()` gain a `progressbar` parameter to display progress in
  the console.

## Deprecated

- `geo_amenity()` and `geo_amenity_sf()`, see
  [Nominatim/issues/1311](https://github.com/osm-search/Nominatim/issues/1311).
  Use `arcgeocoder::arc_geo_categories()` as an alternative.
- `nominatimlite::osm_amenities` dataset deleted.

# nominatimlite 0.2.1

- Remove **osmdata** from Suggests.
- Fix examples.

# nominatimlite 0.2.0

- Improvements in code and tests.
- **rlang** and **tibble** are no longer explicitly required. Conversions to
  tibble happen with `dplyr::tibble()`.
- **sf** object attributes are now returned as tibbles for easier printing in
  the console.
- **sf** objects now handle nested fields provided in the JSON response, such as
  the nested address field, consistently with non-spatial functions.
- `reverse_geo_lite()` and `reverse_geo_lite_sf()` output is improved when the
  API returns nested lists.

# nominatimlite 0.1.6

- Improve results when there is no response from the API.

# nominatimlite 0.1.5

- Avoid de-duplication on results.

# nominatimlite 0.1.4

- Fix issues with `geo_amenity()` and `geo_amenity_sf()`.

# nominatimlite 0.1.3

- Skip API query tests on **CRAN** to avoid false positives.
- Centralize API queries on (internal) function `api_call()`.
- Queries now fully honor the [Nominatim Usage
  Policy](https://operations.osmfoundation.org/policies/nominatim/). Queries may
  be slower now.

# nominatimlite 0.1.2

- New internal function: `nominatim_check_access()`.
- Adapt tests to **testthat** `v3.1.0`.

# nominatimlite 0.1.1

- Adapt tests to **CRAN** checks.

# nominatimlite 0.1.0

- **CRAN** release.
- Adjust query rate limits to Nominatim policy.
- New `strict` argument on `geo_amenity()` and `geo_amenity_sf()`.
- Parameter `polygon` changed to `points_only` (#8) thanks to @jlacko.
- Package now fails gracefully if the URL is not reachable.

# nominatimlite 0.0.1

- Initial version of the package.
