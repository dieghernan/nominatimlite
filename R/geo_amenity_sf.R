#' Geocode amenities in \CRANpkg{sf} format
#'
#' @description
#' This function search [amenities][osm_amenities] as defined by OpenStreetMap
#' on a restricted area defined by a bounding box in the form
#' `(<xmin>, <ymin>, <xmax>, <ymax>)`.  This function returns the spatial
#' object associated with the query using \CRANpkg{sf}, see [geo_amenity()] for
#' retrieving the data in [`tibble`][tibble::tibble] format.
#'
#' @family amenity
#' @family geocoding
#' @family spatial
#'
#' @inheritParams geo_amenity
#' @inheritParams geo_lite_sf
#'
#' @details
#'
#' Bounding boxes can be located using different online tools, as
#' [Bounding Box Tool](https://boundingbox.klokantech.com/).
#'
#' For a full list of valid amenities see
#' <https://wiki.openstreetmap.org/wiki/Key:amenity> and [osm_amenities].
#'
#' See <https://nominatim.org/release-docs/latest/api/Search/> for additional
#' parameters to be passed to `custom_query`.
#'
#'
#' @inheritSection  geo_lite_sf  About Geometry Types
#'
#' @return
#'
#' ```{r child = "man/chunks/sfout.Rmd"}
#' ```
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Usera, Madrid
#'
#' library(ggplot2)
#' mad <- geo_lite_sf("Usera, Madrid, Spain", points_only = FALSE)
#'
#'
#' # Restaurants, pubs and schools
#'
#' rest_pub <- geo_amenity_sf(mad, c("restaurant", "pub", "school"),
#'   limit = 50
#' )
#'
#' if (any(!sf::st_is_empty(rest_pub))) {
#'   ggplot(mad) +
#'     geom_sf() +
#'     geom_sf(data = rest_pub, aes(color = query, shape = query))
#' }
#' }
geo_amenity_sf <- function(
  bbox,
  amenity,
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE,
  points_only = TRUE
) {
  if (limit > 50) {
    message(paste(
      "Nominatim provides 50 results as a maximum. ",
      "Your query may be incomplete"
    ))
    limit <- min(50, limit)
  }

  # bbox types
  if (any(inherits(bbox, "sf"), inherits(bbox, "sfc"))) {
    tolonlat <- sf::st_transform(bbox, 4326)
    bbox <- as.vector(sf::st_bbox(tolonlat))
  }
  bbox <- as.vector(bbox)

  # Overwrite custom query
  custom_query <- as.list(custom_query)
  custom_query$viewbox <- bbox
  custom_query$bounded <- TRUE

  # Dedupe for query
  key <- unique(amenity)

  # Set progress bar
  ntot <- length(key)
  # Set progress bar if n > 1
  progressbar <- all(progressbar, ntot > 1)
  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = ntot, width = 50, style = 3)
  }
  seql <- seq(1, ntot, 1)

  seql <- seq(1, ntot, 1)

  all_res <- lapply(seql, function(x) {
    ad <- key[x]
    if (progressbar) {
      setTxtProgressBar(pb, x)
    }

    geo_lite_struct_sf(
      amenity = ad,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query,
      points_only = points_only
    )
  })
  if (progressbar) {
    close(pb)
  }

  all_res <- dplyr::bind_rows(all_res)

  # Clean columns and names
  nm <- names(all_res)
  nm[nm == "q_amenity"] <- "query"
  names(all_res) <- nm
  all_res <- all_res[, !grepl("^q_", nm)]
  all_res <- sf_to_tbl(all_res)

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    int <- as.vector(sf::st_intersects(all_res, bbox_sf, sparse = FALSE))
    all_res <- all_res[int, ]
  }

  all_res
}
