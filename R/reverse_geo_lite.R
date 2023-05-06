#' Reverse geocode coordinates
#'
#' @description
#' Reverse geocodes geographic coordinates (latitude and longitude) given as
#' numeric values. Latitudes must be between -90 and 90 and longitudes must be
#' between -180 and 180.
#'
#' @param custom_query API-specific parameters to be used, passed as a named
#'   list (ie. `list(zoom = 3)`). See Details.
#'
#' @inheritParams tidygeocoder::reverse_geo
#'
#' @details
#' See <https://nominatim.org/release-docs/develop/api/Reverse/> for additional
#' parameters to be passed to `custom_query`.
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
#' knitr::kable(t)
#'
#'
#' ```
#'
#' @return A `tibble` with the results.
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#'
#' reverse_geo_lite(lat = 40.75728, long = -73.98586)
#'
#' # Several coordinates
#' reverse_geo_lite(
#'   lat = c(40.75728, 55.95335),
#'   long = c(-73.98586, -3.188375)
#' )
#'
#' # With options: zoom to country
#' reverse_geo_lite(
#'   lat = c(40.75728, 55.95335),
#'   long = c(-73.98586, -3.188375),
#'   custom_query = list(zoom = 0),
#'   verbose = TRUE,
#'   full_results = TRUE
#' )
#' }
#' @export
#'
#' @seealso [reverse_geo_lite_sf()], [tidygeocoder::reverse_geo()]
#' @family geocoding
reverse_geo_lite <- function(lat,
                             long,
                             address = "address",
                             full_results = FALSE,
                             return_coords = TRUE,
                             verbose = FALSE,
                             custom_query = list()) {
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
    res_single <- reverse_geo_lite_single(
      lat_cap[i],
      long_cap[i],
      address,
      full_results,
      return_coords,
      verbose,
      custom_query
    )
    all_res <- dplyr::bind_rows(all_res, res_single)
  }

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
  api <- "https://nominatim.openstreetmap.org/reverse?"

  url <- paste0(
    api, "lat=",
    lat_cap,
    "&lon=",
    long_cap,
    "&format=json"
  )


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

  json <- tempfile(fileext = ".json")

  res <- api_call(url, json, quiet = isFALSE(verbose))


  # nocov start
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- dplyr::tibble(ad = NA)
    names(result_out) <- address
    return(invisible(result_out))
  }

  # nocov end

  result_init <- jsonlite::fromJSON(json, flatten = TRUE)

  if ("error" %in% names(result_init)) {
    message(
      "No results for query lon=",
      long_cap, ", lat=", lat_cap
    )
    result_out <- dplyr::tibble(ad = NA)
    names(result_out) <- address

    if (return_coords) {
      result_out$lat <- as.double(lat_cap)
      result_out$lon <- as.double(long_cap)
    }
    return(invisible(result_out))
  }


  result <- NULL

  # Hack to overcome problems with address and boundingbox
  for (i in seq_len(length(result_init))) {
    if (names(result_init)[i] %in% c("address", "extratags")) {
      result <- dplyr::bind_cols(result, dplyr::as_tibble(result_init[i][[1]]))
    } else if (names(result_init)[i] == "boundingbox") {
      result_init[i] <- list(result_init[[i]])
      r <- dplyr::tibble(boundingbox = unname(result_init[i]))
      result <- dplyr::bind_cols(result, r)
    } else {
      result <- dplyr::bind_cols(result, dplyr::as_tibble(result_init[i]))
    }
  }


  result$lat <- as.double(result$lat)
  result$lon <- as.double(result$lon)

  nmes <- names(result)
  nmes[nmes == "display_name"] <- address

  names(result) <- nmes

  # Prepare output
  result_out <- result[address]



  if (return_coords || full_results) {
    disp_coords <- result[c("lat", "lon")]
    result_out <- cbind(result_out, disp_coords)
  }

  # If full
  if (full_results) {
    rest_cols <- result[, !names(result) %in% c(address, "lon", "lat")]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <- dplyr::as_tibble(result_out)

  return(result_out)
}
