#' Check access to Nominatim API
#'
#' @description
#' Check if \R has access to resources at
#' <https://nominatim.openstreetmap.org>.
#'
#' @family api_management
#' @encoding UTF-8
#'
#' @inheritParams geo_lite
#'
#' @return
#' A logical `TRUE/FALSE`.
#'
#' @seealso
#' <https://nominatim.org/release-docs/latest/api/Status/>.
#'
#' @keywords internal
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
#' A wrapper around [utils::download.file()]. On warning or error, it retries
#' the call. Requests are adjusted to the rate of one query per second.
#'
#' See [Nominatim Usage
#' Policy](https://operations.osmfoundation.org/policies/nominatim/).
#'
#' @family api_management
#'
#' @inheritParams utils::download.file
#'
#' @return
#' A cached file path, or `FALSE` when the query fails.
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

  dwn_res <- download_api_file(url, destfile, quiet)

  # Always sleep to keep one call per second with an extra buffer.
  Sys.sleep(1.2)

  if (!inherits(dwn_res, "try-error")) {
    return(destfile)
  }
  if (isFALSE(quiet)) {
    message("Retrying API query.")
  }
  Sys.sleep(1.2)

  dwn_res <- download_api_file(url, destfile, quiet)

  # Return the file when all went well.
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
