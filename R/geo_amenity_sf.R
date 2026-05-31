#' Geocode amenities with \CRANpkg{sf} output
#'
#' @description
#' Searches [amenities][osm_amenities] as defined by OpenStreetMap in a
#' restricted area defined by a bounding box in the form
#' `(<xmin>, <ymin>, <xmax>, <ymax>)` and returns the [`sf`][sf::st_sf]
#' object associated with the query using \CRANpkg{sf}. See [geo_amenity()] for
#' retrieving the data in [`tibble`][tibble::tibble] format.
#'
#' @family amenity
#' @family geocoding
#' @family spatial
#' @encoding UTF-8
#'
#' @inheritParams geo_amenity
#' @inheritParams geo_lite_sf
#' @inherit geo_lite_sf return
#'
#' @details
#' Bounding boxes can be located using online tools such as
#' <https://boundingbox.klokantech.com/>.
#'
#' For a full list of valid amenities, see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity> and [osm_amenities].
#'
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @inheritSection geo_lite_sf About geometry types
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Usera, Madrid
#'
#' library(ggplot2)
#' mad <- geo_lite_sf("Usera, Madrid, Spain", points_only = FALSE)
#'
#' # Restaurants, pubs and schools
#'
#' rest_pub <- geo_amenity_sf(mad, c("restaurant", "pub", "school"),
#'   limit = 50
#' )
#'
#' if (!all(sf::st_is_empty(rest_pub))) {
#'   ggplot(mad) +
#'     geom_sf() +
#'     geom_sf(data = rest_pub, aes(color = query, shape = query))
#' }
#' }
geo_amenity_sf <- function(
  bbox,
  amenity,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE,
  points_only = TRUE
) {
  limit <- cap_limit(limit)

  bbox <- normalize_bbox(bbox)

  # Add the viewbox restriction to the custom query.
  custom_query <- as.list(custom_query)
  custom_query$viewbox <- bbox
  custom_query$bounded <- TRUE

  # Deduplicate queries.
  key <- unique(amenity)

  ntot <- length(key)

  all_res <- progress_lapply(ntot, progressbar, function(x) {
    ad <- key[x]

    geo_lite_struct_sf(
      amenity = ad,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query,
      points_only = points_only
    )
  })

  all_res <- dplyr::bind_rows(all_res)

  # Clean query columns and names.
  nm <- names(all_res)
  nm[nm == "q_amenity"] <- "query"
  names(all_res) <- nm
  all_res <- all_res[, !grepl("^q_", nm)]
  all_res <- sf_to_tbl(all_res)

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    int <- as.vector(sf::st_intersects(all_res, bbox_sf, sparse = FALSE))
    all_res <- all_res[int, ]
  }

  all_res
}
