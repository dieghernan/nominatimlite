#' Address lookup API with \CRANpkg{sf} output
#'
#' @description
#' Looks up addresses and other details for one or more OpenStreetMap (OSM)
#' objects, such as nodes, ways or relations. Results are returned as an
#' [`sf`][sf::st_sf] object using \CRANpkg{sf}. Use [geo_address_lookup()] to
#' return a [tibble][dplyr::tibble] instead.
#'
#' @inherit geo_address_lookup details
#'
#' @inheritSection geo_lite_sf About geometry types
#'
#' @param full_results If `TRUE`, return all available fields from the Nominatim
#'   API. If `FALSE`, return only query metadata, geometry and requested address
#'   columns.
#' @param points_only If `TRUE`, return only point geometries. If `FALSE`, the
#'   API may return other geometry types. See **About geometry types**.
#' @inheritParams geo_address_lookup
#' @inherit geo_lite_sf return
#'
#' @family lookup
#' @family geocoding
#' @family spatial
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Notre Dame Cathedral, Paris
#'
#' NotreDame <- geo_address_lookup_sf(osm_ids = 201611261, type = "W")
#'
#' # Require at least one non-empty object
#' if (!all(sf::st_is_empty(NotreDame))) {
#'   library(ggplot2)
#'
#'   ggplot(NotreDame) +
#'     geom_sf()
#' }
#'
#' NotreDame_poly <- geo_address_lookup_sf(201611261,
#'   type = "W",
#'   points_only = FALSE
#' )
#'
#' if (!all(sf::st_is_empty(NotreDame_poly))) {
#'   ggplot(NotreDame_poly) +
#'     geom_sf()
#' }
#'
#' # Vectorized input
#'
#' several <- geo_address_lookup_sf(c(146656, 240109189), type = c("R", "N"))
#' several
#' }
geo_address_lookup_sf <- function(
  osm_ids,
  type = c("N", "W", "R"),
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
) {
  # Build the API address.
  api <- prepare_api_url(nominatim_server, "lookup?")

  # Prepare OSM object identifiers.
  osm_ids <- as.numeric(osm_ids)
  osm_ids <- floor(abs(osm_ids))
  type <- as.character(type)
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose the lookup URL.
  url <- paste0(api, "osm_ids=", nodes, "&format=geojson")

  if (!isTRUE(points_only)) {
    url <- paste0(url, "&polygon_geojson=1")
  }
  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  # Add custom query options.
  url <- add_custom_query(custom_query, url)

  # Download the API response.
  json <- api_call(url, ".geojson", quiet = isFALSE(verbose))

  # Keep the original query values.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids))

  # Handle missing responses.
  if (isFALSE(json)) {
    message("Cannot reach the API endpoint: ", url, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message("No results found for query: ", nodes, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Unnest address fields.
  sfobj <- unnest_sf(sfobj)

  # Recreate `tbl_query` with normalized OSM IDs.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids), osm_id = osm_ids)

  # Keep only matched results.
  sf_clean <- dplyr::inner_join(sfobj, tbl_query, by = "osm_id")

  # Warn about lost rows.
  if (all(nrow(sf_clean) < nrow(tbl_query), verbose)) {
    warning("Some OSM IDs returned no results. Check the output.")
  }

  # Keep selected columns.
  result_out <- keep_names(
    sf_clean,
    return_addresses,
    full_results,
    colstokeep = "query"
  )

  # Restore tibble classes.
  result_out <- sf_to_tbl(result_out)

  result_out
}
