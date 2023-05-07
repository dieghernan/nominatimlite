#' Address Lookup API for OSM objects
#'
#' @description
#' The lookup API allows to query the address and other details of one or
#' multiple OSM objects like node, way or relation. This function returns the
#' data associated with the query, see [geo_address_lookup_sf()] for
#' retrieving the data as a spatial object.
#'
#' @param osm_ids vector of OSM identifiers (`c(00000, 11111, 22222)`).
#' @param type vector of the type of the OSM type associated to each `osm_ids`.
#'   Possible values are node (`"N"`), way (`"W"`) or relation (`"R"`). If a
#'   single value is provided it would be recycled.
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @family geocoding
#' @family lookup
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
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose url
  url <- paste0(api, "osm_ids=", nodes, "&format=json")

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  if (length(custom_query) > 0) {
    opts <- NULL
    for (i in seq_len(length(custom_query))) {
      nlist <- names(custom_query)[i]
      val <- paste0(custom_query[[i]], collapse = ",")


      opts <- paste0(opts, "&", nlist, "=", val)
    }

    url <- paste0(url, "&", opts)
  }

  # Download

  json <- tempfile(fileext = ".json")

  res <- api_call(url, json, isFALSE(verbose))


  # Step 2: Read and parse results ----

  # If no response...
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- dplyr::tibble(query = paste0(type, osm_ids), a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(invisible(result_out))
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  if (nrow(result) > 0) {
    result$lat <- as.double(result$lat)
    result$lon <- as.double(result$lon)
  }
  # Renamings
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  # Empty query
  if (nrow(result) == 0) {
    message("No results for query ", nodes)
    result_out <- dplyr::tibble(query = paste0(type, osm_ids), a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(invisible(result_out))
  }

  # More renames
  names(result) <- gsub("address.", "", names(result))
  names(result) <- gsub("namedetails.", "", names(result))
  names(result) <- gsub("display_name", "address", names(result))


  # Final output
  res_templ <- dplyr::tibble(
    query = paste0(type, osm_ids),
    osm_id = osm_ids
  )


  result_out <- dplyr::inner_join(res_templ, result, by = "osm_id")


  # Warning in lost rows
  if (all(nrow(result_out) < nrow(res_templ), verbose)) {
    warning("Some ids may not have produced results. Check the final object")
  }


  # Output cols
  out_cols <- c("query", lat, long)

  if (return_addresses) out_cols <- c(out_cols, "address")
  if (full_results) out_cols <- c(out_cols, "address", names(result))

  out_cols <- unique(out_cols)

  result_out <- dplyr::as_tibble(result_out[, out_cols])

  return(result_out)
}
