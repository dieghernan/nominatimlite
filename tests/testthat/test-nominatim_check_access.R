test_that("api_call returns a cached file", {
  tmp <- tempfile(fileext = ".json")
  file.create(tmp)
  local_mocked_bindings(cached_filename = function(url, ext) tmp)

  expect_identical(
    api_call("https://example.com", ext = ".json", quiet = TRUE),
    tmp
  )

  unlink(tmp)
})

test_that("api_call returns FALSE after failed retries", {
  tmp <- tempfile(fileext = ".json")
  calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      calls <<- calls + 1L
      file.create(destfile)
      structure("boom", class = "try-error")
    },
    pause_api_call = function() NULL
  )

  expect_false(api_call("https://example.com", ext = ".json", quiet = TRUE))
  expect_equal(calls, 2L)
  expect_false(file.exists(tmp))
})

test_that("api_call returns after a successful first request", {
  tmp <- tempfile(fileext = ".json")
  calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      calls <<- calls + 1L
      file.create(destfile)
      destfile
    },
    pause_api_call = function() NULL
  )

  expect_identical(
    api_call("https://example.com", ext = ".json", quiet = TRUE),
    tmp
  )
  expect_equal(calls, 1L)
  expect_true(file.exists(tmp))

  unlink(tmp)
})

test_that("cached_filename creates stable cache paths", {
  one <- cached_filename("https://example.com/search?q=Madrid", ".json")
  two <- cached_filename("https://example.com/search?q=Madrid", ".json")
  geojson <- cached_filename("https://example.com/search?q=Madrid", ".geojson")

  expect_identical(one, two)
  expect_match(one, "nominatim_cache", fixed = TRUE)
  expect_match(one, "\\.json$")
  expect_match(geojson, "\\.geojson$")
  expect_true(dir.exists(dirname(one)))
})

test_that("nominatim_check_access reads status responses", {
  local_mocked_bindings(
    on_cran = function() FALSE,
    api_call = testthat::mock_output_sequence(
      test_fixture("status-ok.json"),
      test_fixture("status-message-ok.json"),
      test_fixture("status-ko.json"),
      FALSE
    )
  )

  expect_true(nominatim_check_access())
  expect_true(nominatim_check_access())
  expect_false(nominatim_check_access())
  expect_false(nominatim_check_access())
})

test_that("nominatim_check_access can query the live status endpoint", {
  skip_on_cran()
  skip_if_offline()

  expect_type(nominatim_check_access(), "logical")
})


test_that("On CRAN", {
  env_orig <- Sys.getenv("NOT_CRAN", unset = NA_character_)

  on.exit(
    {
      if (is.na(env_orig)) {
        Sys.unsetenv("NOT_CRAN")
      } else {
        Sys.setenv("NOT_CRAN" = env_orig)
      }
    },
    add = TRUE
  )

  # Imagine we are in CRAN
  Sys.setenv("NOT_CRAN" = "false")
  expect_true(on_cran())
  expect_false(nominatim_check_access())

  Sys.setenv("NOT_CRAN" = "")
  expect_identical(!interactive(), on_cran())
})

test_that("api_call informs when retrying", {
  skip_on_cran()

  tmp <- tempfile(fileext = ".json")
  calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      calls <<- calls + 1L

      if (calls == 1L) {
        return(structure("boom", class = "try-error"))
      }

      file.create(destfile)
      destfile
    },
    pause_api_call = function() NULL
  )

  expect_message(
    res <- api_call("https://example.com", ext = ".json", quiet = FALSE),
    "Retrying the Nominatim API query."
  )

  expect_identical(res, tmp)
  expect_equal(calls, 2L)

  unlink(tmp)
})
