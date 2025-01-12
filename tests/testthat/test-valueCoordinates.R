# tests/testthat/test-valueCoordinates.R

box::use(../../R/valueCoordinates[valueCoordinates])

# Access internal function for testing
value_check <- stenographer:::value_check

test_that("value_check handles NA values correctly", {
  expect_true(value_check(NA, NA))
  expect_false(value_check(1, NA))
  expect_false(value_check(NA, 1))
})

test_that("value_check performs exact matching", {
  expect_true(value_check(1, 1))
  expect_true(value_check("a", "a"))
  expect_false(value_check(1, 2))
  expect_false(value_check("a", "b"))
})

test_that("valueCoordinates validates input type", {
  expect_error(valueCoordinates(list(a = 1)), "'df' must be a data.frame")
})

test_that("valueCoordinates finds NA values correctly", {
  df <- data.frame(
    a = c(1, NA, 3),
    b = c(NA, 2, NA),
    c = c(3, 2, 1)
  )
  
  expect_snapshot(valueCoordinates(df))
})

test_that("valueCoordinates finds specific values", {
  df <- data.frame(
    a = c(1, NA, 3),
    b = c(NA, 2, NA),
    c = c(3, 2, 1)
  )
  
  expect_snapshot(valueCoordinates(df, 2))
})

test_that("valueCoordinates works with custom comparison function", {
  df <- data.frame(
    a = c(1, NA, 3),
    b = c(NA, 2, NA),
    c = c(3, 2, 1)
  )
  
  # Test finding values > 2
  expect_snapshot(valueCoordinates(df, 2, function(x, y) !is.na(x) && x > y))
})

test_that("valueCoordinates returns empty result for no matches", {
  df <- data.frame(
    a = c(1, 2, 3),
    b = c(4, 5, 6)
  )
  
  result <- valueCoordinates(df, 999)
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 2)
  expect_named(result, c("column", "row"))
})

test_that("valueCoordinates handles single-column dataframes", {
  df <- data.frame(a = c(1, NA, 3))
  expect_snapshot(valueCoordinates(df))
})