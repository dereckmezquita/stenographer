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
#' @description An R6 class for flexible logging with customizable output.
#'
#' @examples
#' # Create a basic logger
#' logger <- Logger$new()
#' logger$info("This is an info message")
#' logger$warn("This is a warning")
#' logger$error("This is an error")
#'
#' # Create a logger with custom settings
#' custom_logger <- Logger$new(
#'   level = LogLevel$WARNING,
#'   save_to_file = TRUE,
#'   file_path = tempfile("log_"),
#'   print_fn = message
#' )
#' custom_logger$info("This won't be logged")
#' custom_logger$warn("This will be logged")
#'
#' # Change log level
#' custom_logger$set_level(LogLevel$INFO)
#' custom_logger$info("Now this will be logged")
#' @export
Logger <- R6::R6Class(
    "Logger",
    public = list(
        #' @description
        #' Create a new Logger object.
        #' @param level The minimum log level to output. Default is LogLevel$INFO.
        #' @param save_to_file Logical; whether to save logs to a file. Default is FALSE.
        #' @param file_path Character; path to the log file if save_to_file is TRUE.
        #' @param print_fn Function; custom print function to use for console output.
        #'   Should accept a single character string as input. Default uses cat with a newline.
        #' @return A new `Logger` object.
        #' @examples
        #' logger <- Logger$new(level = LogLevel$WARNING, save_to_file = TRUE, file_path = "log.txt")
        initialize = function(level = LogLevel$INFO, save_to_file = FALSE, file_path = "", 
                              print_fn = function(x) cat(x, "\n")) {
            private$level <- level
            private$save_to_file <- save_to_file
            private$file_path <- file_path
            private$print_fn <- print_fn

            if (private$save_to_file && private$file_path == "") {
                rlang::abort("File path must be provided when save_to_file is TRUE")
            }

            if (private$save_to_file) {
                private$ensure_log_file_exists()
                private$initialize_json_file()
            }
            
            # Register an exit handler to ensure proper closure
            reg.finalizer(self, function(e) e$close(), onexit = TRUE)
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
        #' logger$error("An error occurred", data = list(x = 1), error = "Oops!")
        error = function(msg, data = NULL, error = NULL) {
            if (private$level >= LogLevel$ERROR) {
                entry <- private$create_log_entry("ERROR", msg, data, error)
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
                entry <- private$create_log_entry("WARNING", msg, data)
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
                entry <- private$create_log_entry("INFO", msg, data)
                private$print_fn(private$format_console_output(entry))
                private$log_to_file(entry)
            }
        },

        #' @description
        #' Explicitly close the logger and finalize the JSON file.
        #' @examples
        #' logger <- Logger$new(save_to_file = TRUE, file_path = "log.json")
        #' logger$info("Some log message")
        #' logger$close()
        close = function() {
            if (private$save_to_file && !private$is_closed) {
                private$close_json_file()
                private$is_closed <- TRUE
            }
        },

        #' @description
        #' Clean up and close the JSON file when the logger is garbage collected.
        finalize = function() {
            self$close()
        }
    ),

    private = list(
        level = NULL,
        save_to_file = NULL,
        file_path = NULL,
        print_fn = NULL,
        file_is_empty = NULL,
        is_closed = FALSE,

        ensure_log_file_exists = function() {
            dir <- fs::path_dir(private$file_path)
            if (!fs::dir_exists(dir)) {
                fs::dir_create(dir, recursive = TRUE)
            }
            if (!fs::file_exists(private$file_path)) {
                fs::file_create(private$file_path)
                private$file_is_empty <- TRUE
            } else {
                private$file_is_empty <- file.size(private$file_path) == 0
            }
        },

        initialize_json_file = function() {
            if (private$file_is_empty) {
                cat("[\n", file = private$file_path, append = FALSE)
            }
        },

        log_to_file = function(entry) {
            if (private$save_to_file) {
                json_entry <- jsonlite::toJSON(entry, auto_unbox = TRUE)
                
                if (!private$file_is_empty) {
                    cat(",\n", file = private$file_path, append = TRUE)
                }
                
                cat(json_entry, file = private$file_path, append = TRUE)
                private$file_is_empty <- FALSE
            }
        },

        close_json_file = function() {
            if (!private$file_is_empty) {
                cat("\n]", file = private$file_path, append = TRUE)
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
                entry$error <- private$serialize_error(error)
            }
            return(entry)
        },

        serialize_error = function(error) {
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
            level <- level_color(sprintf("%-7s", entry$level))
            message <- crayon::white(entry$msg)

            output <- sprintf("%s %s %s", timestamp, level, message)

            if (!is.null(entry$data)) {
                output <- paste0(output, "\n", crayon::cyan("Data:"), "\n",
                                 jsonlite::toJSON(entry$data, auto_unbox = TRUE, pretty = TRUE))
            }

            if (!is.null(entry$error)) {
                output <- paste0(output, "\n", crayon::red("Error:"), "\n",
                                 jsonlite::toJSON(entry$error, auto_unbox = TRUE, pretty = TRUE))
            }

            return(output)
        }
    )
)