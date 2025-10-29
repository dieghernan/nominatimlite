#' Geocode amenities
#'
#' @description
#' This function search [amenities][osm_amenities] as defined by OpenStreetMap
#' on a restricted area defined by a bounding box in the form
#' `(<xmin>, <ymin>, <xmax>, <ymax>)`. This function returns the
#' [`tibble`][tibble::tibble] associated with the query, see [geo_amenity_sf()]
#' for retrieving the data as a spatial object ([`sf`][sf::st_sf] format).
#'
#' @family amenity
#' @family geocoding
#'
#' @param bbox The bounding box (viewbox) used to limit the search. It could be:
#'   - A numeric vector of **longitude** (`x`) and **latitude** (`y`)
#'   `(xmin, ymin, xmax, ymax)`. See **Details**.
#'   - A [`sf`][sf::st_sf] or [`sfc`][sf::st_sfc] object.
#' @param amenity A `character` (or a vector of `character`s) with the
#'   amenities to be geolocated (i.e. `c("pub", "restaurant")`). See
#'   [nominatimlite::osm_amenities].
#' @param strict Logical `TRUE/FALSE`. Force the results to be included inside
#' the `bbox`. Note that Nominatim default behavior may return results located
#' outside the provided bounding box.
#' @inheritParams geo_lite_struct
#' @inheritParams geo_lite
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
#' @return
#'
#' ```{r child = "man/chunks/tibbleout.Rmd"}
#' ```
#'
#' @export
#'
#' @examplesIf nominatim_check_access()
#' \donttest{
#' # Times Square, NY, USA
#' bbox <- c(
#'   -73.9894467311, 40.75573629,
#'   -73.9830630737, 40.75789245
#' )
#'
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = "restaurant"
#' )
#'
#' # Several amenities
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = c("restaurant", "pub")
#' )
#'
#' # Increase limit and use with strict
#' geo_amenity(
#'   bbox = bbox,
#'   amenity = c("restaurant", "pub"),
#'   limit = 10,
#'   strict = TRUE
#' )
#' }
geo_amenity <- function(
  bbox,
  amenity,
  lat = "lat",
  long = "lon",
  limit = 1,
  full_results = FALSE,
  return_addresses = TRUE,
  verbose = FALSE,
  nominatim_server = "https://nominatim.openstreetmap.org/",
  progressbar = TRUE,
  custom_query = list(),
  strict = FALSE
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

    geo_lite_struct(
      amenity = ad,
      lat = lat,
      long = long,
      limit = limit,
      full_results = full_results,
      return_addresses = return_addresses,
      verbose = verbose,
      nominatim_server = nominatim_server,
      custom_query = custom_query
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

  if (strict) {
    bbox_sf <- bbox_to_poly(bbox)
    all_res_sf <- sf::st_as_sf(all_res, coords = c("lon", "lat"), crs = 4326)

    int <- as.vector(sf::st_intersects(all_res_sf, bbox_sf, sparse = FALSE))
    all_res <- all_res[int, ]
  }

  return(all_res)
}
