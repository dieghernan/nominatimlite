#' Geocode amenities
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This operation is not supported any more. Use
#' [**osmdata**](https://github.com/ropensci/osmdata) instead.
#'
#'
#' @param bbox A numeric vector of latitude and longitude
#'   `(<min_latitude>, <min_longitude>, <max_latitude>, <max_longitude>)` that
#'   restrict the search area. See **Details**.
#' @param amenity A character of a vector of character with the amenities to be
#'   geolocated (i.e. `c("pub", "restaurant")`).
#' @param custom_query API-specific parameters to be used.
#' @param strict Logical `TRUE/FALSE`. Force the results to be included inside
#' the `bbox`. Note that Nominatim default behavior may return results located
#' outside the provided bounding box.
#'
#' @inheritParams geo_lite
#'
#' @return A \CRANpkg{tibble} with the results.
#'
#' @seealso [geo_amenity_sf()]
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity>.
#'
#'
#' @keywords internal
#'
#' @export
geo_amenity <- function(bbox,
                        amenity,
                        lat = "lat",
                        long = "lon",
                        limit = 1,
                        full_results = FALSE,
                        return_addresses = TRUE,
                        verbose = FALSE,
                        custom_query = list(),
                        strict = FALSE) {
  if (requireNamespace("lifecycle", quietly = TRUE)) {
    lifecycle::deprecate_stop("0.3.0", "geo_amenity()",
      details = paste(
        "Operation not supported any",
        "more by the Nominatim API."
      )
    )
  }
}
