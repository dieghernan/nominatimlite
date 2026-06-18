#' Address lookup API
#'
#' @description
#' Looks up addresses and other details for one or more OpenStreetMap (OSM)
#' objects, such as nodes, ways or relations. Results are returned as a
#' [tibble][dplyr::tibble]. Use [geo_address_lookup_sf()] to return an
#' [`sf`][sf::st_sf] object instead.
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @param osm_ids A numeric vector of OSM identifiers, for example
#'   `c(12345, 67890)`.
#' @param type Character vector of the OSM object type associated with each
#'   `osm_ids` value. Possible values are node (`"N"`), way (`"W"`) or
#'   relation (`"R"`). If a single value is provided, it will be recycled.
#'
#' @inheritParams geo_lite
#' @inherit geo_lite return
#'
#' @family lookup
#' @family geocoding
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' ids <- geo_address_lookup(osm_ids = c(46240148, 34633854), type = "W")
#'
#' ids
#'
#' several <- geo_address_lookup(c(146656, 240109189), type = c("R", "N"))
#' several
#' }
geo_address_lookup <- function(
  osm_ids,
  type = c("N", "W", "R"),
  lat = "lat",
  long = "lon",
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  # Prepare OSM object identifiers.
  osm_ids <- as.numeric(osm_ids)
  osm_ids <- floor(abs(osm_ids))
  type <- as.character(type)
  nodes <- paste0(type, osm_ids, collapse = ",")

  url <- build_lookup_url(
    nominatim_server = nominatim_server,
    nodes = nodes,
    full_results = full_results,
    custom_query = custom_query
  )

  # Download the API response.
  json <- api_call(url, ".json", isFALSE(verbose))

  # Keep the original query values.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids))

  # Handle missing responses.
  if (isFALSE(json)) {
    message("Cannot reach the API endpoint: ", url, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }
  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  result <- rename_coordinate_cols(result, lat, long)

  # Handle empty queries.
  if (nrow(result) == 0) {
    message("No results found for query: ", nodes, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- convert_coordinate_cols(result, lat, long)

  # Recreate `tbl_query` with normalized OSM IDs.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids), osm_id = osm_ids)

  # Keep only matched results.
  result_clean <- dplyr::inner_join(result, tbl_query, by = "osm_id")

  # Warn about lost rows.
  if (all(nrow(result_clean) < nrow(tbl_query), verbose)) {
    warning("Some OSM IDs returned no results. Check the output.")
  }

  # Keep selected columns.
  result_out <- keep_names(
    result_clean,
    return_addresses,
    full_results,
    colstokeep = c("query", lat, long)
  )

  # Restore tibble classes.
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
