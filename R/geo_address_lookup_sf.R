#' Address Lookup API for OSM objects in Spatial Format
#'
#' @description
#' The lookup API allows to query the address and other details of one or
#' multiple OSM objects like node, way or relation. This function returns the
#' spatial object associated with the query, see [geo_address_lookup()] for
#' retrieving the data in `tibble` format.
#'
#' @return A `sf` object with the results.
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
#' library(ggplot2)
#'
#' ggplot(NotreDame) +
#'   geom_sf()
#'
#' NotreDame_poly <- geo_address_lookup_sf(201611261,
#'   type = "W",
#'   points_only = FALSE
#' )
#'
#' ggplot(NotreDame_poly) +
#'   geom_sf()
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
                                  custom_query = list(),
                                  points_only = TRUE) {
  # Step 1: Download ----
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

  # Step 2: Read and parse results ----
  # If no response...
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- data.frame(query = paste0(type, osm_ids))
    result_out$geometry <- "POINT EMPTY"
    result_out <- sf::st_as_sf(dplyr::as_tibble(result_out),
      wkt = "geometry",
      crs = 4326
    )
    return(invisible(result_out))
  }

  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Empty query
  if (length(names(sfobj)) == 1) {
    message("No results for query ", nodes)
    result_out <- data.frame(query = paste0(type, osm_ids))
    result_out$geometry <- "POINT EMPTY"
    result_out <- sf::st_as_sf(dplyr::as_tibble(result_out),
      wkt = "geometry",
      crs = 4326
    )
    return(invisible(result_out))
  }

  # Prepare output
  if ("address" %in% names(sfobj)) {
    add <- as.character(sfobj$address)

    newadd <- lapply(add, function(x) {
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })
    newadd <- dplyr::bind_rows(newadd)

    newsfobj <- sfobj
    newsfobj <- sfobj[, setdiff(names(sfobj), "address")]
    sfobj <- dplyr::bind_cols(newsfobj, newadd)
  }

  result_out <- dplyr::tibble(
    query = paste0(type, osm_ids),
    osm_id = osm_ids
  )

  # More renames
  names(sfobj) <- gsub("address.", "", names(sfobj))
  names(sfobj) <- gsub("namedetails.", "", names(sfobj))
  names(sfobj) <- gsub("display_name", "address", names(sfobj))

  # Keep only same results

  sf_clean <- dplyr::inner_join(sfobj, result_out, by = "osm_id")

  # Warning in lost rows
  if (all(nrow(sf_clean) < nrow(result_out), verbose)) {
    warning("Some ids may not have produced results. Check the final object")
  }


  df_sf <- sf::st_drop_geometry(sf_clean)
  df_sf <- dplyr::as_tibble(df_sf)

  out_cols <- "query"

  if (return_addresses) out_cols <- c(out_cols, "address")
  if (full_results) out_cols <- c(out_cols, "address", names(df_sf))

  out_cols <- unique(out_cols)
  out <- df_sf[, out_cols]

  # Construct final object
  thegeom <- sf::st_geometry(sfobj)
  thegeom <- sf::st_make_valid(thegeom)
  out$geometry <- sf::st_as_text(thegeom)
  result_out <- sf::st_as_sf(out, wkt = "geometry", crs = 4326)
  return(result_out)
}
