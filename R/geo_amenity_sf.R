#' Geocode amenities in Spatial format
#'
#' @description
#' This function search amenities as defined by OpenStreetMap on a restricted
#' area defined by a bounding box in the form of
#' `(<min_latitude>, <min_longitude>, <max_latitude>, <max_longitude>)`. This
#' function returns the spatial object associated with the query, see
#' [geo_amenity()] for retrieving the data in `tibble` format.
#'
#' @inheritParams geo_lite_sf
#' @inheritParams geo_amenity
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
#' ggplot(rest_pub) +
#'   geom_sf()
#'
#' # Hospital as polygon
#'
#' hosp <- geo_amenity_sf(bbox, "hospital", points_only = FALSE)
#'
#' ggplot(hosp) +
#'   geom_sf()
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
  init_am <- dplyr::tibble(query = amenity)
  amenity <- unique(amenity)

  all_res <- lapply(amenity, function(x) {
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

  # Handle dupes in sf
  if (!identical(as.character(init_am$query), amenity)) {
    all_res <- dplyr::left_join(init_am, all_res, by = "query")

    # Convert back to sf
    all_res <- sf::st_as_sf(all_res, sf_column_name = "geometry", crs = 4326)
  }

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    strict <- sf::st_covered_by(all_res, bbox_sf, sparse = FALSE)
    all_res <- all_res[strict, ]
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
  bbox_txt <- paste0(bbox, collapse = ",")


  api <- "https://nominatim.openstreetmap.org/search?"

  url <- paste0(
    api, "viewbox=",
    bbox_txt,
    "&q=[",
    amenity,
    "]&format=geojson&limit=", limit
  )

  if (full_results) {
    url <- paste0(url, "&addressdetails=1")
  }

  if (!isTRUE(points_only)) {
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

  res <- api_call(url, json, isFALSE(verbose))
  if (isFALSE(res)) {
    message(url, " not reachable.")
    result_out <- data.frame(query = amenity)
    result_out$geometry <- "POINT EMPTY"
    result_out <- sf::st_as_sf(dplyr::as_tibble(result_out),
      wkt = "geometry",
      crs = 4326
    )
    return(invisible(result_out))
  }

  sfobj <- sf::read_sf(json, stringsAsFactors = FALSE)


  # Check if null and return

  if (length(names(sfobj)) == 1) {
    message("No results for query ", amenity)
    result_out <- data.frame(query = amenity)
    result_out$geometry <- "POINT EMPTY"
    result_out <- sf::st_as_sf(dplyr::as_tibble(result_out),
      wkt = "geometry",
      crs = 4326
    )
    return(invisible(result_out))
  }

  # Prepare output
  if ("address" %in% names(sfobj)) {
    add <- as.character(sfobj$address)

    newadd <- lapply(add, function(x) {
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })
    newadd <- dplyr::bind_rows(newadd)

    newsfobj <- sfobj
    newsfobj <- sfobj[, setdiff(names(sfobj), "address")]
    sfobj <- dplyr::bind_cols(newsfobj, newadd)
  }

  # Rename
  names(sfobj) <- gsub("address.", "", names(sfobj))
  names(sfobj) <- gsub("namedetails.", "", names(sfobj))
  names(sfobj) <- gsub("display_name", "address", names(sfobj))

  # Prepare output
  sfobj$query <- amenity


  df_sf <- sf::st_drop_geometry(sfobj)
  df_sf <- dplyr::as_tibble(df_sf)

  # Output cols
  out_cols <- "query"

  if (return_addresses) out_cols <- c(out_cols, "address")
  if (full_results) out_cols <- c(out_cols, "address", names(df_sf))

  out_cols <- unique(out_cols)
  out <- df_sf[, out_cols]

  # Construct final object
  thegeom <- sf::st_geometry(sfobj)
  thegeom <- sf::st_make_valid(thegeom)
  out$geometry <- sf::st_as_text(thegeom)
  result_out <- sf::st_as_sf(out, wkt = "geometry", crs = 4326)
  return(result_out)
}
