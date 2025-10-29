#' Address search API (free-form query)
#'
#' @description
#' Geocodes addresses given as character values. This function returns the
#' [`tibble`][tibble::tibble] associated with the query, see [geo_lite_sf()] for
#' retrieving the data as a spatial object ([`sf`][sf::st_sf] format).
#'
#' This function correspond to the **free-form query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/develop/api/Search/).
#'
#' @family geocoding
#'
#' @param address `character` with single line address, e.g.
#'   (`"1600 Pennsylvania Ave NW, Washington"`) or a vector of addresses
#'   (`c("Madrid", "Barcelona")`).
#' @param lat	Latitude column name in the output data (default  `"lat"`).
#' @param long Longitude column name in the output data (default  `"long"`).
#' @param limit	Maximum number of results to return per input address. Note
#'   that each query returns a maximum of 50 results.
#' @param full_results Returns all available data from the API service.
#'    If `FALSE` (default) only latitude, longitude and address columns are
#'    returned. See also `return_addresses`.
#' @param return_addresses Return input addresses with results if `TRUE`.
#' @param verbose If `TRUE` then detailed logs are output to the console.
#' @param nominatim_server The URL of the Nominatim server to use.
#'    Defaults to `"https://nominatim.openstreetmap.org/"`.
#' @param progressbar Logical. If `TRUE` displays a progress bar to indicate
#'   the progress of the function.
#' @param custom_query A named list with API-specific parameters to be used
#'   (i.e. `list(countrycodes = "US")`). See **Details**.
#'
#'
#' @details
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#' @return
#'
#' ```{r child = "man/chunks/tibbleout.Rmd"}
#' ```
#'
#'
#' @seealso
#' [geo_lite_sf()], [tidygeocoder::geo()].
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
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
geo_lite <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list()
) {
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

  all_res <- lapply(seql, function(x) {
    ad <- key[x]
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }
    geo_lite_single(
      address = ad,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      nominatim_server = nominatim_server,
      custom_query
    )
  })
  if (progressbar) {
    close(pb)
  }

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  return(all_res)
}

#' @noRd
#' @inheritParams geo_lite

geo_lite_single <- function(
  address,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = TRUE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  # First build the api address. If the passed nominatim_server does not end
  # with a trailing forward-slash, add one
  api <- prepare_api_url(nominatim_server, "search?q=")

  # Replace spaces with +
  address2 <- gsub(" ", "+", address)

  # Compose url
  url <- paste0(api, address2, "&format=jsonv2&limit=", limit)

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = address)

  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(json, flatten = TRUE))

  # Rename lat and lon
  nmes <- names(result)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long

  names(result) <- nmes

  # Empty query
  if (nrow(result) == 0) {
    message("No results for query ", address)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Coords as double
  result[lat] <- as.double(result[[lat]])
  result[long] <- as.double(result[[long]])

  # Add query
  result_clean <- result
  result_clean$query <- address

  # Keep names
  result_out <- keep_names(
    result_clean,
    return_addresses,
    full_results,
    colstokeep = c("query", lat, long)
  )

  # As tibble
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
