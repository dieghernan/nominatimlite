#' Address search API with \CRANpkg{sf} output (structured query)
#'
#' @description
#' Searches for addresses already split into components and returns matching
#' results as an [`sf`][sf::st_sf] object using \CRANpkg{sf}. Use
#' [geo_lite_struct()] to return a [tibble][dplyr::tibble] instead.
#'
#' This function performs the **structured address search** described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/). To
#' perform a free-form search, use [geo_lite_sf()].
#'
#' @inherit geo_lite_struct details
#'
#' @inheritSection geo_lite_sf About geometry types
#'
#' @param full_results If `TRUE`, return all available fields from the Nominatim
#'   API. If `FALSE`, return only query metadata, geometry and requested address
#'   columns.
#' @param points_only If `TRUE`, return only point geometries. If `FALSE`, the
#'   API may return other geometry types. See **About geometry types**.
#' @inheritParams geo_lite_struct
#' @inherit geo_lite_sf return
#'
#' @inherit geo_lite seealso
#'
#' @family geocoding
#' @family spatial
#' @encoding UTF-8
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Structured address search
#'
#' pl_mayor <- geo_lite_struct_sf(
#'   street = "Plaza Mayor",
#'   county = "Comunidad de Madrid",
#'   country = "Spain", limit = 50,
#'   full_results = TRUE, verbose = TRUE
#' )
#'
#' # Administrative boundary
#' ccaa <- geo_lite_sf("Comunidad de Madrid, Spain", points_only = FALSE)
#'
#' library(ggplot2)
#'
#' if (any(!sf::st_is_empty(pl_mayor), !sf::st_is_empty(ccaa))) {
#'   ggplot(ccaa) +
#'     geom_sf() +
#'     geom_sf(data = pl_mayor, aes(shape = addresstype, color = addresstype))
#' }
#' }
geo_lite_struct_sf <- function(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list(),
  points_only = TRUE
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
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  pars <- lapply(pars, encode_search_text)
  custom_query <- compact_query_options(c(pars, custom_query))
  url <- build_search_url(
    nominatim_server = nominatim_server,
    format = "geojson",
    limit = limit,
    full_results = full_results,
    custom_query = custom_query,
    points_only = points_only
  )

  # Download the API response.
  json <- api_call(url, ".geojson", isFALSE(verbose))

  if (isFALSE(json)) {
    message("Cannot reach the API endpoint: ", url, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the `sf` object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message("No results found for the query.")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Unnest nested fields.
  sfobj <- unnest_sf(sfobj)

  # Prepare the output with query metadata.
  sf_clean <- sfobj

  # Preserve the naming order.
  sf_clean <- dplyr::bind_cols(sf_clean, tbl_query[rep(1, nrow(sf_clean)), ])

  # Keep selected columns.
  result_out <- keep_names(
    sf_clean,
    return_addresses,
    full_results,
    colstokeep = names(tbl_query)
  )

  # Restore tibble classes.
  result_out <- sf_to_tbl(result_out)

  result_out
}
