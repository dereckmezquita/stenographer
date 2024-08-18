#' Log Levels
#'
#' Defines the available log levels for the Logger class.
#'
#' @export
LogLevel <- list(
    ERROR = 0L,
    WARNING = 1L,
    INFO = 2L
)

#' @title Logger
#' @description An R6 class for flexible logging with customisable output and message formatting.
#'
#' @examples
#' # Create a basic logger
#' logger <- Logger$new()
#' logger$info("This is an info message")
#' logger$warn("This is a warning")
#' logger$error("This is an error")
#'
#' # Create a logger with custom settings and message formatting
#' custom_logger <- Logger$new(
#'   level = LogLevel$WARNING,
#'   file_path = tempfile("log_"),
#'   print_fn = function(x) message(paste0("Custom: ", x)),
#'   format_fn = function(level, msg) paste0("Hello prefix: ", msg)
#' )
#' custom_logger$info("This won't be logged")
#' custom_logger$warn("This will be logged with a custom prefix")
#'
#' # Change log level
#' custom_logger$set_level(LogLevel$INFO)
#' custom_logger$info("Now this will be logged with a custom prefix")
#' @export
Logger <- R6::R6Class(
    "Logger",
    public = list(
        #' @description
        #' Create a new Logger object.
        #' @param level The minimum log level to output. Default is LogLevel$INFO.
        #' @param file_path Character; the path to a file to save log entries to. Default is NULL.
        #' @param print_fn Function; custom print function to use for console output.
        #'   Should accept a single character string as input. Default uses cat with a newline.
        #' @param format_fn Function; custom format function to modify the log message.
        #'   Should accept level and msg as inputs and return a formatted string.
        #' @return A new `Logger` object.
        #' @examples
        #' logger <- Logger$new(
        #'   level = LogLevel$WARNING,
        #'   file_path = "log.txt",
        #'   print_fn = function(x) message(paste0("Custom: ", x)),
        #'   format_fn = function(level, msg) paste0("Hello prefix: ", msg)
        #' )
        initialize = function(
            level = LogLevel$INFO,
            file_path = NULL,
            print_fn = function(x) cat(x, "\n"),
            format_fn = function(level, msg) msg
        ) {
            private$level <- level
            private$file_path <- file_path
            private$print_fn <- print_fn
            private$format_fn <- format_fn

            if (!is.null(private$file_path)) {
                private$ensure_log_file_exists()
            }
        },

        #' @description
        #' Set the minimum log level.
        #' @param level The new minimum log level to set.
        #' @examples
        #' logger <- Logger$new()
        #' logger$set_level(LogLevel$WARNING)
        set_level = function(level) {
            private$level <- level
        },

        #' @description
        #' Log an error message.
        #' @param msg Character; the error message to log.
        #' @param data Optional; additional data to include in the log entry.
        #' @param error Optional; an error object to include in the log entry.
        #' @examples
        #' logger <- Logger$new()
        #' logger$error("An error occurred", data = list(x = 1), error = simpleError("Oops!"))
        error = function(msg, data = NULL, error = NULL) {
            if (private$level >= LogLevel$ERROR) {
                formatted_msg <- private$format_fn("ERROR", msg)
                entry <- private$create_log_entry("ERROR", formatted_msg, data, error)
                private$print_fn(private$format_console_output(entry))
                private$log_to_file(entry)
            }
        },

        #' @description
        #' Log a warning message.
        #' @param msg Character; the warning message to log.
        #' @param data Optional; additional data to include in the log entry.
        #' @examples
        #' logger <- Logger$new()
        #' logger$warn("This is a warning", data = list(reason = "example"))
        warn = function(msg, data = NULL) {
            if (private$level >= LogLevel$WARNING) {
                formatted_msg <- private$format_fn("WARNING", msg)
                entry <- private$create_log_entry("WARNING", formatted_msg, data)
                private$print_fn(private$format_console_output(entry))
                private$log_to_file(entry)
            }
        },

        #' @description
        #' Log an info message.
        #' @param msg Character; the info message to log.
        #' @param data Optional; additional data to include in the log entry.
        #' @examples
        #' logger <- Logger$new()
        #' logger$info("Operation completed successfully", data = list(duration = 5.2))
        info = function(msg, data = NULL) {
            if (private$level >= LogLevel$INFO) {
                formatted_msg <- private$format_fn("INFO", msg)
                entry <- private$create_log_entry("INFO", formatted_msg, data)
                private$print_fn(private$format_console_output(entry))
                private$log_to_file(entry)
            }
        }
    ),

    private = list(
        level = NULL,
        file_path = NULL,
        print_fn = NULL,
        format_fn = NULL,

        ensure_log_file_exists = function() {
            dir <- fs::path_dir(private$file_path)
            if (!fs::dir_exists(dir)) {
                fs::dir_create(dir, recursive = TRUE)
            }
            if (!fs::file_exists(private$file_path)) {
                fs::file_create(private$file_path)
            }
        },

        log_to_file = function(entry) {
            if (!is.null(private$file_path)) {
                cat(
                    jsonlite::toJSON(entry, auto_unbox = TRUE),
                    "\n",
                    file = private$file_path,
                    append = TRUE
                )
            }
        },

        create_log_entry = function(level, msg, data = NULL, error = NULL) {
            entry <- list(
                datetime = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3Z"),
                level = level,
                msg = msg
            )
            if (!is.null(data)) {
                entry$data <- data
            }
            if (!is.null(error)) {
                entry$error <- private$serialise_error(error)
            }
            return(entry)
        },

        serialise_error = function(error) {
            if (inherits(error, "error")) {
                return(list(
                    name = class(error)[1],
                    message = conditionMessage(error),
                    call = deparse(error$call)
                ))
            }
            return(error)
        },

        format_console_output = function(entry) {
            timestamp <- crayon::silver(entry$datetime)
            level_color <- switch(entry$level,
                ERROR = crayon::red,
                WARNING = crayon::yellow,
                INFO = crayon::blue,
                crayon::white
            )
            level <- level_color(sprintf("%-7s", entry$level)) # the %-7s left-aligns the string
            message <- crayon::white(entry$msg)

            output <- sprintf("%s %s %s", timestamp, level, message)

            if (!is.null(entry$data)) {
                output <- paste0(
                    output, "\n", crayon::cyan("Data:"), "\n",
                    jsonlite::toJSON(entry$data, auto_unbox = TRUE, pretty = TRUE)
                )
            }

            if (!is.null(entry$error)) {
                output <- paste0(
                    output, "\n", crayon::red("Error:"), "\n",
                    jsonlite::toJSON(entry$error, auto_unbox = TRUE, pretty = TRUE)
                )
            }

            return(output)
        }
    )
)
