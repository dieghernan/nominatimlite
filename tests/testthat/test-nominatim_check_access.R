test_that("api_url", {
  api <- prepare_api_url("https://www.google.com", "some_invented_entry?")

  expect_snapshot(f <- api_call(api, quiet = FALSE))
  expect_type(f, "logical")
  expect_false(f)

  # Checking with right approach
  skip_on_cran()
  skip_if_api_server()
  url <- prepare_api_url(
    "https://nominatim.openstreetmap.org/",
    "status?format=json"
  )

  expect_silent(t <- api_call(url, quiet = TRUE))
  expect_true(file.exists(t))
})

test_that("Mock no access", {
  skip_on_cran()

  my_fn <- api_call

  api_res <- tempfile(fileext = ".json")

  writeLines(
    '{\"status\":0,\"message\":\"OK\"}',
    con = api_res
  )

  local_mocked_bindings(
    api_call = function(...) {
      api_res <- tempfile(fileext = ".json")

      writeLines(
        '{\"status\":0,\"message\":\"OK\"}',
        con = api_res
      )
      api_res
    }
  )

  expect_true(nominatim_check_access())

  local_mocked_bindings(
    api_call = function(...) {
      api_res <- tempfile(fileext = ".json")

      writeLines(
        '{\"status\":0,\"message\":\"KO\"}',
        con = api_res
      )
      api_res
    }
  )
  expect_true(nominatim_check_access())

  local_mocked_bindings(
    api_call = function(...) {
      api_res <- tempfile(fileext = ".json")

      writeLines(
        '{\"status\":999,\"message\":\"KO\"}',
        con = api_res
      )
      api_res
    }
  )
  expect_false(nominatim_check_access())

  local_mocked_bindings(
    api_call = function(...) {
      FALSE
    }
  )
  expect_false(nominatim_check_access())

  local_mocked_bindings(api_call = my_fn)

  expect_identical(api_call, my_fn)
})


test_that("On CRAN", {
  skip_on_cran()
  skip_if_api_server()

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
    }
  )

  expect_message(
    res <- api_call("https://example.com", ext = ".json", quiet = FALSE),
    "Retrying the Nominatim API query."
  )

  expect_identical(res, tmp)
  expect_equal(calls, 2L)

  unlink(tmp)
})
