test_that("Check add_custom_query", {
  u <- "http://test"
  t <- add_custom_query(custom_query = list(), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(1, b = 2), url = u)
  expect_identical(u, t)

  # Uname some argument
  t <- add_custom_query(custom_query = list(a = 1, 2), url = u)
  expect_identical(u, t)


  # Uname some argument
  t <- add_custom_query(custom_query = list(3), url = u)
  expect_identical(u, t)


  # Check
  t <- add_custom_query(custom_query = list(a = 3, b = 3), url = u)
  expect_identical("http://test&a=3&b=3", t)
})
