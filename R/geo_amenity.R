#' Geocode amenities
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This operation is not supported any more. Use
#' [arcgeocoder::arc_geo_categories()] instead.
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
#' @return An error.
#'
#' @seealso [geo_amenity_sf()]
#' @keywords internal
#'
#' @export
#' @examples
#' \donttest{
#' #' # Madrid, Spain
#'
#' library(arcgeocoder)
#' library(ggplot2)
#'
#' bbox <- c(-3.888954, 40.311977, -3.517916, 40.643729)
#'
#' # Food
#' rest_pub <- arc_geo_categories(
#'   bbox = bbox, category = "Bakery,Bar or Pub",
#'   full_results = TRUE,
#'   limit = 50
#' )
#'
#' rest_pub
#' }
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
      with = "arcgeocoder::arc_geo_categories()",
      details = paste(
        "Operation not supported any",
        "more by the Nominatim API."
      )
    )
  }
}
