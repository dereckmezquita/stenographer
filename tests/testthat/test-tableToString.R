# tests/testthat/test-tableToString.R

test_that("tableToString handles basic data frames", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_snapshot(tableToString(df))
})

test_that("tableToString handles single-row data frames", {
  df <- data.frame(a = 1, b = "x")
  expect_snapshot(tableToString(df))
})

test_that("tableToString handles empty data frames", {
  df <- data.frame()
  expect_snapshot(tableToString(df))
})

test_that("tableToString handles data frames with NA values", {
  df <- data.frame(a = c(1, NA, 3), b = c("x", "y", NA))
  expect_snapshot(tableToString(df))
})

test_that("tableToString converts matrices to data frames", {
  mat <- matrix(1:4, nrow = 2)
  expect_snapshot(tableToString(mat))
})

test_that("tableToString handles lists", {
  lst <- list(a = 1:3, b = letters[1:3])
  expect_snapshot(tableToString(lst))
})

test_that("tableToString handles vectors", {
  vec <- 1:3
  expect_snapshot(tableToString(vec))
})

test_that("tableToString handles factors", {
  fct <- factor(c("a", "b", "a"))
  expect_snapshot(tableToString(fct))
})

test_that("tableToString handles data frames with different column types", {
  df <- data.frame(
    num = c(1, 2.5, 3),
    char = c("a", "b", "c"),
    bool = c(TRUE, FALSE, TRUE),
    fct = factor(c("x", "y", "x")),
    stringsAsFactors = FALSE
  )
  expect_snapshot(tableToString(df))
})

test_that("tableToString produces expected string format", {
  df <- data.frame(a = 1:2, b = c("x", "y"))
  result <- tableToString(df)
  
  # Check it's a single string
  expect_type(result, "character")
  expect_length(result, 1)
  
  # Check it contains newlines
  expect_true(grepl("\n", result))
  
  # Check basic content
  expect_true(grepl("a b", result))  # Header
  expect_true(grepl("1 x", result))  # First row
  expect_true(grepl("2 y", result))  # Second row
})