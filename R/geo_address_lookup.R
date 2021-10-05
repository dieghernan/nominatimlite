#' Query the address and other details of one or multiple OSM objects
#'
#' @description
#' Geocodes addresses for OSM objects, identified with the OSM Id.
#'
#' @param osm_ids vector of OSM identifiers (`c(00000, 11111, 22222)`).
#' @param type vector of the type of the OSM type associated to each `osm_ids`.
#'   Possible values are node ("N"), way ("W") or relation ("R"). If a single
#'   value is provided it would be recycled.#'
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @family geocoding
#' @family lookup
#'
#' @return A `tibble` with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' ids <- geo_address_lookup(
#'   osm_ids = c(46240148, 34633854),
#'   type = c("W"),
#' )
#'
#' ids
#' }
#' @export

geo_address_lookup <- function(osm_ids,
                               type,
                               lat = "lat",
                               long = "lon",
                               full_results = FALSE,
                               return_addresses = TRUE,
                               verbose = FALSE,
                               custom_query = list()) {
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

  # nocov start
  res <- tryCatch(
    download.file(url, json, mode = "wb", quiet = isFALSE(verbose)),
    warning = function(e) {
      return(NULL)
    },
    error = function(e) {
      return(NULL)
    }
  )

  if (is.null(res)) {
    message(url, " not reachable.", nodes)
    result_out <- tibble::tibble(query = paste0(type, osm_ids), a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(result_out)
  }
  # nocov end

  result <- tibble::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  if (nrow(result) > 0) {
    result$lat <- as.double(result$lat)
    result$lon <- as.double(result$lon)
  }
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  if (nrow(result) == 0) {
    message("No results for query ", nodes)
    result_out <- tibble::tibble(query = paste0(type, osm_ids), a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(result_out)
  }

  # Rename
  names(result) <- gsub("address.", "", names(result))
  names(result) <- gsub("namedetails.", "", names(result))
  names(result) <- gsub("display_name", "address", names(result))


  # Prepare output
  result_out <- tibble::tibble(query = paste0(type, osm_ids))


  # Output
  result_out <- cbind(result_out, result[lat], result[long])

  if (return_addresses || full_results) {
    disp_name <- result["address"]
    result_out <- cbind(result_out, disp_name)
  }


  # If full
  if (full_results) {
    rest_cols <- result[, !names(result) %in% c(long, lat, "address")]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <- tibble::as_tibble(result_out)

  return(result_out)
}
