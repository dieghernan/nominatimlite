#' Get spatial objects of amenities
#'
#' @description
#' This function search amenities as defined by OpenStreetMap on a restricted
#' area defined by
#' a bounding box in the form of (<min_latitude>, <min_longitude>,
#' <max_latitude>, <max_longitude>).
#'
#' @inheritParams geo_amenity
#' @inheritParams geo_lite_sf
#'
#' @return A `sf` object with the results.
#'
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity>.
#'
#' @seealso [geo_amenity], [nominatimlite::osm_amenities]
#'
#' @examples
#' # Madrid, Spain
#'
#' library(ggplot2)
#'
#' bbox <- c(
#'   -3.888954, 40.311977,
#'   -3.517916, 40.643729
#' )
#'
#' # Restaurants and pubs
#'
#' rest_pub <- geo_amenity_sf(bbox,
#'   c("restaurant", "pub"),
#'   limit = 50
#' )
#'
#'
#' ggplot(rest_pub) +
#'   geom_sf()
#'
#' # Hospital as polygon
#'
#' hosp <- geo_amenity_sf(bbox,
#'   "hospital",
#'   polygon = TRUE
#' )
#'
#' ggplot(hosp) +
#'   geom_sf()
#' @export
geo_amenity_sf <- function(bbox,
                           amenity,
                           limit = 1,
                           full_results = FALSE,
                           return_addresses = TRUE,
                           verbose = FALSE,
                           custom_query = list(),
                           polygon = FALSE) {
  amenity <- unique(amenity)

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

  for (i in seq_len(length(amenity))) {
    res_single <- geo_amenity_sf_single(
      bbox = bbox,
      amenity = amenity[i],
      limit,
      full_results,
      return_addresses,
      verbose,
      custom_query,
      polygon
    )
    all_res <- dplyr::bind_rows(all_res, res_single)
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
                                  polygon = FALSE) {
  bbox_txt <- paste0(bbox, collapse = ",")


  api <- "https://nominatim.openstreetmap.org/search?"

  url <- paste0(
    api, "viewbox=",
    bbox_txt,
    "&amenity=",
    amenity,
    "&format=geojson&limit=", limit
  )

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  if (isTRUE(polygon)) {
    url <- paste0(url, "&polygon_geojson=1")
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

  if (!"bounded" %in% names(custom_query)) {
    url <- paste0(url, "&bounded=1")
  }

  # Download

  json <- tempfile(fileext = ".geojson")

  download.file(url, json, mode = "wb", quiet = isFALSE(verbose))


  sfobj <- sf::st_read(json,
    stringsAsFactors = FALSE,
    quiet = isFALSE(verbose)
  )


  # Check if null and return

  if (length(names(sfobj)) == 1) {
    warning("No results for query ", amenity, call. = FALSE)
    result_out <- data.frame(query = amenity)
    return(result_out)
  }


  # Prepare output
  result_out <- data.frame(query = amenity)

  df_sf <- tibble::as_tibble(sf::st_drop_geometry(sfobj))

  # Rename original address

  names(df_sf) <-
    gsub("address", "osm.address", names(df_sf))

  names(df_sf) <- gsub("display_name", "address", names(df_sf))

  if (return_addresses || full_results) {
    disp_name <- df_sf["address"]
    result_out <- cbind(result_out, disp_name)
  }

  # If full
  if (full_results) {
    rest_cols <- df_sf[, !names(df_sf) %in% c("address")]
    result_out <- cbind(result_out, rest_cols)
  }

  result_out <- sf::st_sf(result_out, geometry = sf::st_geometry(sfobj))
  return(result_out)
}
