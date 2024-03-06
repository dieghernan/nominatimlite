#' Address search API for OSM elements in \CRANpkg{sf} format
#'
#' @description
#' This function allows you to geocode addresses and return the corresponding
#' spatial object. This function returns the spatial object associated with the
#' query using \CRANpkg{sf}, see [geo_lite_sf()] for retrieving the data in
#' \CRANpkg{tibble} format.
#'
#'
#' @param full_results returns all available data from the API service.
#'   If `FALSE` (default) only address columns are returned. See also
#'   `return_addresses`.
#'
#' @param points_only Logical `TRUE/FALSE`. Whether to return only spatial
#'   points (`TRUE`, which is the default) or potentially other shapes as
#'   provided by the Nominatim API (`FALSE`). See **About Geometry Types**.
#'
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @section About Geometry Types:
#'
#' The parameter `points_only` specifies whether the function results will be
#' points (all Nominatim results are guaranteed to have at least point
#' geometry) or possibly other spatial objects.
#'
#' Note that the type of geometry returned in case of `points_only = FALSE`
#' will depend on the object being geocoded:
#'
#'   * Administrative areas, major buildings and the like will be
#'     returned as polygons.
#'   * Rivers, roads and their like as lines.
#'   * Amenities may be points even in case of a `points_only = FALSE` call.
#'
#' The function is vectorized, allowing for multiple addresses to be geocoded;
#' in case of `points_only = FALSE`  multiple geometry types may be returned.
#'
#' @return A \CRANpkg{sf} object with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Map - Points
#' library(ggplot2)
#'
#' string <- "Statue of Liberty, NY, USA"
#' sol <- geo_lite_sf(string)
#'
#' if (any(!sf::st_is_empty(sol))) {
#'   ggplot(sol) +
#'     geom_sf()
#' }
#'
#' sol_poly <- geo_lite_sf(string, points_only = FALSE)
#'
#' if (any(!sf::st_is_empty(sol_poly))) {
#'   ggplot(sol_poly) +
#'     geom_sf() +
#'     geom_sf(data = sol, color = "red")
#' }
#' # Several results
#'
#' Madrid <- geo_lite_sf("Madrid",
#'   limit = 2,
#'   points_only = FALSE, full_results = TRUE
#' )
#'
#' if (any(!sf::st_is_empty(Madrid))) {
#'   ggplot(Madrid) +
#'     geom_sf(fill = NA)
#' }
#' }
#' @export
#'
#' @family geocoding
#' @family spatial

geo_lite_sf <- function(address,
                        limit = 1,
                        return_addresses = TRUE,
                        full_results = FALSE,
                        verbose = FALSE,
                        progressbar = TRUE,
                        nominatim_server =
                          "https://nominatim.openstreetmap.org/",
                        custom_query = list(),
                        points_only = TRUE) {
  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }


  # Dedupe for query
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  # Set progress bar
  ntot <- length(key)
  # Set progress bar if n > 1
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }

  seql <- seq(1, ntot, 1)

  # Loop
  all_res <- lapply(seql, function(x) {
    ad <- key[x]
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }
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

  if (progressbar) close(pb)

  all_res <- dplyr::bind_rows(all_res)

  all_res <- sf_to_tbl(all_res)

  # Handle dupes in sf
  if (!identical(as.character(init_key$query), key)) {
    # Join with indexes
    template <- sf::st_drop_geometry(all_res)[, "query"]
    template$rindex <- seq_len(nrow(template))
    getrows <- dplyr::left_join(init_key, template, by = "query")

    # Select rows
    all_res <- all_res[as.integer(getrows$rindex), ]
    all_res <- sf_to_tbl(all_res)
  }

  return(all_res)
}

#' @noRd
#' @inheritParams geo_lite

geo_lite_sf_single <- function(address,
                               limit = 1,
                               return_addresses = TRUE,
                               full_results = FALSE,
                               verbose = FALSE,
                               nominatim_server =
                                 "https://nominatim.openstreetmap.org/",
                               custom_query = list(),
                               points_only = TRUE) {
  # First build the api address. If the passed nominatim_server does not end
  # with a trailing forward-slash, add one
  if (substr(nominatim_server, nchar(nominatim_server),
             nchar(nominatim_server)) != "/") {
    nominatim_server <- paste0(nominatim_server, "/")
  }
  api <- paste0(nominatim_server, "search.php?q=")

  # Replace spaces with +
  address2 <- gsub(" ", "+", address)

  # Compose url
  url <- paste0(api, address2, "&format=geojson&limit=", limit)

  if (full_results) url <- paste0(url, "&addressdetails=1")
  if (!isTRUE(points_only)) url <- paste0(url, "&polygon_geojson=1")

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".geojson")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = address)

  # nocov start
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
    message("No results for query ", address)
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Prepare output

  # Unnest address
  sfobj <- unnest_sf(sfobj)



  # Prepare output
  sf_clean <- sfobj
  sf_clean$query <- address

  # Keep names
  result_out <- keep_names(sf_clean, return_addresses, full_results,
    colstokeep = "query"
  )

  # Attach as tibble
  result_out <- sf_to_tbl(result_out)

  result_out
}
