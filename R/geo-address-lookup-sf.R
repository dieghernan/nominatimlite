#' Look up OpenStreetMap objects and return \CRANpkg{sf} objects
#'
#' @description
#' Looks up addresses and other details for one or more OpenStreetMap (OSM)
#' objects, such as nodes, ways or relations. Results are returned as an
#' [`sf`][sf::st_sf] object. Use [geo_address_lookup()] to return a
#' [tibble][dplyr::tibble] instead.
#'
#' @inherit geo_address_lookup details
#'
#' @inheritParams geo_address_lookup -full_results
#' @inheritParams geo_lite_sf full_results points_only
#'
#' @inherit geo_lite_sf return
#'
#' @inheritSection geo_lite_sf About geometry types
#'
#' @family lookup
#' @family spatial
#'
#' @export
#' @encoding UTF-8
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Look up Notre-Dame Cathedral in Paris.
#'
#' NotreDame <- geo_address_lookup_sf(osm_ids = 201611261, type = "W")
#'
#' # Require at least one non-empty object.
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
#' # Look up multiple OSM objects.
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
    message_api_unavailable(url)
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message_no_results(nodes)
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
    missing_ids <- setdiff(tbl_query$query, sf_clean$query)
    warning(paste0(
      "No results were found for the following OSM IDs: ",
      paste(missing_ids, collapse = ", "),
      ". The output contains only matched IDs."
    ))
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
