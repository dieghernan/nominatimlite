#' Address search API (structured query)
#'
#' @description
#' Searches for addresses already split into components and returns matching
#' results as a [tibble][dplyr::tibble]. Use [geo_lite_struct_sf()] to return
#' an [`sf`][sf::st_sf] object instead.
#'
#' This function performs the **structured address search** described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/). To
#' perform a free-form search, use [geo_lite()].
#'
#' @details
#' A structured address search accepts an address already split into components.
#' Each argument represents an address field. All components are optional, so
#' provide only those relevant to the address you want to find.
#'
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @param amenity Name or type of amenity. See [geo_amenity()].
#' @param street House number and street name.
#' @param city City.
#' @param county County.
#' @param state State.
#' @param country Country.
#' @param postalcode Postal code.
#' @inheritParams geo_lite
#' @inherit geo_lite return
#'
#' @inherit geo_lite seealso
#'
#' @family geocoding
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' pl_mayor <- geo_lite_struct(
#'   street = "Plaza Mayor", country = "Spain",
#'   limit = 50, full_results = TRUE
#' )
#'
#' dplyr::glimpse(pl_mayor)
#' }
geo_lite_struct <- function(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  limit <- cap_limit(limit)

  # Keep the first value of each parameter; this function is not vectorized.
  pars <- structured_query_params(
    amenity = amenity,
    street = street,
    city = city,
    county = county,
    state = state,
    country = country,
    postalcode = postalcode
  )
  tbl_query <- structured_query_tbl(pars)

  if (all(is.na(pars))) {
    message("No query parameters were provided.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  pars <- lapply(pars, encode_search_text)
  custom_query <- compact_query_options(c(pars, custom_query))
  url <- build_search_url(
    nominatim_server = nominatim_server,
    format = "jsonv2",
    limit = limit,
    full_results = full_results,
    custom_query = custom_query
  )

  # Download the API response.
  json <- api_call(url, ".json", isFALSE(verbose))

  if (isFALSE(json)) {
    message("Cannot reach the API endpoint: ", url, ".")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  result <- rename_coordinate_cols(result, lat, long)

  # Handle empty queries.
  if (nrow(result) == 0) {
    message("No results found for the query.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- convert_coordinate_cols(result, lat, long)

  # Add the structured query to the API results.
  result_clean <- dplyr::bind_cols(tbl_query[rep(1, nrow(result)), ], result)

  # Keep selected columns.
  result_out <- keep_names(
    result_clean,
    return_addresses,
    full_results,
    colstokeep = c(names(tbl_query), lat, long)
  )

  # Restore tibble classes.
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
