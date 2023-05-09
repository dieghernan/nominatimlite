# General ----
add_custom_query <- function(custom_query = list(), url) {
  if (any(length(custom_query) == 0, isFALSE(is_named(custom_query)))) {
    return(url)
  }

  opts <- paste0(names(custom_query), "=", custom_query, collapse = "&")

  end_url <- paste0(url, "&", opts)

  end_url
}

is_named <- function(x) {
  nm <- names(x)

  if (is.null(nm)) {
    return(FALSE)
  }
  if (any(is.na(nm))) {
    return(FALSE)
  }
  if (any(nm == "")) {
    return(FALSE)
  }

  return(TRUE)
}


keep_names <- function(x, return_addresses, full_results,
                       colstokeep = "query") {
  names(x) <- gsub("address.", "", names(x))
  names(x) <- gsub("namedetails.", "", names(x))
  names(x) <- gsub("display_name", "address", names(x))

  out_cols <- colstokeep
  if (return_addresses) out_cols <- c(out_cols, "address")
  if (full_results) out_cols <- c(out_cols, "address", names(x))

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  return(out)
}

keep_names_rev <- function(x, address = "address", return_coords = FALSE,
                           full_results = FALSE,
                           colstokeep = address) {
  names(x) <- gsub("display_name", address, names(x))

  out_cols <- colstokeep
  if (return_coords) out_cols <- c(out_cols, "lat", "lon")
  if (full_results) out_cols <- c(out_cols, "lat", "lon", names(x))

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  return(out)
}

# tibble helpers ----

empty_tbl <- function(x, lat, lon) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$lat <- as.double(NA)
  x$lon <- x$lat

  names(x) <- c(init_nm, lat, lon)

  x
}

empty_tbl_rev <- function(x, address) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$n <- as.character(NA)

  names(x) <- c(init_nm, address)

  # Reorder
  x <- x[, c(address, init_nm)]

  x
}


unnest_reverse <- function(x) {
  # Unnest fields

  lngths <- vapply(x, length, FUN.VALUE = numeric(1))
  endobj <- dplyr::as_tibble(x[lngths == 1])

  # OSM address
  if ("address" %in% names(lngths)) {
    ad <- dplyr::as_tibble(x$address)[1, ]
    endobj <- dplyr::bind_cols(endobj, ad)
  }

  if ("extratags" %in% names(lngths)) {
    xtra <- dplyr::as_tibble(x$extratags)[1, ]
    endobj <- dplyr::bind_cols(endobj, xtra)
  }

  if ("boundingbox" %in% names(lngths)) {
    bb <- dplyr::tibble(boundingbox = list(as.double(x$boundingbox)))
    endobj <- dplyr::bind_cols(endobj, bb)
  }

  endobj
}
# sf helpers----
empty_sf <- function(x) {
  x <- dplyr::as_tibble(x)
  x$geometry <- "POINT EMPTY"

  out <- sf::st_as_sf(x, wkt = "geometry", crs = 4326)

  out
}

sf_to_tbl <- function(x) {
  out <- sf::st_drop_geometry(x)
  out <- dplyr::as_tibble(out)
  thegeom <- sf::st_geometry(x)
  out$geometry <- sf::st_as_text(thegeom)
  result_out <- sf::st_as_sf(out, wkt = "geometry", crs = 4326)
  result_out <- sf::st_make_valid(result_out)

  result_out
}

unnest_sf <- function(x) {
  # Unnest
  if (!("address" %in% names(x))) {
    return(x)
  }

  # Need to unnest
  add <- as.character(x$address)
  newadd <- lapply(add, function(x) {
    df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
    dplyr::as_tibble(df)
  })

  newadd <- dplyr::bind_rows(newadd)

  newsfobj <- x
  newsfobj <- x[, setdiff(names(x), "address")]
  x <- dplyr::bind_cols(newsfobj, newadd)

  x
}
