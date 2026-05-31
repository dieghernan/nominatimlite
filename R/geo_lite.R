#' Address search API (free-form query)
#'
#' @description
#' Geocodes addresses given as character values and returns the
#' [`tibble`][tibble::tibble] associated with the query. See [geo_lite_sf()] for
#' retrieving the data as an [`sf`][sf::st_sf] object.
#'
#' Corresponds to the **free-form query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/).
#'
#' @family geocoding
#' @encoding UTF-8
#'
#' @param address `character` with a single-line address, for example
#'   `"1600 Pennsylvania Ave NW, Washington"`, or a vector of addresses
#'   (`c("Madrid", "Barcelona")`).
#' @param lat Latitude column name in the output data (default `"lat"`).
#' @param long Longitude column name in the output data (default `"long"`).
#' @param limit Maximum number of results to return per input address. Note
#'   that each query returns a maximum of 50 results.
#' @param full_results Return all available data from the Nominatim API.
#'   If `FALSE` (default), only latitude, longitude and address columns are
#'   returned. See also `return_addresses`.
#' @param return_addresses Return input addresses with results if `TRUE`.
#' @param verbose If `TRUE`, detailed logs are output to the console.
#' @param nominatim_server URL of the Nominatim server to use. Defaults to
#'   `"https://nominatim.openstreetmap.org/"`.
#' @param progressbar Logical. If `TRUE` displays a progress bar to indicate
#'   the progress of the function.
#' @param custom_query Named list with API-specific parameters, for example
#'   `list(countrycodes = "US")`. See **Details**.
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @return
#' A [`tibble`][tibble::tibble] with the results that match the query.
#'
#' @seealso
#' [tidygeocoder::geo()].
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' geo_lite("Madrid, Spain")
#'
#' # Several addresses
#' geo_lite(c("Madrid", "Barcelona"))
#'
#' # With options: restrict search to the United States
#' geo_lite(c("Madrid", "Barcelona"),
#'   custom_query = list(countrycodes = "US"),
#'   full_results = TRUE
#' )
#' }
geo_lite <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list()
) {
  limit <- cap_limit(limit)

  # Deduplicate queries before calling the API.
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  ntot <- length(key)

  all_res <- progress_lapply(ntot, progressbar, function(x) {
    ad <- key[x]
    geo_lite_single(
      address = ad,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      nominatim_server = nominatim_server,
      custom_query
    )
  })

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  all_res
}

#' @inheritParams geo_lite
#' @noRd

geo_lite_single <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = TRUE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  url <- build_search_url(
    nominatim_server = nominatim_server,
    format = "jsonv2",
    limit = limit,
    full_results = full_results,
    custom_query = custom_query,
    query = address
  )

  # Download the API response.
  json <- api_call(url, ".json", isFALSE(verbose))

  # Keep the original query value.
  tbl_query <- dplyr::tibble(query = address)

  if (isFALSE(json)) {
    message("API endpoint is not reachable: ", url, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  result <- rename_coordinate_cols(result, lat, long)

  # Handle empty queries.
  if (nrow(result) == 0) {
    message("No results for query ", address, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- convert_coordinate_cols(result, lat, long)

  # Add the query to the API results.
  result_clean <- result
  result_clean$query <- address

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
