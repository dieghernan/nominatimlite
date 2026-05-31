# General ----
cap_limit <- function(limit) {
  if (limit <= 50) {
    return(limit)
  }

  message(paste0(
    "Nominatim returns at most 50 results. ",
    "`limit` has been set to 50."
  ))
  min(50, limit)
}

progress_lapply <- function(n, progressbar, f) {
  progressbar <- all(progressbar, n > 1)

  if (progressbar) {
    pb <- txtProgressBar(min = 0, max = n, width = 50, style = 3)
    on.exit(close(pb))
  }

  lapply(seq_len(n), function(i) {
    if (progressbar) {
      setTxtProgressBar(pb, i)
    }
    f(i)
  })
}

cap_coordinates <- function(lat, long) {
  if (!is.numeric(lat) || !is.numeric(long)) {
    stop("`lat` and `long` must be numeric.")
  }

  if (length(lat) != length(long)) {
    stop("`lat` and `long` must have the same number of elements.")
  }

  lat_cap <- pmax(pmin(lat, 90), -90)
  if (!identical(lat_cap, lat)) {
    message("Latitude values have been restricted to the range [-90, 90].")
  }

  long_cap <- pmax(pmin(long, 180), -180)
  if (!all(long_cap == long)) {
    message("Longitude values have been restricted to the range [-180, 180].")
  }

  list(lat = lat_cap, long = long_cap)
}

rename_coordinate_cols <- function(x, lat = "lat", long = "lon") {
  nmes <- names(x)
  nmes[nmes == "lat"] <- lat
  nmes[nmes == "lon"] <- long
  names(x) <- nmes

  x
}

convert_coordinate_cols <- function(x, lat = "lat", long = "lon") {
  x[lat] <- as.double(x[[lat]])
  x[long] <- as.double(x[[long]])

  x
}

normalize_bbox <- function(bbox) {
  if (any(inherits(bbox, "sf"), inherits(bbox, "sfc"))) {
    bbox <- sf::st_transform(bbox, 4326)
    bbox <- sf::st_bbox(bbox)
  }

  as.vector(bbox)
}

structured_query_params <- function(
  amenity = NULL,
  street = NULL,
  city = NULL,
  county = NULL,
  state = NULL,
  country = NULL,
  postalcode = NULL
) {
  pars <- list(
    amenity = amenity[1],
    street = street[1],
    city = city[1],
    county = county[1],
    state = state[1],
    country = country[1],
    postalcode = postalcode[1]
  )

  lapply(pars, function(x) {
    if (is.null(x)) {
      return(NA_character_)
    }
    as.character(x)
  })
}

structured_query_tbl <- function(pars) {
  tbl_query <- dplyr::as_tibble(pars)
  names(tbl_query) <- paste0("q_", names(tbl_query))

  tbl_query
}

compact_query_options <- function(x) {
  is_missing <- vapply(
    x,
    function(option) {
      any(is.null(option), is.na(option))
    },
    FUN.VALUE = logical(1)
  )

  x[!is_missing]
}

encode_query_value <- function(x) {
  if (is.logical(x)) {
    x <- ifelse(isTRUE(x), 1, 0)
  }
  paste0(x, collapse = ",")
}

encode_search_text <- function(x) {
  gsub(" ", "+", x, fixed = TRUE)
}

add_address_details <- function(url, full_results, always = FALSE) {
  if (isTRUE(full_results)) {
    return(paste0(url, "&addressdetails=1"))
  }

  if (always) {
    return(paste0(url, "&addressdetails=0"))
  }

  url
}

add_polygon_geojson <- function(url, points_only) {
  if (!isTRUE(points_only)) {
    return(paste0(url, "&polygon_geojson=1"))
  }

  url
}

build_search_url <- function(
  nominatim_server,
  format,
  limit,
  full_results,
  custom_query = list(),
  query = NULL,
  points_only = TRUE
) {
  if (is.null(query)) {
    url <- paste0(
      prepare_api_url(nominatim_server, "search?"),
      "format=",
      format,
      "&limit=",
      limit
    )
  } else {
    url <- paste0(
      prepare_api_url(nominatim_server, "search?q="),
      encode_search_text(query),
      "&format=",
      format,
      "&limit=",
      limit
    )
  }

  url <- add_address_details(url, full_results)
  url <- add_polygon_geojson(url, points_only)
  add_custom_query(custom_query, url)
}

build_reverse_url <- function(
  nominatim_server,
  lat,
  long,
  format,
  full_results,
  custom_query = list(),
  points_only = TRUE
) {
  url <- paste0(
    prepare_api_url(nominatim_server, "reverse?"),
    "lat=",
    lat,
    "&lon=",
    long,
    "&format=",
    format
  )

  url <- add_polygon_geojson(url, points_only)
  url <- add_address_details(url, full_results, always = TRUE)
  add_custom_query(custom_query, url)
}

build_lookup_url <- function(
  nominatim_server,
  nodes,
  full_results,
  custom_query = list()
) {
  url <- paste0(
    prepare_api_url(nominatim_server, "lookup?"),
    "osm_ids=",
    nodes,
    "&format=jsonv2"
  )

  url <- add_address_details(url, full_results)
  add_custom_query(custom_query, url)
}

reverse_query_keys <- function(lat, long) {
  coords <- cap_coordinates(lat, long)
  init_key <- dplyr::tibble(
    lat_key_int = lat,
    long_key_int = long,
    lat_cap_int = coords$lat,
    long_cap_int = coords$long
  )

  list(
    init = init_key,
    unique = dplyr::distinct(init_key)
  )
}

run_reverse_queries <- function(key, progressbar, f) {
  all_res <- progress_lapply(nrow(key), progressbar, function(i) {
    rw <- key[i, ]
    res_single <- f(
      lat_cap = as.double(rw$lat_cap_int),
      long_cap = as.double(rw$long_cap_int)
    )

    dplyr::bind_cols(res_single, rw[, c(1, 2)])
  })

  dplyr::bind_rows(all_res)
}

add_custom_query <- function(custom_query = list(), url) {
  if (any(length(custom_query) == 0, isFALSE(is_named(custom_query)))) {
    return(url)
  }

  custom_query <- lapply(custom_query, encode_query_value)

  opts <- paste0(names(custom_query), "=", custom_query, collapse = "&")

  end_url <- paste0(url, "&", opts)

  end_url
}

is_named <- function(x) {
  nm <- names(x)

  if (is.null(nm)) {
    return(FALSE)
  }
  if (anyNA(nm)) {
    return(FALSE)
  }
  if (any(nm == "")) {
    return(FALSE)
  }

  TRUE
}

keep_names <- function(
  x,
  return_addresses,
  full_results,
  colstokeep = "query"
) {
  x$address <- x$display_name
  if ("boundingbox" %in% names(x)) {
    bbun <- lapply(x$boundingbox, function(y) {
      unl <- unlist(y)
      bb <- dplyr::tibble(boundingbox = list(as.double(unl)))
      bb
    })
    bbun <- dplyr::bind_rows(bbun)
    cln <- x[, names(x) != "boundingbox"]
    x <- dplyr::bind_cols(cln, bbun)
  }

  out_cols <- colstokeep
  if (return_addresses) {
    out_cols <- c(out_cols, "address")
  }
  if (full_results) {
    out_cols <- c(out_cols, "address", names(x))
  }

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  out
}

keep_names_rev <- function(
  x,
  address = "address",
  return_coords = FALSE,
  full_results = FALSE,
  colstokeep = address
) {
  x$xxxyyyzzz <- x$display_name
  nm <- names(x)
  nm <- gsub("xxxyyyzzz", address, nm, fixed = TRUE)
  names(x) <- nm
  out_cols <- colstokeep
  if (return_coords) {
    out_cols <- c(out_cols, "lat", "lon")
  }
  if (full_results) {
    out_cols <- c(out_cols, "lat", "lon", names(x))
  }

  out_cols <- unique(out_cols)
  out <- x[, out_cols]

  out
}

prepare_api_url <- function(
  nominatim_server = "https://nominatim.openstreetmap.org/",
  entry
) {
  api <- paste0(gsub("/$", "", nominatim_server), "/", entry)
  api
}

# Tibble helpers ----

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

  # Put the address column first.
  x <- x[, c(address, init_nm)]

  x
}

unnest_reverse <- function(x) {
  # Unnest nested fields.

  lngths <- lengths(x)

  # Remove null fields.
  x <- x[lngths > 0]

  endobj <- dplyr::as_tibble(x[lngths == 1])

  # Add OSM address fields.
  if ("address" %in% names(x)) {
    ad <- dplyr::as_tibble(x$address)[1, ]
    names(ad) <- paste0("address.", names(ad))

    endobj <- dplyr::bind_cols(endobj, ad)
  }

  if ("extratags" %in% names(x)) {
    xtra <- dplyr::as_tibble(x$extratags)[1, ]
    names(xtra) <- paste0("extratags.", names(xtra))
    endobj <- dplyr::bind_cols(endobj, xtra)
  }

  if ("boundingbox" %in% names(x)) {
    bb <- dplyr::tibble(boundingbox = list(as.double(x$boundingbox)))
    endobj <- dplyr::bind_cols(endobj, bb)
  }

  endobj
}
# sf helpers ----
empty_sf <- function(x) {
  x <- dplyr::as_tibble(x)
  x$geometry <- "POINT EMPTY"

  out <- sf::st_as_sf(x, wkt = "geometry", crs = sf::st_crs(4326))

  out
}

sf_to_tbl <- function(x) {
  if (all(!inherits(x, "tbl"), inherits(x, "sf"))) {
    # Add the expected `sf` tibble classes when they are missing.
    template <- class(empty_sf(dplyr::tibble(a = 1)))
    class(x) <- template
  }

  # Reorder columns, because geometry stays last even when not selected.
  x <- x[, setdiff(names(x), "geometry")]

  result_out <- sf::st_make_valid(x)

  result_out
}

unnest_sf <- function(x) {
  # Unnest nested fields.
  if ("address" %in% names(x)) {
    # Unnest address fields.
    add <- as.character(x$address)
    newadd <- lapply(add, function(x) {
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })

    newadd <- dplyr::bind_rows(newadd)
    names(newadd) <- paste0("address.", names(newadd))

    newsfobj <- x
    newsfobj <- x[, setdiff(names(x), "address")]
    x <- dplyr::bind_cols(newsfobj, newadd)
  }

  if ("extratags" %in% names(x)) {
    # Unnest extra tag fields.
    xtra <- as.character(x$extratags)

    newxtra <- lapply(xtra, function(x) {
      if (any(is.null(x), is.na(x))) {
        return(dplyr::tibble(xxx_empty_remove = NA))
      }
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })

    newxtra <- dplyr::bind_rows(newxtra)
    names(newxtra) <- paste0("extratags.", names(newxtra))

    newsfobj <- x
    newsfobj <- x[, setdiff(names(x), "extratags")]
    x <- dplyr::bind_cols(newsfobj, newxtra)
    x <- x[, setdiff(names(x), "extratags.xxx_empty_remove")]
  }

  x <- sf_to_tbl(x)

  x
}

unnest_sf_reverse <- function(x) {
  # Remove null fields.
  nulls_or_nas <- vapply(
    x,
    function(a_col) {
      any(is.null(a_col), is.na(a_col))
    },
    FUN.VALUE = logical(1)
  )

  x <- x[!nulls_or_nas]

  # Unnest nested fields.
  if ("address" %in% names(x)) {
    # Unnest address fields.
    add <- as.character(x$address)
    newadd <- lapply(add, function(x) {
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })

    newadd <- dplyr::bind_rows(newadd)[1, ]
    names(newadd) <- paste0("address.", names(newadd))

    newsfobj <- x
    newsfobj <- x[, setdiff(names(x), "address")]
    x <- dplyr::bind_cols(newsfobj, newadd)
  }

  if ("extratags" %in% names(x)) {
    # Unnest extra tag fields.
    xtra <- as.character(x$extratags)

    newxtra <- lapply(xtra, function(x) {
      df <- jsonlite::fromJSON(x, simplifyVector = TRUE)
      dplyr::as_tibble(df)
    })

    newxtra <- dplyr::bind_rows(newxtra)[1, ]
    names(newxtra) <- paste0("extratags.", names(newxtra))

    newsfobj <- x
    newsfobj <- x[, setdiff(names(x), "extratags")]
    x <- dplyr::bind_cols(newsfobj, newxtra)
  }

  x <- sf_to_tbl(x)

  x
}
