#' Address lookup API for OSM elements in \CRANpkg{sf} format
#'
#' @description
#' The lookup API allows to query the address and other details of one or
#' multiple OSM objects like node, way or relation. This function returns the
#' spatial object associated with the query using \CRANpkg{sf}, see
#' [geo_address_lookup()] for retrieving the data in \CRANpkg{tibble} format.
#'
#' @return A \CRANpkg{sf} object with the results.
#'
#' @inheritParams geo_lite_sf
#' @inheritParams geo_address_lookup
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Lookup/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @seealso [geo_address_lookup()]
#' @family lookup
#' @family geocoding
#' @family spatial
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Notre Dame Cathedral, Paris
#'
#' NotreDame <- geo_address_lookup_sf(osm_ids = 201611261, type = "W")
#'
#' # Need at least one non-empty object
#' if (any(!sf::st_is_empty(NotreDame))) {
#'   library(ggplot2)
#'
#'   ggplot(NotreDame) +
#'     geom_sf()
#' }
#'
#' NotreDame_poly <- geo_address_lookup_sf(201611261,
#'   type = "W",
#'   points_only = FALSE
#' )
#'
#'
#' if (any(!sf::st_is_empty(NotreDame_poly))) {
#'   ggplot(NotreDame_poly) +
#'     geom_sf()
#' }
#'
#' # It is vectorized
#'
#' several <- geo_address_lookup_sf(c(146656, 240109189), type = c("R", "N"))
#' several
#' }
#' @export
geo_address_lookup_sf <- function(osm_ids,
                                  type = c("N", "W", "R"),
                                  full_results = FALSE,
                                  return_addresses = TRUE,
                                  verbose = FALSE,
                                  nominatim_server =
                                    "https://nominatim.openstreetmap.org/",
                                  custom_query = list(),
                                  points_only = TRUE) {
  # First build the api address. If the passed nominatim_server does not end
  # with a trailing forward-slash, add one
  api <- prepare_api_url(nominatim_server, "lookup?")

  # Prepare nodes
  osm_ids <- as.integer(osm_ids)
  type <- as.character(type)
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose url
  url <- paste0(api, "osm_ids=", nodes, "&format=geojson")

  if (!isTRUE(points_only)) url <- paste0(url, "&polygon_geojson=1")
  if (full_results) url <- paste0(url, "&addressdetails=1")


  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".geojson")
  res <- api_call(url, json, quiet = isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = paste0(type, osm_ids))

  # nocov start
  # If no response...
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }
  # nocov end

  # Read
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Empty query
  if (length(names(sfobj)) == 1) {
    message("No results for query ", nodes)
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Prepare output

  # Unnest address
  sfobj <- unnest_sf(sfobj)


  # In this function we need to re-create tbl_query
  tbl_query <- dplyr::tibble(
    query = paste0(type, osm_ids),
    osm_id = osm_ids
  )

  # Keep only same results
  sf_clean <- dplyr::inner_join(sfobj, tbl_query, by = "osm_id")

  # Warning in lost rows
  if (all(nrow(sf_clean) < nrow(tbl_query), verbose)) {
    warning("Some ids may not have produced results. Check the final object")
  }

  # Keep names
  result_out <- keep_names(sf_clean, return_addresses, full_results,
    colstokeep = "query"
  )

  # Attach as tibble
  result_out <- sf_to_tbl(result_out)

  result_out
}
