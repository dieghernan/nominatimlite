#' Address search API in \CRANpkg{sf} format (free-form query)
#'
#' @description
#' Geocodes addresses and returns the corresponding spatial object. The
#' query output is provided in \CRANpkg{sf} format; see [geo_lite()] for
#' retrieving the data in [`tibble`][tibble::tibble] format.
#'
#' Corresponds to the **free-form query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/latest/api/Search/).
#'
#' @family geocoding
#' @family spatial
#' @encoding UTF-8
#'
#' @param full_results Returns all available data from the API service.
#'   If `FALSE` (default), only address columns are returned. See also
#'   `return_addresses`.
#' @param points_only Logical `TRUE/FALSE`. Whether to return only spatial
#'   points (`TRUE`, which is the default) or potentially other shapes as
#'   provided by the Nominatim API (`FALSE`). See **About geometry types**.
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
#' geometry) or possibly other spatial objects.
#'
#' Note that the type of geometry returned in case of `points_only = FALSE`
#' will depend on the object being geocoded:
#'
#'   - Administrative areas, major buildings and the like will be
#'     returned as polygons.
#'   - Rivers, roads and similar features will be returned as lines.
#'   - Amenities may be points even with `points_only = FALSE`.
#'
#' The function is vectorized, allowing for multiple addresses to be geocoded;
#' with `points_only = FALSE`, multiple geometry types may be returned.
#'
#' @return
#'
#' ```{r child = "man/chunks/sfout.Rmd"}
#' ```
#'
#' @seealso
#' [geo_lite()].
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
  if (limit > 50) {
    message(paste(
      "Nominatim returns at most 50 results. ",
      "Your query may be incomplete."
    ))
    limit <- min(50, limit)
  }

  # Deduplicate queries.
  init_key <- dplyr::tibble(query = address)
  key <- unique(address)

  # Set the progress bar.
  ntot <- length(key)
  # Show the progress bar only when there is more than one query.
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }

  seql <- seq(1, ntot, 1)

  # Run one request per unique query.
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

  if (progressbar) {
    close(pb)
  }

  all_res <- dplyr::bind_rows(all_res)

  all_res <- sf_to_tbl(all_res)

  # Restore duplicate inputs in `sf` output.
  if (!identical(as.character(init_key$query), key)) {
    # Join with indexes.
    template <- sf::st_drop_geometry(all_res)[, "query"]
    template$rindex <- seq_len(nrow(template))
    getrows <- dplyr::left_join(init_key, template, by = "query")

    # Select rows.
    all_res <- all_res[as.double(getrows$rindex), ]
    all_res <- sf_to_tbl(all_res)
  }

  all_res
}

#' @noRd
#' @inheritParams geo_lite

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
  # Build the API address and ensure that the server URL has one trailing slash.
  api <- prepare_api_url(nominatim_server, "search?q=")

  # Replace spaces with `+`.
  address2 <- gsub(" ", "+", address, fixed = TRUE)

  # Compose the URL.
  url <- paste0(api, address2, "&format=geojson&limit=", limit)

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }
  if (!isTRUE(points_only)) {
    url <- paste0(url, "&polygon_geojson=1")
  }

  # Add options.
  url <- add_custom_query(custom_query, url)

  # Download to a temporary file.
  json <- api_call(url, ".geojson", isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tibble with the query.
  tbl_query <- dplyr::tibble(query = address)

  if (isFALSE(json)) {
    message(url, " is not reachable.")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read the spatial object.
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Handle empty queries.
  if (length(names(sfobj)) == 1) {
    message("No results for query ", address, ".")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Prepare the output.

  # Unnest address fields.
  sfobj <- unnest_sf(sfobj)

  # Prepare the output.
  sf_clean <- sfobj
  sf_clean$query <- address

  # Keep selected names.
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
