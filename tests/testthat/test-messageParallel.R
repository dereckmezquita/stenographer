# tests/testthat/test-messageParallel.R

test_that("messageParallel handles basic string", {
  expect_snapshot({
    messageParallel("Hello World")
  })
})

test_that("messageParallel concatenates multiple arguments", {
  expect_snapshot({
    messageParallel("Hello", " ", "World")
  })
})

test_that("messageParallel handles empty strings", {
  expect_snapshot({
    messageParallel("")
  })
})

test_that("messageParallel handles special characters", {
  expect_snapshot({
    messageParallel("Hello\nWorld")  # newline
    messageParallel("Hello\tWorld")  # tab
    messageParallel("Hello \"World\"")  # quotes
  })
})

test_that("messageParallel handles multiple lines", {
  expect_snapshot({
    messageParallel("Line 1\nLine 2\nLine 3")
  })
})

test_that("messageParallel handles numbers", {
  expect_snapshot({
    messageParallel(123)
    messageParallel(1.234)
  })
})

test_that("messageParallel handles mixing types", {
  expect_snapshot({
    messageParallel("Number: ", 123, " String: ", "test")
  })
})