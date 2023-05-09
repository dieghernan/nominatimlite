#' Geocode amenities
#'
#' @description
#' This function search amenities as defined by OpenStreetMap on a restricted
#' area defined by a bounding box in the form of
#' `(<min_latitude>, <min_longitude>, <max_latitude>, <max_longitude>)`. This
#' function returns the `tibble` associated with the query, see
#' [geo_amenity_sf()] for retrieving the data as a spatial object
#' (((\pkg{sf}) format).
#'
#'
#' @param bbox A numeric vector of latitude and longitude
#'   `(<min_latitude>, <min_longitude>, <max_latitude>, <max_longitude>)` that
#'   restrict the search area. See **Details**.
#' @param amenity A character of a vector of character with the amenities to be
#'   geolocated (i.e. `c("pub", "restaurant")`). See **Details** and
#'   [nominatimlite::osm_amenities].
#' @param custom_query API-specific parameters to be used.
#'   See [nominatimlite::geo_lite()].
#' @param strict Logical `TRUE/FALSE`. Force the results to be included inside
#' the `bbox`. Note that Nominatim default behavior may return results located
#' outside the provided bounding box.
#'
#' @inheritParams geo_lite
#'
#' @return A `tibble` with the results.
#'
#' @seealso [geo_amenity_sf()]
#' @family amenity
#' @family geocoding
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity>.
#'
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Times Square, NY, USA
#' bbox <- c(-73.9894467311, 40.75573629, -73.9830630737, 40.75789245)
#'
#' geo_amenity(bbox = bbox, amenity = "restaurant")
#'
#' # Several amenities
#' geo_amenity(bbox = bbox, amenity = c("restaurant", "pub"))
#'
#' # Increase limit and use with strict
#' geo_amenity(
#'   bbox = bbox, amenity = c("restaurant", "pub"), limit = 10,
#'   strict = TRUE
#' )
#' }
#'
#' @export
geo_amenity <- function(bbox,
                        amenity,
                        lat = "lat",
                        long = "lon",
                        limit = 1,
                        full_results = FALSE,
                        return_addresses = TRUE,
                        verbose = FALSE,
                        custom_query = list(),
                        strict = FALSE) {
  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }


  # Dedupe for query
  amenity <- as.character(amenity)
  init_key <- dplyr::tibble(query = amenity)
  key <- unique(amenity)

  all_res <- lapply(key, function(x) {
    geo_amenity_single(
      bbox = bbox,
      amenity = x,
      lat,
      long,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query
    )
  })

  all_res <- dplyr::bind_rows(all_res)
  all_res <- dplyr::left_join(init_key, all_res, by = "query")

  if (strict) {
    strict <- all_res[lat] >= bbox[2] &
      all_res[lat] <= bbox[4] &
      all_res[long] >= bbox[1] &
      all_res[long] <= bbox[3]

    strict <- as.logical(strict)

    all_res <- all_res[strict, ]
  }



  return(all_res)
}



#' @noRd
#' @inheritParams geo_amenity
geo_amenity_single <- function(bbox,
                               amenity,
                               lat = "lat",
                               long = "lon",
                               limit = 1,
                               full_results = TRUE,
                               return_addresses = TRUE,
                               verbose = FALSE,
                               custom_query = list()) {
  # Step 1: Download ----
  bbox_txt <- paste0(bbox, collapse = ",")

  api <- "https://nominatim.openstreetmap.org/search?"

  url <- paste0(
    api, "viewbox=", bbox_txt, "&q=[", amenity,
    "]&format=json&limit=", limit
  )

  if (full_results) url <- paste0(url, "&addressdetails=1")
  if (!"bounded" %in% names(custom_query)) url <- paste0(url, "&bounded=1")

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".json")
  res <- api_call(url, json, isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = amenity)

  # If no response...
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
    message("No results for query ", amenity)
    out <- empty_tbl(tbl_query, lat, long)
    return(invisible(out))
  }

  # Coords as double
  result[lat] <- as.double(result[[lat]])
  result[long] <- as.double(result[[long]])

  # Add query
  result_clean <- result
  result_clean$query <- amenity

  # Keep names
  result_out <- keep_names(result_clean, return_addresses, full_results,
    colstokeep = c("query", lat, long)
  )

  # As tibble
  result_out <- dplyr::as_tibble(result_out)

  result_out
}
