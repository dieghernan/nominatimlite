#' Address search API (free-form query)
#'
#' @description
#' Searches for addresses supplied as a character vector and returns matching
#' results as a [tibble][dplyr::tibble]. Use [geo_lite_sf()] to return an
#' [`sf`][sf::st_sf] object instead.
#'
#' This function performs the **free-form address search** described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/).
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @param address A character vector of single-line addresses, for example
#'   `"1600 Pennsylvania Ave NW, Washington"` or
#'   `c("Madrid", "Barcelona")`.
#' @param lat A string giving the name of the latitude column in the output.
#'   Defaults to `"lat"`.
#' @param long A string giving the name of the longitude column in the output.
#'   Defaults to `"lon"`.
#' @param limit A positive integer giving the maximum number of results to
#'   return per query. Nominatim returns at most 50 results per query.
#' @param full_results If `TRUE`, return all available fields from the Nominatim
#'   API. If `FALSE`, return only query metadata, location data and requested
#'   address columns.
#' @param return_addresses If `TRUE`, include single-line addresses in the
#'   results.
#' @param verbose If `TRUE`, displays detailed messages in the console.
#' @param nominatim_server A string giving the base URL of the Nominatim
#'   server. Defaults to
#'   `"https://nominatim.openstreetmap.org/"`.
#' @param progressbar If `TRUE`, displays a progress bar when processing
#'   multiple queries.
#' @param custom_query A named list of additional API parameters, for example
#'   `list(countrycodes = "US")`. See **Details**.
#'
#' @returns
#' A [`tibble`][dplyr::tibble] with the results that match the query.
#'
#' @family geocoding
#'
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' geo_lite("Madrid, Spain")
#'
#' # Multiple addresses
#' geo_lite(c("Madrid", "Barcelona"))
#'
#' # Restrict the search to the United States and return all fields
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
    message_api_unavailable(url)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  result <- rename_coordinate_cols(result, lat, long)

  # Handle empty queries.
  if (nrow(result) == 0) {
    message_no_results(address)
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
