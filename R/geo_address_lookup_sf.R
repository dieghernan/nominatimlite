#' Get spatial objects from OSM ids
#'
#' @description
#' This function allows you to extract the spatial objects for specific
#' OSM objects.
#'
#' @return A `sf` object with the results.
#'
#' @inheritParams geo_address_lookup
#' @inheritParams geo_lite_sf
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @family spatial
#' @family lookup
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Notre Dame Cathedral, Paris
#'
#' NotreDame <- geo_address_lookup_sf(
#'   osm_ids = c(201611261),
#'   type = c("W")
#' )
#'
#' library(ggplot2)
#'
#' ggplot(NotreDame) +
#'   geom_sf()
#'
#' NotreDame_poly <- geo_address_lookup_sf(
#'   osm_ids = c(201611261),
#'   type = c("W"),
#'   points_only = FALSE
#' )
#'
#' ggplot(NotreDame_poly) +
#'   geom_sf()
#' }
#' @export
geo_address_lookup_sf <- function(osm_ids,
                                  type = c("N", "W", "R"),
                                  full_results = FALSE,
                                  return_addresses = TRUE,
                                  verbose = FALSE,
                                  custom_query = list(),
                                  points_only = TRUE) {
  api <- "https://nominatim.openstreetmap.org/lookup?"

  # Prepare nodes
  nodes <- paste0(type, osm_ids, collapse = ",")

  # Compose url
  url <- paste0(api, "osm_ids=", nodes, "&format=geojson")

  if (!isTRUE(points_only)) {
    url <- paste0(url, "&polygon_geojson=1")
  }


  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  if (length(custom_query) > 0) {
    opts <- NULL
    for (i in seq_len(length(custom_query))) {
      nlist <- names(custom_query)[i]
      val <- paste0(custom_query[[i]], collapse = ",")


      opts <- paste0(opts, "&", nlist, "=", val)
    }

    url <- paste0(url, "&", opts)
  }

  # Download

  json <- tempfile(fileext = ".geojson")

  res <- api_call(url, json, quiet = isFALSE(verbose))

  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- data.frame(query = paste0(type, osm_ids))
    return(invisible(result_out))
  }
  # nocov end

  sfobj <- sf::st_read(json,
    stringsAsFactors = FALSE,
    quiet = isFALSE(verbose)
  )

  # Check if null and return

  if (length(names(sfobj)) == 1) {
    message("No results for query ", nodes)
    result_out <- data.frame(query = paste0(type, osm_ids))
    return(invisible(result_out))
  }


  # Prepare output

  result_out <- data.frame(query = paste0(type, osm_ids))

  df_sf <- tibble::as_tibble(sf::st_drop_geometry(sfobj))

  # Rename original address

  names(df_sf) <-
    gsub("address", "osm.address", names(df_sf))

  names(df_sf) <- gsub("display_name", "address", names(df_sf))


  if (return_addresses || full_results) {
    disp_name <- df_sf["address"]
    result_out <- cbind(result_out, disp_name)
  }

  # If full
  if (full_results) {
    rest_cols <- df_sf[, !names(df_sf) %in% "address"]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <- sf::st_sf(result_out, geometry = sf::st_geometry(sfobj))
  return(result_out)
}
