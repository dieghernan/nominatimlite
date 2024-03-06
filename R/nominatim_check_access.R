#' Check access to Nominatim API
#'
#' @family api_management
#'
#' @description
#' Check if **R** has access to resources at
#' <https://nominatim.openstreetmap.org>.
#'
#' @return a logical.
#'
#' @seealso
#' <https://nominatim.org/release-docs/latest/api/Status/>
#'
#' @examples
#' \donttest{
#' nominatim_check_access()
#' }
#' @keywords internal
#' @export
nominatim_check_access <- function(
  nominatim_server = "https://nominatim.openstreetmap.org/"
) {
  # First build the api address. If the passed nominatim_server does not end
  # with a trailing forward-slash, add one
  if (substr(nominatim_server, nchar(nominatim_server),
             nchar(nominatim_server)) != "/") {
    nominatim_server <- paste0(nominatim_server, "/")
  }
  url <- paste0(nominatim_server, "status.php?format=json")
  destfile <- tempfile(fileext = ".json")

  api_res <- api_call(url, destfile, TRUE)

  # nocov start
  if (isFALSE(api_res)) {
    return(FALSE)
  }
  # nocov end
  result <- dplyr::as_tibble(jsonlite::fromJSON(destfile, flatten = TRUE))

  # nocov start
  if (result$status == 0 || result$message == "OK") {
    return(TRUE)
  } else {
    return(FALSE)
  }
  # nocov end
}

skip_if_api_server <- function() {
  # nocov start
  if (nominatim_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("Nominatim API not reachable")
  }
  return(invisible())
  # nocov end
}


#' Helper function for centralize API queries
#'
#' @description
#' A wrapper of [utils::download.file()]. On warning on error it will
#' retry the call. Requests are adjusted to the rate of 1 query per second.
#'
#' See [Nominatim Usage
#' Policy](https://operations.osmfoundation.org/policies/nominatim/).
#'
#' @family api_management
#'
#' @inheritParams utils::download.file
#' @return A logical `TRUE/FALSE`
#'
#' @keywords internal
#'
api_call <- function(url, destfile, quiet) {
  # nocov start
  dwn_res <-
    tryCatch(
      download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
      warning = function(e) {
        return(FALSE)
      },
      error = function(e) {
        return(FALSE)
      }
    )
  # nocov end
  # Always sleep to make 1 call per sec
  Sys.sleep(1)

  # nocov start
  if (isFALSE(dwn_res)) {
    if (isFALSE(quiet)) message("Retrying query")
    Sys.sleep(1)

    dwn_res <-
      tryCatch(
        download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
        warning = function(e) {
          return(FALSE)
        },
        error = function(e) {
          return(FALSE)
        }
      )
  }

  if (isFALSE(dwn_res)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
  # nocov end
}
