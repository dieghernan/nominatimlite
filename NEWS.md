# nominatimlite 0.1.3

-   Skip API query tests on CRAN to avoid false positives.
-   Centralize API queries on (internal) function `api_call()`.
-   Queries fully honors now the [Nominatim Usage
    Policy](https://operations.osmfoundation.org/policies/nominatim/). Queries
    may be slower now.

# nominatimlite 0.1.2

-   New internal: `nominatim_check_access()`.

-   Adapt tests to `testthat` v3.1.0.

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
