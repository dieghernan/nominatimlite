#' Reverse Geocoding API for OSM objects in Spatial format
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be
#' between `[-90, 90]` and longitudes between `[-180, 180]`. This function
#' returns the \CRANpkg{sf} spatial object associated with the query, see
#' [reverse_geo_lite()] for retrieving the data in \CRANpkg{tibble} format.
#'
#' @inheritParams reverse_geo_lite
#' @inheritParams geo_lite_sf
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Reverse/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @inheritSection  reverse_geo_lite  About Zooming
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @return A `sf` object with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' library(ggplot2)
#'
#'
#' Coliseum <- geo_lite("Coliseo, Rome, Italy")
#'
#' # Coliseum
#' Col_sf <- reverse_geo_lite_sf(
#'   lat = Coliseum$lat,
#'   lon = Coliseum$lon,
#'   points_only = FALSE
#' )
#'
#' ggplot(Col_sf) +
#'   geom_sf()
#'
#' # City of Rome - Zoom 10
#'
#' Rome_sf <- reverse_geo_lite_sf(
#'   lat = Coliseum$lat,
#'   lon = Coliseum$lon,
#'   custom_query = list(zoom = 10),
#'   points_only = FALSE
#' )
#'
#' ggplot(Rome_sf) +
#'   geom_sf()
#'
#' # County - Zoom 8
#'
#' County_sf <- reverse_geo_lite_sf(
#'   lat = Coliseum$lat,
#'   lon = Coliseum$lon,
#'   custom_query = list(zoom = 8),
#'   points_only = FALSE
#' )
#'
#' ggplot(County_sf) +
#'   geom_sf()
#' }
#' @export
#'
#' @seealso [reverse_geo_lite()]
#' @family reverse
#' @family spatial
reverse_geo_lite_sf <- function(lat,
                                long,
                                address = "address",
                                full_results = FALSE,
                                return_coords = TRUE,
                                verbose = FALSE,
                                custom_query = list(),
                                points_only = TRUE) {
  # Check inputs
  if (!is.numeric(lat) || !is.numeric(long)) {
    stop("lat and long must be numeric")
  }

  if (length(lat) != length(long)) {
    stop("lat and long should have the same number of elements")
  }

  # Lat
  lat_cap <- pmax(pmin(lat, 90), -90)

  if (!identical(lat_cap, lat)) {
    message("latitudes have been restricted to [-90, 90]")
  }

  # Lon
  long_cap <- pmax(pmin(long, 180), -180)

  if (!all(long_cap == long)) {
    message("longitudes have been restricted to [-180, 180]")
  }


  # Dedupe for query using data frame

  init_key <- dplyr::tibble(
    lat_key_int = lat, long_key_int = long,
    lat_cap_int = lat_cap, long_cap_int = long_cap
  )
  key <- dplyr::distinct(init_key)

  all_res <- lapply(seq_len(nrow(key)), function(x) {
    rw <- key[x, ]
    res_single <- reverse_geo_lite_sf_single(
      as.double(rw$lat_cap_int),
      as.double(rw$long_cap_int),
      address,
      full_results,
      return_coords,
      verbose,
      custom_query,
      points_only
    )

    res_single <- dplyr::bind_cols(res_single, rw[, c(1, 2)])

    res_single
  })


  all_res <- dplyr::bind_rows(all_res)

  # Handle dupes in sf
  if (!identical(nrow(init_key), nrow(all_res))) {
    # Join with indexes
    tmplt <- sf::st_drop_geometry(all_res)[, c("lat_key_int", "long_key_int")]
    tmplt$rindex <- seq_len(nrow(tmplt))
    getrows <- dplyr::left_join(init_key, tmplt, by = c(
      "lat_key_int",
      "long_key_int"
    ))

    # Select rows
    all_res <- all_res[as.integer(getrows$rindex), ]
  }

  # Final cleanup
  kpnms <- setdiff(names(all_res), c("lat_key_int", "long_key_int"))

  all_res <- all_res[, kpnms]

  all_res <- sf_to_tbl(all_res)

  all_res
}


#' @noRd
#' @inheritParams reverse_geo_lite_sf
reverse_geo_lite_sf_single <- function(lat_cap,
                                       long_cap,
                                       address = "address",
                                       full_results = TRUE,
                                       return_coords = TRUE,
                                       verbose = TRUE,
                                       custom_query = list(),
                                       points_only = FALSE) {
  # Step 1: Download ----
  api <- "https://nominatim.openstreetmap.org/reverse?"

  # Compose url
  url <- paste0(api, "lat=", lat_cap, "&lon=", long_cap, "&format=geojson")

  if (!isTRUE(points_only)) url <- paste0(url, "&polygon_geojson=1")
  if (isFALSE(full_results)) {
    url <- paste0(url, "&addressdetails=0")
  } else {
    url <- paste0(url, "&addressdetails=1")
  }

  # Add options
  url <- add_custom_query(custom_query, url)


  # Download to temp file
  json <- tempfile(fileext = ".geojson")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)

  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_sf(empty_tbl_rev(tbl_query, address))
    return(invisible(out))
  }
  # nocov end


  # Empty query
  result_init <- jsonlite::fromJSON(json, flatten = TRUE)
  if ("error" %in% names(result_init)) {
    message(
      "No results for query lon=",
      long_cap, ", lat=", lat_cap
    )
    out <- empty_sf(empty_tbl_rev(tbl_query, address))
    return(invisible(out))
  }

  # Prepare output
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Unnest address
  sfobj <- unnest_sf_reverse(sfobj)

  # Add lat lon
  sf_clean <- dplyr::bind_cols(sfobj, tbl_query)


  # Keep names
  result_out <- keep_names_rev(sf_clean, address, return_coords, full_results)

  # Attach as tibble
  result_out <- sf_to_tbl(result_out)

  result_out
}
