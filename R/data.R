#' OpenStreetMap amenity database
#'
#' @description
#' Database with the list of amenities available on OpenStreetMap.
#'
#'
#' @encoding UTF-8

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
#' @examples
#'
#' amenities <- nominatimlite::osm_amenities
#'
#' amenities
NULL
