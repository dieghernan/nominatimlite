#' Geocode amenities
#'
#' @description
#' `r lifecycle::badge("defunct")`
#'
#' This operation is not supported any more. Use
#' [arcgeocoder::arc_geo_categories()] instead.
#'
#'
#' @param bbox,... Deprecated
#'
#' @return An error.
#'
#' @keywords internal
#' @name geo_amenity
#' @rdname geo_amenity
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
geo_amenity <- function(bbox = NULL, ...) {
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

#'
#' @name geo_amenity_sf
#' @rdname geo_amenity
#'
#' @keywords internal
#' @export
geo_amenity_sf <- function(bbox = NULL, ...) {
  if (requireNamespace("lifecycle", quietly = TRUE)) {
    lifecycle::deprecate_stop("0.3.0", "geo_amenity_sf()",
      with = "arcgeocoder::arc_geo_categories()",
      details = paste(
        "Operation not supported any",
        "more by the Nominatim API."
      )
    )
  }
}
