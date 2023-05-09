#' Address Lookup API for OSM objects
#'
#' @description
#' The lookup API allows to query the address and other details of one or
#' multiple OSM objects like node, way or relation. This function returns the
#' `tibble` associated with the query, see [geo_address_lookup_sf()] for
#' retrieving the data as a spatial object ((\pkg{sf}) format).
#'
#' @param osm_ids vector of OSM identifiers as **numeric**
#'   (`c(00000, 11111, 22222)`).
#' @param type vector character of the type of the OSM type associated to each
#'   `osm_ids`. Possible values are node (`"N"`), way (`"W"`) or relation
#'   (`"R"`). If a single value is provided it would be recycled.
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @seealso [geo_address_lookup_sf()]
#' @family lookup
#' @family geocoding
#'
#' @return A `tibble` with the results found by the query.
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
#' @export

geo_address_lookup <- function(osm_ids,
                               type = c("N", "W", "R"),
                               lat = "lat",
                               long = "lon",
                               full_results = FALSE,
                               return_addresses = TRUE,
                               verbose = FALSE,
                               custom_query = list()) {
  # Step 1: Download ----
  api <- "https://nominatim.openstreetmap.org/lookup?"

  # Prepare nodes
  osm_ids <- as.integer(osm_ids)
  type <- as.character(type)
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose url
  url <- paste0(api, "osm_ids=", nodes, "&format=json")

  if (full_results) url <- paste0(url, "&addressdetails=1")

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- api_call(url, json, isFALSE(verbose))


  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids))

  # nocov start
  # If no response...
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }
  # nocov end
  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))


  # Rename lat and lon
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  # Empty query
  if (nrow(result) == 0) {
    message("No results for query ", nodes)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Coords as double
  result[lat] <- as.double(result[[lat]])
  result[long] <- as.double(result[[long]])


  # In this function we need to re-create tbl_query
  tbl_query <- dplyr::tibble(
    query = paste0(type, osm_ids),
    osm_id = osm_ids
  )

  # Keep only same results
  result_clean <- dplyr::inner_join(result, tbl_query, by = "osm_id")

  # Warning in lost rows
  if (all(nrow(result_clean) < nrow(tbl_query), verbose)) {
    warning("Some ids may not have produced results. Check the final object")
  }

  # Keep names
  result_out <- keep_names(result_clean, return_addresses, full_results,
    colstokeep = c("query", lat, long)
  )

  # As tibble
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
