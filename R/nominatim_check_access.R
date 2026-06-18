#' Check access to the Nominatim API
#'
#' @description
#' Checks whether \R can access the Nominatim API at
#' <https://nominatim.openstreetmap.org>.
#'
#' @inheritParams geo_lite nominatim_server
#'
#' @returns
#' A single logical value: `TRUE` if the API is available and `FALSE` otherwise.
#'
#' @seealso
#' <https://nominatim.org/release-docs/latest/api/Status/>.
#'
#' @family api_management
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
#' Wraps [utils::download.file()] and retries the request after a warning or
#' error. Requests are limited to approximately one query per second.
#'
#' See [Nominatim Usage
#' Policy](https://operations.osmfoundation.org/policies/nominatim/).
#'
#' @param ext File extension for the cached response. Must be `".json"` or
#'   `".geojson"`.
#' @inheritParams utils::download.file url quiet
#'
#' @returns
#' A cached file path, or `FALSE` when the query fails.
#'
#' @family api_management
#' @keywords internal
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
  Sys.sleep(1.2)

  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }
  if (isFALSE(quiet)) {
    message("Retrying the Nominatim API query.")
  }
  Sys.sleep(1.2)

  dwn_res <- download_api_file(url, destfile, quiet)

  # Return the file after a successful request.
  if (!inherits(dwn_res, "try-error")) {
    return(destfile) # nocov
  }

  unlink(destfile, force = TRUE)

  !inherits(dwn_res, "try-error")
}

download_api_file <- function(url, destfile, quiet) {
  suppressWarnings(try(
    download.file(url, destfile = destfile, quiet = quiet, mode = "wb"),
    silent = TRUE
  ))
}

#' Create a hashed filename for caching requests
#'
#' @param url The URL to cache.
#' @param ext The file extension to append to the cached file.
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
