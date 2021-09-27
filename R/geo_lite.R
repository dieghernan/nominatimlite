#' Geocode addresses
#'
#' @description
#' Geocodes addresses given as character values.
#'
#' @param address single line address (i.e. `"1600 Pennsylvania Ave NW,
#'   Washington"`) or a vector of addresses (`c("Madrid", "Barcelona")`).
#' @param lat	latitude column name (i.e. `"lat"`).
#' @param long	longitude column name (i.e. `"long"`).
#' @param limit	maximum number of results to return per input address. Note
#'   that each query returns a maximum of 50 results.
#' @param custom_query API-specific parameters to be used, passed as a named
#'   list (i.e. `list(countrycodes = "US")`). See Details.
#'
#' @inheritParams tidygeocoder::geo
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @return A `tibble` with the results.
#'
#' @examples
#' \donttest{
#' geo_lite("Madrid, Spain")
#'
#' # Several addresses
#' geo_lite(c("Madrid", "Barcelona"))
#'
#' # With options: restrict search to USA
#' geo_lite(c("Madrid", "Barcelona"),
#'   custom_query = list(countrycodes = "US"),
#'   full_results = TRUE
#' )
#' }
#' @export
#'
#' @seealso [geo_lite_sf()], [tidygeocoder::geo()]
#' @family geocoding
geo_lite <- function(address,
                     lat = "lat",
                     long = "lon",
                     limit = 1,
                     full_results = FALSE,
                     return_addresses = TRUE,
                     verbose = FALSE,
                     custom_query = list()) {
  address <- unique(address)

  # nocov start

  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))

    limit <- min(50, limit)
  }

  # nocov end

  # Loop
  all_res <- NULL

  for (i in seq_len(length(address))) {
    if (i > 1) {
      Sys.sleep(1)
    }

    res_single <- geo_lite_single(
      address = address[i],
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query
    )
    all_res <- dplyr::bind_rows(all_res, res_single)
  }

  return(all_res)
}

#' @noRd
#' @inheritParams geo_lite

geo_lite_single <- function(address,
                            lat = "lat",
                            long = "lon",
                            limit = 1,
                            full_results = TRUE,
                            return_addresses = TRUE,
                            verbose = FALSE,
                            custom_query = list()) {
  api <- "https://nominatim.openstreetmap.org/search?q="

  # Replace spaces with +
  address2 <- gsub(" ", "+", address)

  # Compose url
  url <- paste0(api, address2, "&format=json&limit=", limit)

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

  json <- tempfile(fileext = ".json")
  
  # nocov start
  res <- tryCatch(
    download.file(url, json, mode = "wb", quiet = isFALSE(verbose)),
    warning = function(e) {
      return(NULL)
    },
    error = function(e) {
      return(NULL)
    }
  )

  if (is.null(res)) {
    message(url, " not reachable. Returning NULL.")
    return(NULL)
  }
# nocov end


  result <- tibble::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  if (nrow(result) > 0) {
    result$lat <- as.double(result$lat)
    result$lon <- as.double(result$lon)
  }
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  if (nrow(result) == 0) {
    warning("No results for query ", address, call. = FALSE)
    result_out <- tibble::tibble(query = address, a = NA, b = NA)
    names(result_out) <- c("query", lat, long)
    return(result_out)
  }

  # Rename
  names(result) <- gsub("address.", "", names(result))
  names(result) <- gsub("namedetails.", "", names(result))
  names(result) <- gsub("display_name", "address", names(result))


  # Prepare output
  result_out <- tibble::tibble(query = address)


  # Output
  result_out <- cbind(result_out, result[lat], result[long])

  if (return_addresses || full_results) {
    disp_name <- result["address"]
    result_out <- cbind(result_out, disp_name)
  }


  # If full
  if (full_results) {
    rest_cols <- result[, !names(result) %in% c(long, lat, "address")]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <- tibble::as_tibble(result_out)

  return(result_out)
}
