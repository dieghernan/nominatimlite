#' OpenStreetMap amenity database
#'
#' @description
#' Database with the list of amenities available on OpenStreetMap.
#'
#' @family datasets
#' @family amenity
#'
#' @encoding UTF-8
#'
#' @name osm_amenities
#'
#' @docType data
#'
#' @format
#' A [`tibble`][tibble::tibble] with with
#' `r prettyNum(nrow(nominatimlite::osm_amenities), big.mark=",")` rows and
#' fields:
#' \describe{
#'   \item{category}{The category of the amenity.}
#'   \item{amenity}{The value of the amenity.}
#'   \item{comment}{A brief description of the type of amenity.}
#' }
#'
#'
#' @source <https://wiki.openstreetmap.org/wiki/Key:amenity>
#'
#' @note Data extracted on **03 April 2024**.
#'
#' @examples
#'
#' data("osm_amenities")
#'
#' amenities
NULL
