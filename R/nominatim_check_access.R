#' Check access to Nominatim API
#'
#' @description
#' Check if **R** has access to resources at
#' <https://nominatim.openstreetmap.org>.
#'
#' @family api_management
#' @keywords internal
#' @encoding UTF-8
#'
#' @return
#' A logical `TRUE/FALSE`.
#'
#' @inheritParams geo_lite
#'
#' @seealso
#' <https://nominatim.org/release-docs/latest/api/Status/>.
#'
#' @export
#'
#' @examples
#' \donttest{
#' nominatim_check_access()
#' }
nominatim_check_access <- function(
  nominatim_server = "https://nominatim.openstreetmap.org/"
) {
  # Build the API address and ensure that the server URL has one trailing slash.
  url <- prepare_api_url(nominatim_server, "status?format=json")

  api_res <- api_call(url, ".json", TRUE)
  if (isFALSE(api_res)) {
    return(FALSE)
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(api_res, flatten = TRUE))

  # nocov start
  if (result$status == 0 || result$message == "OK") {
    TRUE
  } else {
    FALSE
  }
  # nocov end
}

skip_if_api_server <- function() {
  # nocov start
  if (nominatim_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("Nominatim API is not reachable.")
  }
  invisible()
  # nocov end
}


#' Helper function for centralized API queries
#'
#' @description
#' A wrapper of [utils::download.file()]. On warning or error, it retries the
#' call. Requests are adjusted to the rate of one query per second.
#'
#' See [Nominatim Usage
#' Policy](https://operations.osmfoundation.org/policies/nominatim/).
#'
#' @family api_management
#'
#' @inheritParams utils::download.file
#'
#' @return
#' A logical `TRUE/FALSE`.
#'
#' @keywords internal
#'
#' @noRd
#'
api_call <- function(url, ext = c(".json", ".geojson"), quiet) {
  ext <- match.arg(ext)

  # Hash the destination file.
  destfile <- cached_filename(url, ext)
  # Return cached files.
  if (file.exists(destfile)) {
    return(destfile)
  }

  dwn_res <- suppressWarnings(try(
    download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
    silent = TRUE
  ))

  # Always sleep to keep one call per second with an extra buffer.
  Sys.sleep(1.2)

  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }
  if (isFALSE(quiet)) {
    message("Retrying query.")
  }
  Sys.sleep(1.2)

  dwn_res <- suppressWarnings(try(
    download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
    silent = TRUE
  ))

  # Return the file when all went well.
  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }

  unlink(destfile, force = TRUE)

  !inherits(dwn_res, "try-error")
}

#' Create a hashed filename for caching requests
#'
#' @param url The URL to cache.
#' @noRd
cached_filename <- function(url, ext = ".json") {
  tmpf <- tempfile()
  writeLines(url, tmpf)

  hash <- unname(tools::md5sum(tmpf))
  unlink(tmpf, force = TRUE)

  # Create the corresponding temporary directory and add the extension.
  tmpnomin <- file.path(tempdir(), "nominatim_cache")
  if (!dir.exists(tmpnomin)) {
    dir.create(tmpnomin, showWarnings = FALSE, recursive = TRUE)
  }

  # Return the final filename.
  fname <- file.path(tmpnomin, paste0(hash, ext))
  fname
}
