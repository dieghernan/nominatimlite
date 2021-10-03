#' Check access to Nominatim API
#'
#' @concept helper
#'
#' @description
#' Check if R has access to resources at
#' <https://nominatim.openstreetmap.org>.
#'
#' @return a logical.
#'
#' @examples
#'
#' nominatim_check_access()
#' @keywords internal
#' @export
nominatim_check_access <- function() {
  url <- paste0(
    "https://nominatim.openstreetmap.org/search?q=",
    "Madrid&format=json&limit=1"
  )
  # nocov start
  access <-
    tryCatch(
      download.file(url, destfile = tempfile(), quiet = TRUE),
      warning = function(e) {
        return(FALSE)
      }
    )

  if (isFALSE(access)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
  # nocov end
}

skip_if_api_server <- function() {
  if (nominatim_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("Nominatim API not reachable")
  }
  return(invisible())
}
