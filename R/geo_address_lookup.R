#' Address lookup API
#'
#' @description
#' The lookup API queries the address and other details of one or more
#' OSM objects (node, way, relation) and returns the
#' [`tibble`][tibble::tibble] associated with the query; see
#' [geo_address_lookup_sf()] for retrieving the data as a spatial object
#' ([`sf`][sf::st_sf] format).
#'
#' @family lookup
#' @family geocoding
#' @encoding UTF-8
#'
#' @param osm_ids Vector of OSM identifiers as numeric values
#'   (`c(00000, 11111, 22222)`).
#' @param type Character vector of the OSM object type associated with each
#'   `osm_ids` value. Possible values are node (`"N"`), way (`"W"`) or
#'   relation (`"R"`). If a single value is provided it will be recycled.
#'
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @seealso
#' [geo_address_lookup_sf()].
#'
#' @return
#'
#' ```{r child = "man/chunks/tibbleout.Rmd"}
#' ```
#'
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
  # Step 1: Download ----
  # Build the API address and ensure that the server URL has one trailing slash.
  api <- prepare_api_url(nominatim_server, "lookup?")

  # Prepare nodes.
  osm_ids <- as.numeric(osm_ids)
  osm_ids <- floor(abs(osm_ids))
  type <- as.character(type)
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose the URL.
  url <- paste0(api, "osm_ids=", nodes, "&format=jsonv2")

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  # Add options.
  url <- add_custom_query(custom_query, url)

  # Download to a temporary file.
  json <- api_call(url, ".json", isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tibble with the query.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids))

  # Handle missing responses.
  if (isFALSE(json)) {
    message(url, " is not reachable.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }
  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  # Rename latitude and longitude columns.
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  # Handle empty queries.
  if (nrow(result) == 0) {
    message("No results for query ", nodes, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Convert coordinates to double.
  result[lat] <- as.double(result[[lat]])
  result[long] <- as.double(result[[long]])

  # Re-create `tbl_query` with normalized OSM IDs.
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids), osm_id = osm_ids)

  # Keep only matched results.
  result_clean <- dplyr::inner_join(result, tbl_query, by = "osm_id")

  # Warn about lost rows.
  if (all(nrow(result_clean) < nrow(tbl_query), verbose)) {
    warning("Some IDs may not have produced results. Check the final object.")
  }

  # Keep selected names.
  result_out <- keep_names(
    result_clean,
    return_addresses,
    full_results,
    colstokeep = c("query", lat, long)
  )

  # Convert to tibble.
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
