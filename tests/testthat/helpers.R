skip_if_api_server <- function() {
  if (nominatim_check_access()) {
    return(invisible(TRUE))
  }

  testthat::skip("Nominatim API is not reachable.")

  invisible()
}
