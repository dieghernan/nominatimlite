#' Reverse geocoding API
#'
#' @description
#' Finds addresses from latitude and longitude coordinates and returns the
#' matching results as a [tibble][dplyr::tibble]. Latitudes must be in
#' \eqn{\left[-90, 90 \right]} and longitudes in
#' \eqn{\left[-180, 180 \right]}. Use [reverse_geo_lite_sf()] to return an
#' [`sf`][sf::st_sf] object instead.
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Reverse/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @section About zooming:
#'
#' Set `custom_query = list(zoom = 3)` to adjust the output. Selected zoom
#' levels correspond to these address details:
#'
#' ```{r, echo=FALSE}
#'
#' t <- dplyr::tribble(
#'  ~zoom, ~address_detail,
#'  "`3`", "country",
#'  "`5`", "state",
#'  "`8`", "county",
#'  "`10`", "city",
#'  "`14`", "suburb",
#'  "`16`", "major streets",
#'  "`17`", "major and minor streets",
#'  "`18`", "building"
#'  )
#'
#' knitr::kable(t, col.names = paste0("**", names(t), "**"))
#'
#' @param lat Numeric latitude values in the range
#'   \eqn{\left[-90, 90 \right]}.
#' @param long Numeric longitude values in the range
#'   \eqn{\left[-180, 180 \right]}.
#' @param address Name of the address column in the output. Defaults to
#'   `"address"`.
#' @param return_coords Return input coordinates with results if `TRUE`.
#' @param custom_query A named list of API-specific parameters, for example
#'   `list(zoom = 3)`. See **Details**.
#'
#' @inheritParams geo_lite
#' @inherit geo_lite return
#'
#' @family reverse
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#'
#' reverse_geo_lite(lat = 40.75728, long = -73.98586)
#'
#' # Multiple coordinate pairs
#' reverse_geo_lite(lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375))
#'
#' # Set the zoom to country level
#' sev <- reverse_geo_lite(
#'   lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375),
#'   custom_query = list(zoom = 0, extratags = TRUE),
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
reverse_geo_lite <- function(
  lat,
  long,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list()
) {
  keys <- reverse_query_keys(lat, long)
  all_res <- run_reverse_queries(
    keys$unique,
    progressbar,
    function(lat_cap, long_cap) {
      reverse_geo_lite_single(
        lat_cap = lat_cap,
        long_cap = long_cap,
        address = address,
        full_results = full_results,
        return_coords = return_coords,
        verbose = verbose,
        custom_query = custom_query,
        nominatim_server = nominatim_server
      )
    }
  )

  all_res <- dplyr::left_join(
    keys$init[, c(1, 2)],
    all_res,
    by = c("lat_key_int", "long_key_int")
  )

  # Remove internal join keys.
  all_res <- all_res[, -c(1, 2)]
  all_res
}

#' @inheritParams reverse_geo_lite
#' @noRd
reverse_geo_lite_single <- function(
  lat_cap,
  long_cap,
  address = "address",
  full_results = FALSE,
  return_coords = TRUE,
  verbose = TRUE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  url <- build_reverse_url(
    nominatim_server = nominatim_server,
    lat = lat_cap,
    long = long_cap,
    format = "jsonv2",
    full_results = full_results,
    custom_query = custom_query
  )

  # Download the API response.
  json <- api_call(url, ".json", isFALSE(verbose))

  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)

  if (isFALSE(json)) {
    message("Cannot reach the API endpoint: ", url, ".")
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Handle empty queries.
  if ("error" %in% names(result_init)) {
    message(
      "No results found for query: lat = ",
      lat_cap,
      ", long = ",
      long_cap,
      "."
    )
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }

  # Unnest nested fields.
  result <- unnest_reverse(result_init)

  result$lat <- as.double(result$lat)
  result$lon <- as.double(result$lon)

  # Keep selected columns.
  result_out <- keep_names_rev(
    result,
    address = address,
    return_coords = return_coords,
    full_results = full_results
  )

  result_out
}
