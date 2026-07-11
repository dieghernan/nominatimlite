skip_if_nominatim_unavailable <- function() {
  if (is.null(.nominatim_check_access)) {
    .nominatim_check_access <<- nominatim_check_access()
  }

  if (.nominatim_check_access) {
    return(invisible(TRUE))
  }

  testthat::skip("Nominatim API is not reachable.")

  invisible()
}

.nominatim_check_access <- NULL

skip_if_api_server <- skip_if_nominatim_unavailable

test_fixture <- function(...) {
  testthat::test_path("fixtures", ...)
}

mock_geo_tbl <- function(query, lat = "lat", lon = "lon") {
  out <- dplyr::tibble(
    query = query,
    lat = seq_along(query),
    lon = seq_along(query) * -1,
    address = paste("address", query)
  )
  names(out)[2:3] <- c(lat, lon)
  out
}

mock_reverse_tbl <- function(lat, lon, address = "address") {
  out <- dplyr::tibble(
    address = paste("address", lat, lon),
    lat = lat,
    lon = lon
  )
  names(out)[1] <- address
  out
}

mock_geo_sf <- function(query) {
  sf::st_as_sf(
    dplyr::tibble(
      query = query,
      address = paste("address", query),
      lon = seq_along(query) * -1,
      lat = seq_along(query)
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
}

mock_reverse_sf <- function(lat, lon, address = "address") {
  out <- sf::st_as_sf(
    dplyr::tibble(
      address = paste("address", lat, lon),
      lat = lat,
      lon = lon
    ),
    coords = c("lon", "lat"),
    crs = 4326,
    remove = FALSE
  )
  names(out)[1] <- address
  out
}
