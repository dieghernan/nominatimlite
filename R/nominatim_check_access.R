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
#' @keyword internal
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