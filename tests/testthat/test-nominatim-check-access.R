test_that("api_call() returns an existing cached response", {
  tmp <- withr::local_tempfile(fileext = ".json")
  file.create(tmp)
  local_mocked_bindings(cached_filename = function(url, ext) tmp)

  expect_identical(
    api_call("https://example.com", ext = ".json", quiet = TRUE),
    tmp
  )
})

test_that("api_call() returns FALSE and removes files after failed retries", {
  tmp <- withr::local_tempfile(fileext = ".json")
  state <- new.env(parent = emptyenv())
  state$calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      state$calls <- state$calls + 1L
      file.create(destfile)
      structure("boom", class = "try-error")
    },
    pause_api_call = function() NULL
  )

  expect_false(api_call("https://example.com", ext = ".json", quiet = TRUE))
  expect_equal(state$calls, 2L)
  expect_false(file.exists(tmp))
})

test_that("api_call() returns after the first successful request", {
  tmp <- withr::local_tempfile(fileext = ".json")
  state <- new.env(parent = emptyenv())
  state$calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      state$calls <- state$calls + 1L
      file.create(destfile)
      destfile
    },
    pause_api_call = function() NULL
  )

  expect_identical(
    api_call("https://example.com", ext = ".json", quiet = TRUE),
    tmp
  )
  expect_equal(state$calls, 1L)
  expect_true(file.exists(tmp))
})

test_that("cached_filename() creates stable paths for each format", {
  one <- cached_filename("https://example.com/search?q=Madrid", ".json")
  two <- cached_filename("https://example.com/search?q=Madrid", ".json")
  geojson <- cached_filename("https://example.com/search?q=Madrid", ".geojson")

  expect_identical(one, two)
  expect_match(one, "nominatim_cache", fixed = TRUE)
  expect_match(one, "\\.json$")
  expect_match(geojson, "\\.geojson$")
  expect_true(dir.exists(dirname(one)))
})

test_that("nominatim_check_access() interprets status responses", {
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

test_that("nominatim_check_access() returns logical status from the live API", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline(host = "nominatim.openstreetmap.org")

  expect_type(nominatim_check_access(), "logical")
})


test_that("on_cran() controls access checks from NOT_CRAN", {
  # Imagine we are in CRAN
  withr::local_envvar("NOT_CRAN" = "false")
  expect_true(on_cran())
  expect_false(nominatim_check_access())

  withr::local_envvar("NOT_CRAN" = "")
  expect_identical(!interactive(), on_cran())
})

test_that("api_call() reports and completes a successful retry", {
  tmp <- withr::local_tempfile(fileext = ".json")
  state <- new.env(parent = emptyenv())
  state$calls <- 0L

  local_mocked_bindings(
    cached_filename = function(url, ext) tmp,
    download_api_file = function(url, destfile, quiet) {
      state$calls <- state$calls + 1L

      if (state$calls == 1L) {
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
  expect_equal(state$calls, 2L)
})
