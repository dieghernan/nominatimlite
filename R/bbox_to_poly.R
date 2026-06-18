#' Convert a bounding box to an [`sfc`][sf::st_sfc] `POLYGON` object
#'
#' @description
#' Converts bounding box coordinates to an [`sfc`][sf::st_sfc] object with
#' `POLYGON` geometry.
#'
#' @details
#' Bounding boxes can be located using online tools such as
#' <https://boundingbox.klokantech.com/>.
#'
#' @param bbox A numeric vector of four bounding box coordinates in the form
#'   `c(xmin, ymin, xmax, ymax)`.
#' @param xmin,ymin,xmax,ymax Individual bounding box coordinates. Use these
#'   arguments as an alternative to `bbox`.
#' @inheritParams sf::st_sf crs
#'
#' @returns
#' An [`sfc`][sf::st_sfc] object with `POLYGON` geometry and the coordinate
#' reference system specified by `crs`.
#'
#' @seealso
#' [sf::st_as_sfc()] and [sf::st_sfc()].
#'
#' @family spatial
#'
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#'
#' # Bounding box for Germany
#' bbox_GER <- c(5.86631529, 47.27011137, 15.04193189, 55.09916098)
#'
#' bbox_GER_sf <- bbox_to_poly(bbox_GER)
#'
#' library(ggplot2)
#'
#' ggplot(bbox_GER_sf) +
#'   geom_sf()
#' \donttest{
#' # Extract the bounding box of an `sf` object
#' sfobj <- geo_lite_sf("seychelles", points_only = FALSE)
#'
#' sfobj
#'
#' # Require at least one non-empty object
#' if (!all(sf::st_is_empty(sfobj))) {
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
bbox_to_poly <- function(
  bbox = NA,
  xmin = NA,
  ymin = NA,
  xmax = NA,
  ymax = NA,
  crs = 4326
) {
  if (!anyNA(bbox) && length(bbox) != 4) {
    stop(
      "`bbox` must contain exactly four elements, but the provided value has ",
      length(bbox),
      "."
    )
  }

  # Use explicit x and y values when `bbox` is missing.
  if (anyNA(bbox)) {
    bbox <- as.double(c(xmin, ymin, xmax, ymax))

    if (anyNA(bbox)) {
      stop(
        "Provide `bbox` or non-missing values for `xmin`, `ymin`, `xmax` ",
        "and `ymax`."
      )
    }
  }

  bbox_double <- as.double(bbox)
  names(bbox_double) <- c("xmin", "ymin", "xmax", "ymax")
  class(bbox_double) <- "bbox"

  bbox_sf <- sf::st_as_sfc(bbox_double)
  sf::st_crs(bbox_sf) <- sf::st_crs(crs)

  bbox_sf
}
