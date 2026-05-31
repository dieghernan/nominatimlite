#' Address search API with \CRANpkg{sf} output (free-form query)
#'
#' @description
#' Geocodes addresses and returns the corresponding [`sf`][sf::st_sf] object.
#' The query output is returned as an \CRANpkg{sf} object. See [geo_lite()] for
#' retrieving the data in [`tibble`][tibble::tibble] format.
#'
#' Corresponds to the **free-form query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/).
#'
#' @family geocoding
#' @family spatial
#' @encoding UTF-8
#'
#' @param full_results Return all available data from the Nominatim API.
#'   If `FALSE` (default), only address columns are returned. See also
#'   `return_addresses`.
#' @param points_only Logical `TRUE/FALSE`. Whether to return only point
#'   geometries (`TRUE`, which is the default) or potentially other shapes as
#'   returned by the Nominatim API (`FALSE`). See **About geometry types**.
#'
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @section About geometry types:
#'
#' The parameter `points_only` specifies whether the function results will be
#' points (all Nominatim results are guaranteed to have at least point
#' geometry) or other geometry types.
#'
#' Note that when `points_only = FALSE`, the type of geometry returned depends
#' on the object being geocoded. Administrative areas, major buildings and the
#' like will be returned as polygons, rivers, roads and similar features will
#' be returned as lines, and amenities may still be returned as points.
#'
#' This function is vectorized, allowing multiple addresses to be geocoded.
#' With `points_only = FALSE`, multiple geometry types may be returned.
#'
#' @return
#' An [`sf`][sf::st_sf] object with the results that match the query.
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Map: points
#' library(ggplot2)
#'
#' string <- "Statue of Liberty, NY, USA"
#' sol <- geo_lite_sf(string)
#'
#' if (!all(sf::st_is_empty(sol))) {
#'   ggplot(sol) +
#'     geom_sf()
#' }
#'
#' sol_poly <- geo_lite_sf(string, points_only = FALSE)
#'
#' if (!all(sf::st_is_empty(sol_poly))) {
#'   ggplot(sol_poly) +
#'     geom_sf() +
#'     geom_sf(data = sol, color = "red")
#' }
#' # Several results
#'
#' madrid <- geo_lite_sf("Comunidad de Madrid, Spain",
#'   limit = 2,
#'   points_only = FALSE, full_results = TRUE
#' )
#'
#' if (!all(sf::st_is_empty(madrid))) {
#'   ggplot(madrid) +
#'     geom_sf(fill = NA)
#' }
#' }
geo_lite_sf <- function(
  address,
  limit = 1,
  return_addresses = TRUE,
  full_results = FALSE,
  verbose = FALSE,
  progressbar = TRUE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
) {
  limit <- cap_limit(limit)

  # Deduplicate queries before calling the API.
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  ntot <- length(key)

  # Run one request per unique query.
  all_res <- progress_lapply(ntot, progressbar, function(x) {
    ad <- key[x]
    geo_lite_sf_single(
      address = ad,
      limit,
      return_addresses,
      full_results,
      verbose,
      custom_query,
      points_only,
      nominatim_server = nominatim_server
    )
  })

  all_res <- dplyr::bind_rows(all_res)

  all_res <- sf_to_tbl(all_res)

  # Restore duplicate inputs in `sf` output.
  if (!identical(as.character(init_key$query), key)) {
    # Join with row indexes.
    template <- sf::st_drop_geometry(all_res)[, "query"]
    template$rindex <- seq_len(nrow(template))
    getrows <- dplyr::left_join(init_key, template, by = "query")

    # Restore the original row order.
    all_res <- all_res[as.double(getrows$rindex), ]
    all_res <- sf_to_tbl(all_res)
  }

  all_res
}

#' @inheritParams geo_lite
#' @noRd

geo_lite_sf_single <- function(
  address,
  limit = 1,
  return_addresses = TRUE,
  full_results = FALSE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
) {
  url <- build_search_url(
    nominatim_server = nominatim_server,
    format = "geojson",
    limit = limit,
    full_results = full_results,
    custom_query = custom_query,
    query = address,
    points_only = points_only
  )

  # Download the API response.
  json <- api_call(url, ".geojson", isFALSE(verbose))

  # Keep the original query value.
  tbl_query <- dplyr::tibble(query = address)

  if (isFALSE(json)) {
    message("API endpoint is not reachable: ", url, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message("No results for query ", address, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Unnest nested fields.
  sfobj <- unnest_sf(sfobj)

  # Add the query to the API results.
  sf_clean <- sfobj
  sf_clean$query <- address

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
