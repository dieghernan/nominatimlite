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
#'   \item{category}{Amenity category.}
#'   \item{amenity}{Amenity value.}
#'   \item{comment}{Brief description of the amenity type.}
#' }
#'
#' @source <https://wiki.openstreetmap.org/wiki/Key:amenity>
#'
#' @note The data were extracted on **April 3, 2024**. See
#' `inst/COPYRIGHTS` for copyright and license details.
#'
#' @family amenity
#' @keywords datasets
#'
#' @docType data
#' @name osm_amenities
#' @encoding UTF-8
#'
#' @examples
#' data("osm_amenities")
#'
#' osm_amenities
NULL
