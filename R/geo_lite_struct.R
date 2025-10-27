#' Address search API (structured query)
#'
#' @description
#' Geocodes addresses already split into components. This function returns the
#' [`tibble`][tibble::tibble] associated with the query, see
#' [geo_lite_struct_sf()] for retrieving the data as a spatial object
#' ([`sf`][sf::st_sf] format).
#'
#' This function correspond to the **structured query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/develop/api/Search/). For
#' performing a free-form search use [geo_lite()].
#'
#' @family geocoding
#'
#' @param amenity Name and/or type of POI, see also [geo_amenity].
#' @param street House number and street name.
#' @param city City.
#' @param county County.
#' @param state State.
#' @param country Country.
#' @param postalcode Postal Code.
#' @inheritParams geo_lite
#'
#'
#' @details
#'
#' The structured form of the search query allows to look up up an address that
#' is already split into its components. Each parameter represents a field of
#' the address. All parameters are optional. You should only use the ones that
#' are relevant for the address you want to geocode.
#'
#'
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
#' [geo_lite_struct_sf()], [tidygeocoder::geo()].
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' pl_mayor <- geo_lite_struct(
#'   street = "Plaza Mayor", country = "Spain",
#'   limit = 50, full_results = TRUE
#' )
#'
#'
#' dplyr::glimpse(pl_mayor)
#' }
geo_lite_struct <- function(
  amenity = NULL, street = NULL, city = NULL, county = NULL, state = NULL,
  country = NULL, postalcode = NULL, lat = "lat", long = "lon", limit = 1,
  full_results = FALSE, return_addresses = TRUE, verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  custom_query = list()
) {
  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }

  # Check params, not vectorized
  pars <- list(
    amenity = amenity[1],
    street = street[1],
    city = city[1],
    county = county[1],
    state = state[1],
    country = country[1],
    postalcode = postalcode[1]
  )

  pars <- lapply(pars, function(x) {
    if (is.null(x)) {
      return(NA_character_)
    }
    a_char <- as.character(x)
    a_char
  })

  tbl_query <- dplyr::as_tibble(pars)
  names(tbl_query) <- paste0("q_", names(tbl_query))

  if (all(is.na(pars))) {
    message("Nothing to search for.")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Paste +
  pars <- lapply(pars, function(x) {
    gsub(" ", "+", x)
  })

  # First build the api address. If the passed nominatim_server does not end
  # with a trailing forward-slash, add one
  api <- prepare_api_url(nominatim_server, "search?")
  # Compose url
  url <- paste0(api, "format=jsonv2&limit=", limit)

  if (full_results) url <- paste0(url, "&addressdetails=1")

  # Clean and add options
  newopts <- c(pars, custom_query)

  logis <- vapply(newopts, function(x) {
    any(is.na(x), is.null(x))
  }, FUN.VALUE = logical(1))


  newopts <- newopts[!logis]
  url <- add_custom_query(newopts, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
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
    message("No results for query")
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }


  # Coords as double
  result[lat] <- as.double(result[[lat]])
  result[long] <- as.double(result[[long]])


  # Add query
  result_clean <- dplyr::bind_cols(
    tbl_query[rep(1, nrow(result)), ],
    result
  )

  # Keep names
  result_out <- keep_names(result_clean, return_addresses, full_results,
    colstokeep = c(names(tbl_query), lat, long)
  )

  # As tibble
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
