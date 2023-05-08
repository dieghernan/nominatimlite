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

# tibble helpers ----

empty_tbl <- function(x, lat, lon) {
  init_nm <- names(x)
  x <- dplyr::as_tibble(x)
  x$lat <- as.double(NA)
  x$lon <- x$lat

  names(x) <- c(init_nm, lat, lon)

  x
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
