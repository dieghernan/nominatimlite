#' Geocode amenities in Spatial format
#'
#' @description
#' This function search amenities as defined by OpenStreetMap on a restricted
#' area defined by a bounding box in the form of
#' `(<min_latitude>, <min_longitude>, <max_latitude>, <max_longitude>)`. This
#' function returns the \CRANpkg{sf} spatial object associated with the query,
#' see [geo_amenity()] for retrieving the data in \CRANpkg{tibble} format.
#'
#' @inheritParams geo_lite_sf
#' @inheritParams geo_amenity
#'
#' @return A \CRANpkg{sf} object with the results.
#'
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity>.
#'
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @seealso [geo_amenity()]
#' @family amenity
#' @family geocoding
#' @family spatial
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Madrid, Spain
#'
#' library(ggplot2)
#'
#' bbox <- c(-3.888954, 40.311977, -3.517916, 40.643729)
#'
#' # Restaurants and pubs
#'
#' rest_pub <- geo_amenity_sf(bbox, c("restaurant", "pub"), limit = 50)
#'
#' if (any(!sf::st_is_empty(rest_pub))) {
#'   ggplot(rest_pub) +
#'     geom_sf()
#' }
#'
#' # Hospital as polygon
#'
#' hosp <- geo_amenity_sf(bbox, "hospital", points_only = FALSE)
#'
#' if (any(!sf::st_is_empty(hosp))) {
#'   ggplot(hosp) +
#'     geom_sf()
#' }
#' }
#' @export
geo_amenity_sf <- function(bbox,
                           amenity,
                           limit = 1,
                           full_results = FALSE,
                           return_addresses = TRUE,
                           verbose = FALSE,
                           custom_query = list(),
                           points_only = TRUE,
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
    geo_amenity_sf_single(
      bbox = bbox,
      amenity = x,
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query,
      points_only
    )
  })

  all_res <- dplyr::bind_rows(all_res)

  all_res <- sf_to_tbl(all_res)

  # Handle dupes in sf
  if (!identical(as.character(init_key$query), key)) {
    # Join with indexes
    template <- sf::st_drop_geometry(all_res)[, "query"]
    template$rindex <- seq_len(nrow(template))
    getrows <- dplyr::left_join(init_key, template, by = "query")

    # Select rows
    all_res <- all_res[as.integer(getrows$rindex), ]
    all_res <- sf_to_tbl(all_res)
  }

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    strict <- sf::st_covered_by(all_res, bbox_sf, sparse = FALSE)
    all_res <- all_res[strict, ]
    all_res <- sf_to_tbl(all_res)
  }

  return(all_res)
}



#' @noRd
#' @inheritParams geo_amenity_sf
geo_amenity_sf_single <- function(bbox,
                                  amenity,
                                  limit = 1,
                                  full_results = TRUE,
                                  return_addresses = TRUE,
                                  verbose = FALSE,
                                  custom_query = list(),
                                  points_only = TRUE) {
  # Step 1: Download ----
  bbox_txt <- paste0(bbox, collapse = ",")
  api <- "https://nominatim.openstreetmap.org/search?"

  url <- paste0(
    api, "viewbox=", bbox_txt, "&q=[", amenity,
    "]&format=geojson&limit=", limit
  )


  if (full_results) url <- paste0(url, "&addressdetails=1")
  if (!isTRUE(points_only)) url <- paste0(url, "&polygon_geojson=1")
  if (!"bounded" %in% names(custom_query)) url <- paste0(url, "&bounded=1")

  # Add options
  url <- add_custom_query(custom_query, url)

  # Download to temp file
  json <- tempfile(fileext = ".geojson")
  res <- api_call(url, json, quiet = isFALSE(verbose))

  # Step 2: Read and parse results ----

  # Keep a tbl with the query
  tbl_query <- dplyr::tibble(query = amenity)

  # If no response...
  if (isFALSE(res)) {
    message(url, " not reachable.")
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }

  # Read
  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)

  # Empty query
  if (length(names(sfobj)) == 1) {
    message("No results for query ", amenity)
    out <- empty_sf(tbl_query)
    return(invisible(out))
  }


  # Prepare output

  # Unnest address
  sfobj <- unnest_sf(sfobj)



  # Prepare output
  sf_clean <- sfobj
  sf_clean$query <- amenity

  # Keep names
  result_out <- keep_names(sf_clean, return_addresses, full_results,
    colstokeep = "query"
  )

  # Attach as tibble
  result_out <- sf_to_tbl(result_out)

  result_out
}
