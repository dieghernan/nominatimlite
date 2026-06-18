#' Address search API with \CRANpkg{sf} output (free-form query)
#'
#' @description
#' Searches for addresses and returns matching results as an
#' [`sf`][sf::st_sf] object. Use [geo_lite()] to return a
#' [tibble][dplyr::tibble] instead.
#'
#' This function performs the **free-form address search** described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/).
#'
#' @inherit geo_lite details
#'
#' @section About geometry types:
#'
#' The `points_only` argument controls whether the results contain only points.
#' All Nominatim results have at least a point geometry.
#'
#' When `points_only = FALSE`, the geometry type depends on the matching
#' feature. Administrative areas and major buildings are returned as polygons,
#' rivers and roads are returned as lines and amenities may still be returned
#' as points.
#'
#' This function is vectorized, allowing multiple addresses to be searched.
#' With `points_only = FALSE`, multiple geometry types may be returned.
#'
#' @param full_results If `TRUE`, return all available fields from the Nominatim
#'   API. If `FALSE`, return only query metadata, geometry and requested address
#'   columns.
#' @param points_only If `TRUE`, return only point geometries. If `FALSE`, the
#'   API may return other geometry types. See **About geometry types**.
#' @inheritParams geo_lite
#'
#' @returns
#' An [`sf`][sf::st_sf] object with the results that match the query.
#'
#' @inherit geo_lite seealso
#'
#' @family geocoding
#' @family spatial
#'
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Point geometries
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
#' # Multiple matches
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
    message_api_unavailable(url)
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message_no_results(address)
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
