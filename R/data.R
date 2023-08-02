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
#' @format A `tibble` with with
#' `r prettyNum(nrow(nominatimlite::osm_amenities), big.mark=",")` rows and
#' fields:
#' \describe{
#'   \item{category}{The category of the amenity}
#'   \item{amenity}{The name of the amenity}
#' }
#'
#' @details
#'
#' ```{r, echo=FALSE}
#'
#' t <- nominatimlite::osm_amenities
#'
#' knitr::kable(t, col.names = c("**category**", "**amenity**"))
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
