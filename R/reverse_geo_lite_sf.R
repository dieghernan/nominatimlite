#' Reverse Geocoding API for OSM objects in Spatial format
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be
#' between `[-90, 90]` and longitudes between `[-180, 180]`. This function
#' returns the (\pkg{sf}) spatial object associated with the query, see
#' [reverse_geo_lite()] for retrieving the data in `tibble` format.
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
  lat_cap <- pmin(lat, 90)
  lat_cap <- pmax(lat_cap, -90)


  if (!all(lat_cap == lat)) {
    message("latitudes have been restricted to [-90, 90]")
  }

  # Lon
  long_cap <- pmin(long, 180)
  long_cap <- pmax(long_cap, -180)


  if (!all(long_cap == long)) {
    message("longitudes have been restricted to [-180, 180]")
  }

  # Loop
  all_res <- NULL

  for (i in seq_len(length(long_cap))) {
    res_single <- reverse_geo_lite_sf_single(
      lat_cap[i],
      long_cap[i],
      address,
      full_results,
      return_coords,
      verbose,
      custom_query,
      points_only
    )
    all_res <- dplyr::bind_rows(all_res, res_single)
  }

  return(all_res)
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
  api <- "https://nominatim.openstreetmap.org/reverse?"

  url <- paste0(
    api, "lat=",
    lat_cap,
    "&lon=",
    long_cap,
    "&format=geojson"
  )

  if (!isTRUE(points_only)) {
    url <- paste0(url, "&polygon_geojson=1")
  }

  if (isFALSE(full_results)) {
    url <- paste0(url, "&addressdetails=0")
  }

  if (length(custom_query) > 0) {
    opts <- NULL
    for (i in seq_len(length(custom_query))) {
      nlist <- names(custom_query)[i]
      val <- paste0(custom_query[[i]], collapse = ",")


      opts <- paste0(opts, "&", nlist, "=", val)
    }

    url <- paste0(url, opts)
  }

  # Download

  json <- tempfile(fileext = ".geojson")

  res <- api_call(url, json, quiet = isFALSE(verbose))


  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- dplyr::tibble(ad = NA)
    names(result_out) <- address

    coords <- data.frame(lat = lat_cap, lon = long_cap)

    geometry <- sf::st_as_sf(coords, coords = c("lon", "lat"), crs = 4326)
    geometry <- sf::st_geometry(geometry)

    if (return_coords) {
      result_out <- dplyr::bind_cols(result_out, coords)
    }

    result_out <- sf::st_sf(result_out, geometry)

    return(invisible(result_out))
  }
  # nocov end


  sfobj <- tryCatch(
    sf::st_read(
      json,
      stringsAsFactors = FALSE,
      quiet = isFALSE(verbose)
    ),
    error = function(e) {
      return(FALSE)
    },
    # nocov start
    warning = function(e) {
      return(FALSE)
    }
    # nocov end
  )

  # Handle errors
  if (!"sf" %in% class(sfobj)) {
    message(
      "No results for query lon=",
      long_cap,
      ", lat=",
      lat_cap
    )
    result_out <- dplyr::tibble(ad = NA)
    names(result_out) <- address

    coords <- data.frame(lat = lat_cap, lon = long_cap)

    geometry <- sf::st_as_sf(coords, coords = c("lon", "lat"), crs = 4326)
    geometry <- sf::st_geometry(geometry)

    if (return_coords) {
      result_out <- dplyr::bind_cols(result_out, coords)
    }

    result_out <- sf::st_sf(result_out, geometry)

    return(invisible(result_out))
  }

  # Prepare output
  df_sf <- dplyr::as_tibble(sf::st_drop_geometry(sfobj))

  # Rename original address

  names(df_sf) <-
    gsub(
      paste0("^", address, "$"),
      paste0("osm.", address),
      names(df_sf)
    )
  nmes <- names(df_sf)
  nmes[nmes == "display_name"] <- address

  names(df_sf) <- nmes
  df_sf$lat <- as.double(lat_cap)
  df_sf$lon <- as.double(long_cap)

  # Prepare output
  result_out <- df_sf[address]

  if (return_coords || full_results) {
    disp_coords <- df_sf[c("lat", "lon")]
    result_out <- cbind(result_out, disp_coords)
  }

  # If full
  if (full_results) {
    rest_cols <- df_sf[, !names(df_sf) %in% c(address, "lon", "lat")]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <-
    sf::st_sf(result_out, geometry = sf::st_geometry(sfobj))
}
