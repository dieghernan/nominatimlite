#' Check access to the Nominatim API
#'
#' @description
#' Checks whether \R can access a Nominatim API server.
#'
#' @inheritParams geo_lite nominatim_server
#'
#' @returns
#' A single logical value: `TRUE` if the API is available and `FALSE` otherwise.
#'
#' @seealso
#' <https://nominatim.org/release-docs/latest/api/Status/>.
#'
#' @keywords internal
#' @encoding UTF-8
#' @export
#'
#' @examples
#' \donttest{
#' nominatim_check_access()
#' }
nominatim_check_access <- function(
  nominatim_server = "https://nominatim.openstreetmap.org/"
) {
  if (on_cran()) {
    return(FALSE)
  }

  # Build the API address.
  url <- prepare_api_url(nominatim_server, "status?format=json")

  api_res <- api_call(url, ".json", TRUE)
  if (isFALSE(api_res)) {
    return(FALSE)
  }

  result <- dplyr::as_tibble(jsonlite::fromJSON(api_res, flatten = TRUE))

  any(result$status == 0 || result$message == "OK")
}

#' Query the Nominatim API
#'
#' @description
#' Wraps [utils::download.file()] and retries the request after an error or
#' warning. Requests are limited to approximately one query per second.
#'
#' See [Nominatim Usage
#' Policy](https://operations.osmfoundation.org/policies/nominatim/).
#'
#' @param ext A character string specifying the file extension for the cached
#'   response. Must be `".json"` or `".geojson"`.
#' @inheritParams utils::download.file url quiet
#'
#' @returns
#' A cached file path or `FALSE` when the query fails.
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

  dwn_res <- download_api_file(url, destfile, quiet)

  # Always sleep to keep one call per second with an extra buffer.
  pause_api_call()

  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }
  if (isFALSE(quiet)) {
    message("Retrying the Nominatim API query.")
  }
  pause_api_call()

  dwn_res <- download_api_file(url, destfile, quiet)

  # Return the file after a successful request.
  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }

  unlink(destfile, force = TRUE)

  !inherits(dwn_res, "try-error")
}

download_api_file <- function(url, destfile, quiet) {
  # nocov start
  suppressWarnings(try(
    download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
    silent = TRUE
  ))
  # nocov end
}

pause_api_call <- function() {
  # nocov start
  Sys.sleep(1.2)
  # nocov end
}

#' Create a hashed filename for caching requests
#'
#' Creates a deterministic path in the session temporary directory from the
#' request URL.
#'
#' @param url A character string specifying the URL to cache.
#' @param ext A character string specifying the file extension to append to the
#'   cached file.
#'
#' @returns A path to the cached response file.
#'
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

#' Check whether the current session is running on CRAN
#'
#' Checks the `NOT_CRAN` environment variable and whether the session is
#' interactive.
#'
#' @returns A single logical value.
#'
#' @noRd
on_cran <- function() {
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive()
  } else {
    !isTRUE(as.logical(env))
  }
}
