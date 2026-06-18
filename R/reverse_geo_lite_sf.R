#' Reverse geocoding API with \CRANpkg{sf} output
#'
#' @description
#' Finds addresses from latitude and longitude coordinates and returns the
#' matching results as an [`sf`][sf::st_sf] object. Latitude values must be in
#' \eqn{\left[-90, 90 \right]} and longitude values in
#' \eqn{\left[-180, 180 \right]}. Use [reverse_geo_lite()] to return a
#' [tibble][dplyr::tibble] instead.
#'
#' @inherit reverse_geo_lite details
#'
#' @inheritSection reverse_geo_lite About zooming
#' @inheritSection geo_lite_sf About geometry types
#'
#' @param full_results If `TRUE`, return all available fields from the Nominatim
#'   API. If `FALSE`, return only query metadata, geometry and requested address
#'   columns.
#' @param points_only If `TRUE`, return only point geometries. If `FALSE`, the
#'   API may return other geometry types. See **About geometry types**.
#' @inheritParams reverse_geo_lite
#'
#' @inherit geo_lite_sf return
#'
#' @inherit reverse_geo_lite seealso
#'
#' @family reverse
#' @family spatial
#'
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' library(ggplot2)
#'
#' # Colosseum coordinates
#' col_lon <- 12.49309
#' col_lat <- 41.89026
#'
#' # Colosseum as a polygon
#' col_sf <- reverse_geo_lite_sf(
#'   lat = col_lat,
#'   long = col_lon,
#'   points_only = FALSE
#' )
#'
#' dplyr::glimpse(col_sf)
#'
#' if (!all(sf::st_is_empty(col_sf))) {
#'   ggplot(col_sf) +
#'     geom_sf()
#' }
#'
#' # City of Rome: same coordinates with zoom 10
#'
#' rome_sf <- reverse_geo_lite_sf(
#'   lat = col_lat,
#'   long = col_lon,
#'   custom_query = list(zoom = 10),
#'   points_only = FALSE
#' )
#'
#' dplyr::glimpse(rome_sf)
#'
#' if (!all(sf::st_is_empty(rome_sf))) {
#'   ggplot(rome_sf) +
#'     geom_sf()
#' }
#' }
reverse_geo_lite_sf <- function(
  lat,
  long,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  points_only = TRUE
) {
  keys <- reverse_query_keys(lat, long)
  all_res <- run_reverse_queries(
    keys$unique,
    progressbar,
    function(lat_cap, long_cap) {
      reverse_geo_lite_sf_single(
        lat_cap = lat_cap,
        long_cap = long_cap,
        address = address,
        full_results = full_results,
        return_coords = return_coords,
        verbose = verbose,
        custom_query = custom_query,
        points_only = points_only,
        nominatim_server = nominatim_server
      )
    }
  )

  # Restore duplicate inputs in `sf` output.
  if (!identical(nrow(keys$init), nrow(all_res))) {
    # Join with row indexes.
    tmplt <- sf::st_drop_geometry(all_res)[, c("lat_key_int", "long_key_int")]
    tmplt$rindex <- seq_len(nrow(tmplt))
    getrows <- dplyr::left_join(
      keys$init,
      tmplt,
      by = c("lat_key_int", "long_key_int")
    )

    # Restore the original row order.
    all_res <- all_res[as.double(getrows$rindex), ]
  }

  # Remove internal join keys.
  kpnms <- setdiff(names(all_res), c("lat_key_int", "long_key_int"))

  all_res <- all_res[, kpnms]

  all_res <- sf_to_tbl(all_res)

  all_res
}
#' @inheritParams reverse_geo_lite_sf
#' @noRd
reverse_geo_lite_sf_single <- function(
  lat_cap,
  long_cap,
  address = "address",
  full_results = TRUE,
  return_coords = TRUE,
  verbose = TRUE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = FALSE
) {
  url <- build_reverse_url(
    nominatim_server = nominatim_server,
    lat = lat_cap,
    long = long_cap,
    format = "geojson",
    full_results = full_results,
    custom_query = custom_query,
    points_only = points_only
  )

  # Download the API response.
  json <- api_call(url, ".geojson", isFALSE(verbose))

  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)

  if (isFALSE(json)) {
    message_api_unavailable(url)
    out <- empty_sf(empty_tbl_rev(tbl_query, address))
    return(invisible(out))
  }

  # Handle empty queries.
  result_init <- jsonlite::fromJSON(json, flatten = TRUE)
  if ("error" %in% names(result_init)) {
    message_no_results(paste0("lat = ", lat_cap, ", long = ", long_cap))
    out <- empty_sf(empty_tbl_rev(tbl_query, address))
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Unnest nested fields.
  sfobj <- unnest_sf_reverse(sfobj)

  # Add latitude and longitude.
  sf_clean <- dplyr::bind_cols(sfobj, tbl_query)

  # Keep selected columns.
  result_out <- keep_names_rev(sf_clean, address, return_coords, full_results)

  # Restore tibble classes.
  result_out <- sf_to_tbl(result_out)

  result_out
}
