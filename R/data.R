#' OpenStreetMap amenity database
#'
#' @description
#' Database with the list of amenities available on OpenStreetMap.
#'
#'
#' @family datasets
#' @family amenity
#'
#' @encoding UTF-8
#'
#'
#' @name osm_amenities
#'
#' @docType data
#'
#' @format A `tibble` with the amenities and the corresponding category
#'
#' @details
#'
#' ```{r, echo=FALSE}
#'
#' t <- nominatimlite::osm_amenities
#'
#' knitr::kable(t)
#'
#'
#' ```
#'
#' @source <https://wiki.openstreetmap.org/wiki/Key:amenity>
#'
#' @note Data extracted on **14 June 2021**.
#'
#' @examples
#'
#' amenities <- nominatimlite::osm_amenities
#'
#' amenities
NULL
