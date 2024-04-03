#' Coerce a bounding box to a [`sfc`][sf::st_sfc] `POLYGON` object
#'
#' @description
#' Create a [`sfc`][sf::st_sfc] object from the coordinates of a bounding box.
#'
#' @family spatial
#'
#' @param bbox numeric vector of 4 elements representing the coordinates of the
#'   bounding box. Values should be `c(xmin, ymin, xmax, ymax)`.
#' @param xmin,ymin,xmax,ymax alternatively, you can use these named parameters
#'   instead of `bbox`.
#'
#' @inheritParams sf::st_sf
#'
#' @return A [`sfc`][sf::st_sfc] object of class `POLYGON`.
#'
#' @seealso
#' [sf::st_as_sfc()] and [sf::st_sfc()].
#'
#'
#' @details
#' Bounding boxes can be located using different online tools, as [Bounding
#' Box Tool](https://boundingbox.klokantech.com/).
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#'
#' # bounding box of Germany
#' bbox_GER <- c(5.86631529, 47.27011137, 15.04193189, 55.09916098)
#'
#' bbox_GER_sf <- bbox_to_poly(bbox_GER)
#'
#'
#' library(ggplot2)
#'
#' ggplot(bbox_GER_sf) +
#'   geom_sf()
#' \donttest{
#' # Extract the bounding box of a sf object
#' sfobj <- geo_lite_sf("seychelles", points_only = FALSE)
#'
#' sfobj
#'
#' # Need at least one non-empty object
#' if (any(!sf::st_is_empty(sfobj))) {
#'   bbox <- sf::st_bbox(sfobj)
#'
#'   bbox
#'
#'   bbox_sfobj <- bbox_to_poly(bbox)
#'
#'   ggplot(bbox_sfobj) +
#'     geom_sf(fill = "lightblue", alpha = 0.5) +
#'     geom_sf(data = sfobj, fill = "wheat")
#' }
#' }
bbox_to_poly <- function(bbox = NA, xmin = NA, ymin = NA, xmax = NA, ymax = NA,
                         crs = 4326) {
  if (!anyNA(bbox) && length(bbox) != 4) {
    stop(
      "bbox argument needs 4 elements. Provided value has ",
      length(bbox)
    )
  }

  # If no bbox check x and y values
  if (anyNA(bbox)) {
    bbox <- as.double(c(xmin, ymin, xmax, ymax))

    if (anyNA(bbox)) {
      stop("xmin, ymin, xmax, ymax can't be NA, if bbox is not provided")
    }
  }

  bbox_double <- as.double(bbox)
  names(bbox_double) <- c("xmin", "ymin", "xmax", "ymax")
  class(bbox_double) <- "bbox"

  bbox_sf <- sf::st_as_sfc(bbox_double)
  sf::st_crs(bbox_sf) <- sf::st_crs(crs)

  return(bbox_sf)
}
