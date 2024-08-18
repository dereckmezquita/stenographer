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
#' @description An R6 class for flexible logging with customisable output, message formatting, and context.
#'
#' @examples
#' # Create a basic logger
#' logger <- Logger$new()
#' logger$info("This is an info message")
#' logger$warn("This is a warning")
#' logger$error("This is an error")
#'
#' # Create a logger with custom settings, message formatting, and context
#' custom_logger <- Logger$new(
#'   level = LogLevel$WARNING,
#'   file_path = tempfile("log_"),
#'   print_fn = function(x) message(paste0("Custom: ", x)),
#'   format_fn = function(level, msg) paste0("Hello prefix: ", msg),
#'   context = list(program = "MyApp")
#' )
#' custom_logger$info("This won't be logged")
#' custom_logger$warn("This will be logged with a custom prefix")
#'
#' # Change log level and update context
#' custom_logger$set_level(LogLevel$INFO)
#' custom_logger$update_context(list(user = "John"))
#' custom_logger$info("Now this will be logged with a custom prefix and context")
#' @export
Logger <- R6::R6Class(
    "Logger",
    public = list(
        #' @description
        #' Create a new Logger object.
        #' @param level The minimum log level to output. Default is LogLevel$INFO.
        #' @param file_path Character; the path to a file to save log entries to. Default is NULL.
        #' @param db_conn DBI connection object; an existing database connection. Default is NULL.
        #' @param table_name Character; the name of the table to log to in the database. Default is "LOGS".
        #' @param print_fn Function; custom print function to use for console output.
        #'   Should accept a single character string as input. Default uses cat with a newline.
        #' @param format_fn Function; custom format function to modify the log message.
        #'   Should accept level and msg as inputs and return a formatted string.
        #' @param context List; initial context for the logger. Default is an empty list.
        #' @return A new `Logger` object.
        initialize = function(
            level = LogLevel$INFO,
            file_path = NULL,
            db_conn = NULL,
            table_name = "LOGS",
            print_fn = function(x) cat(x, "\n"),
            format_fn = function(level, msg) msg,
            context = list()
        ) {
            private$level <- level
            private$file_path <- file_path
            private$db_conn <- db_conn
            private$table_name <- table_name
            private$print_fn <- print_fn
            private$format_fn <- format_fn
            private$context <- context

            if (!is.null(private$file_path)) {
                private$ensure_log_file_exists()
            }
            if (!is.null(private$db_conn)) {
                private$ensure_log_table_exists()
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
        #' Update the logger's context
        #' @param new_context A list of new context items to add or update
        update_context = function(new_context) {
            private$context <- modifyList(private$context, new_context)
        },

        #' @description
        #' Clear the logger's context
        clear_context = function() {
            private$context <- list()
        },

        #' @description
        #' Get the current context
        get_context = function() {
            return(private$context)
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
                private$log_entry(entry)
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
                private$log_entry(entry)
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
                private$log_entry(entry)
            }
        }
    ),

    private = list(
        level = NULL,
        file_path = NULL,
        db_conn = NULL,
        table_name = NULL,
        print_fn = NULL,
        format_fn = NULL,
        context = NULL,

        ensure_log_file_exists = function() {
            dir <- fs::path_dir(private$file_path)
            if (!fs::dir_exists(dir)) {
                fs::dir_create(dir, recursive = TRUE)
            }
            if (!fs::file_exists(private$file_path)) {
                fs::file_create(private$file_path)
            }
        },

        ensure_log_table_exists = function() {
            if (!DBI::dbExistsTable(private$db_conn, private$table_name)) {
                DBI::dbExecute(private$db_conn, sprintf("
                    CREATE TABLE %s (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        datetime TEXT,
                        level TEXT,
                        context TEXT,
                        msg TEXT,
                        data TEXT,
                        error TEXT
                    )
                ", private$table_name))
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

        log_to_db = function(entry) {
            if (!is.null(private$db_conn)) {
                entry$data <- NULL
                if (!is.null(entry$data)) {
                    entry$data <- jsonlite::toJSON(entry$data)
                }
                entry$error <- NULL
                if (!is.null(entry$error)) {
                    entry$error <- jsonlite::toJSON(entry$error)
                }
                entry$context <- NULL
                if (length(private$context) > 0) {
                    entry$context <- jsonlite::toJSON(private$context)
                }
                DBI::dbWriteTable(private$db_conn, private$table_name, as.data.frame(entry), append = TRUE)
            }
        },

        log_entry = function(entry) {
            private$print_fn(private$format_console_output(entry))
            private$log_to_file(entry)
            private$log_to_db(entry)
        },

        create_log_entry = function(level, msg, data = NULL, error = NULL) {
            entry <- list(
                datetime = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3Z"),
                level = level,
                msg = msg
            )
            if (!is.null(data)) {
                entry$data <- jsonlite::toJSON(data)
            }
            if (!is.null(error)) {
                entry$error <- jsonlite::toJSON(private$serialise_error(error))
            }
            if (length(private$context) > 0) {
                entry$context <- jsonlite::toJSON(private$context)
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
                    jsonlite::toJSON(jsonlite::fromJSON(entry$data), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            if (!is.null(entry$error)) {
                output <- paste0(
                    output, "\n", crayon::red("Error:"), "\n",
                    jsonlite::toJSON(jsonlite::fromJSON(entry$error), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            if (!is.null(entry$context)) {
                output <- paste0(
                    output, "\n", crayon::magenta("Context:"), "\n",
                    jsonlite::toJSON(jsonlite::fromJSON(entry$context), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            return(output)
        }
    )
)
