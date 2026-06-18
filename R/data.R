#' OpenStreetMap amenities
#'
#' @description
#' A dataset of amenity values available on OpenStreetMap.
#'
#' @format
#' A [tibble][dplyr::tibble] with
#' `r prettyNum(nrow(nominatimlite::osm_amenities), big.mark = ",")` rows and
#' three columns:
#' \describe{
#'   \item{category}{The category of the amenity.}
#'   \item{amenity}{The value of the amenity.}
#'   \item{comment}{A brief description of the type of amenity.}
#' }
#'
#' @source <https://wiki.openstreetmap.org/wiki/Key:amenity>
#'
#' @note The data were extracted on **April 3, 2024**.
#'
#' @family amenity
#' @family datasets
#'
#' @docType data
#' @name osm_amenities
#' @encoding UTF-8
#'
#' @examples
#'
#' data("osm_amenities")
#'
#' osm_amenities
NULL
