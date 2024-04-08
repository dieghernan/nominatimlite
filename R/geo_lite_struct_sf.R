#' Address search API for OSM elements in \CRANpkg{sf} format (structured query)
#'
#' @description
#' Geocodes addresses already split into components and return the corresponding
#' spatial object. This function returns the spatial object associated with the
#' query using \CRANpkg{sf}, see [geo_lite_struct()] for retrieving the data in
#' [`tibble`][tibble::tibble] format.
#'
#' This function correspond to the **structured query** search described in the
#' [API endpoint](https://nominatim.org/release-docs/develop/api/Search/). For
#' performing a free-form search use [geo_lite_sf()].
#'
#' @family geocoding
#' @family spatial
#'
#' @inheritParams geo_lite_struct
#' @inheritParams geo_lite_sf
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
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @return
#'
#' ```{r child = "man/chunks/sfout.Rmd"}
#' ```
#'
#' @seealso
#' [geo_lite_struct()].
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Map
#'
#' pl_mayor <- geo_lite_struct_sf(
#'   street = "Plaza Mayor",
#'   county = "Comunidad de Madrid",
#'   country = "Spain", limit = 50,
#'   full_results = TRUE, verbose = TRUE
#' )
#'
#' # Outline
#' ccaa <- geo_lite_sf("Comunidad de Madrid, Spain", points_only = FALSE)
#'
#' library(ggplot2)
#'
#' if (any(!sf::st_is_empty(pl_mayor), !sf::st_is_empty(ccaa))) {
#'   ggplot(ccaa) +
#'     geom_sf() +
#'     geom_sf(data = pl_mayor, aes(shape = addresstype, color = addresstype))
#' }
#' }
geo_lite_struct_sf <- function(
    amenity = NULL, street = NULL, city = NULL, county = NULL, state = NULL,
    country = NULL, postalcode = NULL, limit = 1, full_results = FALSE,
    return_addresses = TRUE, verbose = FALSE,
    nominatim_server = "https://nominatim.openstreetmap.org/",
    custom_query = list(), points_only = TRUE) {
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
    out <- empty_sf(tbl_query)
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
  url <- paste0(api, "format=geojson&limit=", limit)

  if (full_results) url <- paste0(url, "&addressdetails=1")
  if (!isTRUE(points_only)) url <- paste0(url, "&polygon_geojson=1")

  # Clean and add options
  newopts <- c(pars, custom_query)

  logis <- vapply(newopts, function(x) {
    any(is.na(x), is.null(x))
  }, FUN.VALUE = logical(1))


  newopts <- newopts[!logis]
  url <- add_custom_query(newopts, url)

  # Download to temp file
  json <- tempfile(fileext = ".geojson")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Empty query
  if (length(names(sfobj)) == 1) {
    message("No results for query")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Prepare output

  # Unnest address
  sfobj <- unnest_sf(sfobj)



  # Prepare output
  sf_clean <- sfobj

  # Naming order
  sf_clean <- dplyr::bind_cols(
    sf_clean,
    tbl_query[rep(1, nrow(sf_clean)), ]
  )

  # Keep names
  result_out <- keep_names(sf_clean, return_addresses, full_results,
    colstokeep = names(tbl_query)
  )

  # Attach as tibble
  result_out <- sf_to_tbl(result_out)

  result_out
}
