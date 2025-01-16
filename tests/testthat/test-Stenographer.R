# tests/testthat/test-stenographer.R

test_that("LogLevel contains correct values", {
  expect_equal(LogLevel$OFF, -1L)
  expect_equal(LogLevel$ERROR, 0L)
  expect_equal(LogLevel$WARNING, 1L)
  expect_equal(LogLevel$INFO, 2L)
})

test_that("Stenographer initializes with default settings", {
  steno <- Stenographer$new()
  expect_equal(steno$.__enclos_env__$private$level, LogLevel$INFO)
  expect_null(steno$.__enclos_env__$private$file_path)
  expect_null(steno$.__enclos_env__$private$db_conn)
  expect_equal(steno$.__enclos_env__$private$table_name, "LOGS")
  expect_equal(steno$get_context(), list())
})

test_that("Stenographer respects LogLevel$OFF", {
  # Create logger that captures output
  output <- character(0)
  steno <- Stenographer$new(
    level = LogLevel$OFF,
    print_fn = function(x) output <<- c(output, x)
  )
  
  # Try logging at all levels
  steno$info("test info")
  steno$warn("test warning")
  steno$error("test error")
  
  # Nothing should be logged
  expect_length(output, 0)
})

test_that("Stenographer respects LogLevel$ERROR", {
  output <- character(0)
  steno <- Stenographer$new(
    level = LogLevel$ERROR,
    print_fn = function(x) output <<- c(output, x)
  )
  
  steno$info("test info")
  steno$warn("test warning")
  steno$error("test error")
  
  # Only error should be logged
  expect_length(output, 1)
  expect_true(grepl("test error", output[1]))
})

test_that("Stenographer respects LogLevel$WARNING", {
  output <- character(0)
  steno <- Stenographer$new(
    level = LogLevel$WARNING,
    print_fn = function(x) output <<- c(output, x)
  )
  
  steno$info("test info")
  steno$warn("test warning")
  steno$error("test error")
  
  # Warning and error should be logged
  expect_length(output, 2)
  expect_true(any(grepl("test warning", output)))
  expect_true(any(grepl("test error", output)))
})

test_that("Stenographer respects LogLevel$INFO", {
  output <- character(0)
  steno <- Stenographer$new(
    level = LogLevel$INFO,
    print_fn = function(x) output <<- c(output, x)
  )
  
  steno$info("test info")
  steno$warn("test warning")
  steno$error("test error")
  
  # All messages should be logged
  expect_length(output, 3)
  expect_true(any(grepl("test info", output)))
  expect_true(any(grepl("test warning", output)))
  expect_true(any(grepl("test error", output)))
})

test_that("Stenographer active field get_level returns correct level and set_level works", {
  # Start with INFO
  steno <- Stenographer$new(level = LogLevel$INFO)
  expect_equal(steno$get_level, LogLevel$INFO)
  
  # Change to OFF
  steno$set_level(LogLevel$OFF)
  expect_equal(steno$get_level, LogLevel$OFF)
  
  # Change to ERROR
  steno$set_level(LogLevel$ERROR)
  expect_equal(steno$get_level, LogLevel$ERROR)
  
  # Change to WARNING
  steno$set_level(LogLevel$WARNING)
  expect_equal(steno$get_level, LogLevel$WARNING)
  
  # Change back to INFO
  steno$set_level(LogLevel$INFO)
  expect_equal(steno$get_level, LogLevel$INFO)
})

test_that("context management works correctly", {
  output <- character(0)
  steno <- Stenographer$new(
    print_fn = function(x) output <<- c(output, x)
  )
  
  # Test initial empty context
  expect_equal(steno$get_context(), list())
  
  # Test updating context
  steno$update_context(list(user = "test"))
  expect_equal(steno$get_context(), list(user = "test"))
  
  # Test context appears in log
  steno$info("test message")
  expect_true(any(grepl("\"user\":\\s*\"test\"", output)))
  
  # Test clearing context
  steno$clear_context()
  expect_equal(steno$get_context(), list())
})

test_that("message formatting works", {
  output <- character(0)
  steno <- Stenographer$new(
    format_fn = function(level, msg) paste0("PREFIX:", msg),
    print_fn = function(x) output <<- c(output, x)
  )
  
  steno$info("test")
  expect_true(any(grepl("PREFIX:test", output)))
})

test_that("error serialization works", {
  output <- character(0)
  steno <- Stenographer$new(
    print_fn = function(x) output <<- c(output, x)
  )
  
  # Create an error object
  err <- tryCatch(stop("test error"), error = function(e) e)
  
  steno$error("An error occurred", error = err)
  
  # Check error details are included
  expect_true(any(grepl("test error", output)))
  expect_true(any(grepl("Error:", output)))
})
