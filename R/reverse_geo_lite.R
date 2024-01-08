#' Reverse Geocoding API for OSM objects
#'
#' @description
#' Generates an address from a latitude and longitude. Latitudes must be
#' between `[-90, 90]` and longitudes between `[-180, 180]`. This
#' function returns the \CRANpkg{tibble} associated with the query, see
#' [reverse_geo_lite_sf()] for retrieving the data as a spatial object
#' (\CRANpkg{sf}) format).
#'
#' @param lat  latitude values in numeric format. Must be in the range
#'   `[-90, 90]`.
#' @param long  longitude values in numeric format. Must be in the range
#'   `[-180, 180]`.
#' @param address address column name in the output data (default  `"address"`).
#' @param return_coords	return input coordinates with results if `TRUE`.
#' @param custom_query API-specific parameters to be used, passed as a named
#'   list (ie. `list(zoom = 3)`). See **Details**.
#'
#' @inheritParams geo_lite
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Reverse/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @section About Zooming:
#'
#' Use the option `custom_query = list(zoom = 3)` to adjust the output. Some
#' equivalences on terms of zoom:
#'
#'
#' ```{r, echo=FALSE}
#'
#' t <- dplyr::tribble(
#'  ~zoom, ~address_detail,
#'  3, "country",
#'  5, "state",
#'  8, "county",
#'  10, "city",
#'  14, "suburb",
#'  16, "major streets",
#'  17, "major and minor streets",
#'  18, "building"
#'  )
#'
#' knitr::kable(t, col.names = paste0("**", names(t), "**"))
#'
#'
#' ```
#'
#' @return A \CRANpkg{tibble} with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#'
#' reverse_geo_lite(lat = 40.75728, long = -73.98586)
#'
#' # Several coordinates
#' reverse_geo_lite(lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375))
#'
#' # With options: zoom to country level
#' sev <- reverse_geo_lite(
#'   lat = c(40.75728, 55.95335), long = c(-73.98586, -3.188375),
#'   custom_query = list(zoom = 0, extratags = 1),
#'   verbose = TRUE, full_results = TRUE
#' )
#'
#' dplyr::glimpse(sev)
#' }
#'
#' @export
#'
#' @seealso [reverse_geo_lite_sf()], [tidygeocoder::reverse_geo()]
#' @family reverse
#'
reverse_geo_lite <- function(lat,
                             long,
                             address = "address",
                             full_results = FALSE,
                             return_coords = TRUE,
                             verbose = FALSE,
                             progressbar = TRUE,
                             custom_query = list()) {
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

  # Set progress bar
  ntot <- nrow(key)
  # Set progress bar if n > 1
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }

  seql <- seq(1, ntot, 1)


  all_res <- lapply(seql, function(x) {
    if (progressbar) {
      setTxtProgressBar(pb, x)
      cat(paste0(" (", x, "/", ntot, ")  "))
    }
    rw <- key[x, ]
    res_single <- reverse_geo_lite_single(
      as.double(rw$lat_cap_int),
      as.double(rw$long_cap_int),
      address,
      full_results,
      return_coords,
      verbose,
      custom_query
    )

    res_single <- dplyr::bind_cols(res_single, rw[, c(1, 2)])

    res_single
  })
  if (progressbar) close(pb)

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key[, c(1, 2)], all_res,
    by = c("lat_key_int", "long_key_int")
  )

  # Final clean
  all_res <- all_res[, -c(1, 2)]
  return(all_res)
}

#' @noRd
#' @inheritParams reverse_geo_lite
reverse_geo_lite_single <- function(lat_cap,
                                    long_cap,
                                    address = "address",
                                    full_results = FALSE,
                                    return_coords = TRUE,
                                    verbose = TRUE,
                                    custom_query = list()) {
  # Step 1: Download ----
  api <- "https://nominatim.openstreetmap.org/reverse?"

  # Compose url
  url <- paste0(api, "lat=", lat_cap, "&lon=", long_cap, "&format=json")

  if (isFALSE(full_results)) {
    url <- paste0(url, "&addressdetails=0")
  } else {
    url <- paste0(url, "&addressdetails=1")
  }

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  tbl_query <- dplyr::tibble(lat = lat_cap, lon = long_cap)



  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_tbl(tbl_query, address)
    return(invisible(out))
  }
  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  # Empty query
  if ("error" %in% names(result_init)) {
    message(
      "No results for query lon=",
      long_cap, ", lat=", lat_cap
    )
    out <- empty_tbl_rev(tbl_query, address)
    return(invisible(out))
  }


  # Unnnest fields
  result <- unnest_reverse(result_init)

  result$lat <- as.double(result$lat)
  result$lon <- as.double(result$lon)

  # Keep names
  result_out <- keep_names_rev(result,
    address = address,
    return_coords = return_coords,
    full_results = full_results
  )

  return(result_out)
}
