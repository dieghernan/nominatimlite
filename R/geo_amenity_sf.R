#' Geocode amenities in Spatial format
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This operation is not supported any more. Use
#' [arcgeocoder::arc_geo_categories()] instead.
#'
#'
#' @inheritParams geo_lite_sf
#' @inheritParams geo_amenity
#'
#' @return An error
#'
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
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
#' if (nrow(rest_pub) > 1) {
#'   # To sf
#'   rest_pub_sf <- sf::st_as_sf(rest_pub, coords = c("lon", "lat"), crs = 4326)
#'
#'   ggplot(rest_pub_sf) +
#'     geom_sf(aes(color = Type))
#' }
#' }
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
      with = "arcgeocoder::arc_geo_categories()",
      details = paste(
        "Operation not supported any",
        "more by the Nominatim API."
      )
    )
  }
}
