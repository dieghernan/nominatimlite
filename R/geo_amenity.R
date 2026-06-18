#' Look up amenities
#'
#' @description
#' Looks up OpenStreetMap [amenities][osm_amenities] within a bounding box of
#' the form `(xmin, ymin, xmax, ymax)`. Results are returned as a
#' [tibble][dplyr::tibble]. Use [geo_amenity_sf()] to return an
#' [`sf`][sf::st_sf] object instead.
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
#' @param bbox Bounding box (viewbox) used to limit the search. It can be
#'   a numeric vector of **longitude** (`x`) and **latitude** (`y`) in the form
#'   `(xmin, ymin, xmax, ymax)`, or a [`sf`][sf::st_sf] or
#'   [`sfc`][sf::st_sfc] object. See **Details**.
#' @param amenity A character vector of amenities to look up,
#'   for example `c("pub", "restaurant")`. See [osm_amenities].
#' @param strict If `TRUE`, keep only results inside `bbox`. By default,
#'   Nominatim may return results outside the bounding box.
#' @inheritParams geo_lite
#' @inherit geo_lite return
#'
#' @family amenity
#' @family geocoding
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Times Square, NY, USA
#' bbox <- c(
#'   -73.9894467311, 40.75573629,
#'   -73.9830630737, 40.75789245
#' )
#'
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = "restaurant"
#' )
#'
#' # Multiple amenities
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = c("restaurant", "pub")
#' )
#'
#' # Increase `limit` and use strict filtering
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = c("restaurant", "pub"),
#'   limit = 10,
#'   strict = TRUE
#' )
#' }
geo_amenity <- function(
  bbox,
  amenity,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE
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

    geo_lite_struct(
      amenity = ad,
      lat = lat,
      long = long,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query
    )
  })

  all_res <- dplyr::bind_rows(all_res)

  # Clean query columns and names.
  nm <- names(all_res)
  nm[nm == "q_amenity"] <- "query"
  names(all_res) <- nm
  all_res <- all_res[, !grepl("^q_", nm)]

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    all_res_sf <- sf::st_as_sf(all_res, coords = c("lon", "lat"), crs = 4326)

    int <- as.vector(sf::st_intersects(all_res_sf, bbox_sf, sparse = FALSE))
    all_res <- all_res[int, ]
  }

  all_res
}
