#' OpenStreetMap amenities
#'
#' @description
#' A dataset of amenities available on OpenStreetMap.
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
#' @note Data extracted on **April 3, 2024**.
#'
#' @family datasets
#' @family amenity
#' @encoding UTF-8
#' @docType data
#' @name osm_amenities
#'
#' @examples
#'
#' data("osm_amenities")
#'
#' osm_amenities
NULL
