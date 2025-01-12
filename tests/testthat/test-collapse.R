# tests/testthat/test-collapse.R

test_that("collapse handles multiple elements with default separator", {
  expect_equal(collapse(c("a", "b", "c")), "a b c")
})

test_that("collapse handles single element", {
  expect_equal(collapse("a"), "a")
})

test_that("collapse handles empty vector", {
  expect_equal(collapse(character(0)), character(0))
})

test_that("collapse works with custom separators", {
  expect_equal(collapse(c("a", "b", "c"), ", "), "a, b, c")
  expect_equal(collapse(c("a", "b", "c"), "|"), "a|b|c")
  expect_equal(collapse(c("a", "b", "c"), ""), "abc")
})

test_that("collapse handles numeric vectors", {
  expect_equal(collapse(1:3, ", "), "1, 2, 3")
})

test_that("collapse handles NA values", {
  expect_equal(collapse(c("a", NA, "c"), ", "), "a, NA, c")
})

test_that("collapse handles different data types", {
  expect_equal(collapse(c(TRUE, FALSE), ", "), "TRUE, FALSE")
  expect_equal(collapse(c(1.5, 2.7), ", "), "1.5, 2.7")
})

test_that("collapse preserves empty strings", {
  expect_equal(collapse(c("a", "", "c"), ", "), "a, , c")
})

test_that("collapse handles special characters in separator", {
  expect_equal(collapse(c("a", "b"), "\n"), "a\nb")
  expect_equal(collapse(c("a", "b"), "\t"), "a\tb")
})
