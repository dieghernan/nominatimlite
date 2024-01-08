#' Geocode amenities in Spatial format
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This operation is not supported any more. Use
#' [**osmdata**](https://github.com/ropensci/osmdata) instead.
#'
#'
#' @inheritParams geo_lite_sf
#' @inheritParams geo_amenity
#'
#' @return A \CRANpkg{sf} object with the results.
#'
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity>.
#'
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @keywords internal
#'
#' @export
geo_amenity_sf <- function(bbox,
                           amenity,
                           limit = 1,
                           full_results = FALSE,
                           return_addresses = TRUE,
                           verbose = FALSE,
                           custom_query = list(),
                           points_only = TRUE,
                           strict = FALSE) {
  if (requireNamespace("lifecycle", quietly = TRUE)) {
    lifecycle::deprecate_stop("0.3.0", "geo_amenity_sf()",
      details = paste(
        "Operation not supported any",
        "more by the Nominatim API."
      )
    )
  }
}
