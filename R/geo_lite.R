#' Address Search API for OSM objects
#'
#' @description
#' Geocodes addresses given as character values. This
#' function returns the data associated with the query, see [geo_lite_sf()]
#' for retrieving the data as a spatial object (`sf` format).
#'
#' @param address character with single line address
#'   (`"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
#'   (`c("Madrid", "Barcelona")`).
#' @param lat	latitude column name (i.e. `"lat"`).
#' @param long	longitude column name (i.e. `"long"`).
#' @param limit	maximum number of results to return per input address. Note
#'   that each query returns a maximum of 50 results.
#' @param full_results returns all available data from the API service.
#'    If `FALSE` (default) only latitude, longitude and address columns are
#'    returned. See also `return_addresses`.
#' @param return_addresses return input addresses with results if `TRUE`.
#' @param verbose if `TRUE` then detailed logs are output to the console.
#' @param custom_query A named list with API-specific parameters to be used
#'   (i.e. `list(countrycodes = "US")`). See **Details**.
#'
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @return A `tibble` with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' geo_lite("Madrid, Spain")
#'
#' # Several addresses
#' geo_lite(c("Madrid", "Barcelona"))
#'
#' # With options: restrict search to USA
#' geo_lite(c("Madrid", "Barcelona"),
#'   custom_query = list(countrycodes = "US"),
#'   full_results = TRUE
#' )
#' }
#' @export
#'
#' @seealso [geo_lite_sf()], [tidygeocoder::geo()]
#' @family geocoding
geo_lite <- function(address,
                     lat = "lat",
                     long = "lon",
                     limit = 1,
                     full_results = FALSE,
                     return_addresses = TRUE,
                     verbose = FALSE,
                     custom_query = list()) {
  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))

    limit <- min(50, limit)
  }



  # Dedupe for query
  init_ad <- dplyr::tibble(query = address)
  address <- unique(address)

  all_res <- lapply(address, function(x) {
    geo_lite_single(
      address = x,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query
    )
  })

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_ad, all_res, by = "query")

  return(all_res)
}

#' @noRd
#' @inheritParams geo_lite

geo_lite_single <- function(address,
                            lat = "lat",
                            long = "lon",
                            limit = 1,
                            full_results = TRUE,
                            return_addresses = TRUE,
                            verbose = FALSE,
                            custom_query = list()) {
  api <- "https://nominatim.openstreetmap.org/search?q="

  # Replace spaces with +
  address2 <- gsub(" ", "+", address)

  # Compose url
  url <- paste0(api, address2, "&format=json&limit=", limit)

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

  res <- api_call(url, json, quiet = isFALSE(verbose))

  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- dplyr::tibble(query = address, a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(invisible(result_out))
  }
  # nocov end


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
    message("No results for query ", address)
    result_out <- dplyr::tibble(query = address, a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(invisible(result_out))
  }

  # More renames
  names(result) <- gsub("address.", "", names(result))
  names(result) <- gsub("namedetails.", "", names(result))
  names(result) <- gsub("display_name", "address", names(result))

  result$query <- address


  # Output cols
  out_cols <- c("query", lat, long)

  if (return_addresses) out_cols <- c(out_cols, "address")
  if (full_results) out_cols <- c(out_cols, "address", names(result))

  out_cols <- unique(out_cols)

  result_out <- dplyr::as_tibble(result[, out_cols])

  return(result_out)
}
