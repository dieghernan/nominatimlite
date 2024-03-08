# nominatimlite (development version)

-   It is possible to use **nominatimlite** with local server thanks to the
    new argument `nominatim_server` (#42 \@alexwhitedatamine).

# nominatimlite 0.3.0

-   Add a `progressbar` parameter to `geo_lite()`, `geo_lite_sf()`,
    `reverse_geo_lite()` and `reverse_geo_lite_sf()` to display progress in the
    console.

## Deprecated

-   `geo_amenity()` and `geo_amenity_sf()`, see
    [Nominatim/issues/1311](https://github.com/osm-search/Nominatim/issues/1311).
    Use `arcgeocoder::arc_geo_categories()` as an alternative.
-   `nominatimlite::osm_amenities` data set deleted.

# nominatimlite 0.2.1

-   Remove **osmdata** from Suggests.
-   Fix examples.

# nominatimlite 0.2.0

-   **rlang** and **tibble** are not explicitly required. Conversions to tibble
    happens with `dplyr::tibble()`.
-   The data attributes of **sf** objects are returned now as tibble, for easy
    printing in console.
-   Improvements in code and tests.
-   Now **sf** objects can handle correctly nested fields provided in the json
    response (for example, the nested address field provided by the API). This
    is consistent also with the results provided by the non-spatial functions,
    were unnesting was already handled correctly.
-   Improvements on the output of `reverse_geo_lite()` and
    `reverse_geo_lite_sf()` when the API returns nested lists.

# nominatimlite 0.1.6

-   Improve results when there is no response of the API.

# nominatimlite 0.1.5

-   Avoid de-duplication on results.

# nominatimlite 0.1.4

-   Fix issues with `geo_amenity()` and `geo_amenity_sf()`.

# nominatimlite 0.1.3

-   Skip API query tests on **CRAN** to avoid false positives.
-   Centralize API queries on (internal) function `api_call()`.
-   Queries fully honors now the [Nominatim Usage
    Policy](https://operations.osmfoundation.org/policies/nominatim/). Queries
    may be slower now.

# nominatimlite 0.1.2

-   New internal: `nominatim_check_access()`.
-   Adapt tests to **testthat** v3.1.0.

# nominatimlite 0.1.1

-   Adapt tests to **CRAN** checks.

# nominatimlite 0.1.0

-   **CRAN** release.
-   Adjust query rate limits to Nominatim policy.
-   New `strict` argument on `geo_amenity()` and `geo_amenity_sf()`.
-   Parameter `polygon` changed to `points_only` #8 thanks to @jlacko.
-   Package now falls gracefully if url not reachable.

# nominatimlite 0.0.1

-   Initial version of the package
