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
