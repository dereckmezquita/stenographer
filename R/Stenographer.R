#' @title Logging Level
#'
#' @description
#' Defines standard logging levels for controlling message output granularity.
#' Use as a configuration for the `Stenographer` class to control which messages
#' are logged.
#'
#' A list with four integer elements:
#' \describe{
#'   \item{OFF}{(-1) Disables all logging}
#'   \item{ERROR}{(0) Logs only errors}
#'   \item{WARNING}{(1) Logs errors and warnings}
#'   \item{INFO}{(2) Logs all messages}
#' }
#'
#' @examples
#' # Check logging levels
#' LogLevel$OFF     # -1
#' LogLevel$ERROR   # 0
#' LogLevel$WARNING # 1
#' LogLevel$INFO    # 2
#'
#' @export
LogLevel <- list(
    OFF = -1L,
    ERROR = 0L,
    WARNING = 1L,
    INFO = 2L
)

#' @title Check if an object is a valid log level
#' @param x Object to check
#' @return Logical
valid_log_level <- function(x) {
    return(is.integer(x) && (x %in% c(-1L, 0L, 1L, 2L)))
}

#' @title R6 Class for Advanced Logging Functionality
#'
#' @description
#' Provides a flexible logging system with support for multiple output destinations,
#' customisable formatting, and contextual logging. Features include:
#'
#' * Multiple log levels (ERROR, WARNING, INFO)
#' * File-based logging
#' * Database logging support
#' * Customisable message formatting
#' * Contextual data attachment
#' * Coloured console output
#'
#' @importFrom rlang abort
#' @importFrom R6 R6Class
#' @importFrom fs path_dir dir_exists dir_create file_exists file_create
#' @importFrom DBI dbExistsTable dbExecute dbWriteTable
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom crayon silver red yellow blue white cyan magenta
#'
#' @examples
#' # Create a basic Stenographer
#' steno <- Stenographer$new()
#' steno$info("This is an info message")
#' steno$warn("This is a warning")
#' steno$error("This is an error")
#'
#' # Disable all logging
#' steno$set_level(LogLevel$OFF)
#' steno$info("This won't be logged")
#' steno$warn("This won't be logged either")
#' steno$error("This also won't be logged")
#'
#' # Create a logger with custom settings, message formatting, and context
#' custom_steno <- Stenographer$new(
#'   level = LogLevel$WARNING,
#'   file_path = tempfile("log_"),
#'   print_fn = function(x) message(paste0("Custom: ", x)),
#'   format_fn = function(level, msg) paste0("Hello prefix: ", msg),
#'   context = list(program = "MyApp")
#' )
#' custom_steno$info("This won't be logged")
#' custom_steno$warn("This will be logged with a custom prefix")
#'
#' # Change log level and update context
#' custom_steno$set_level(LogLevel$INFO)
#' custom_steno$update_context(list(user = "John"))
#' custom_steno$info("Now this will be logged with a custom prefix and context")
#'
#' @export
Stenographer <- R6Class(
    "Stenographer",
    active = list(
        #' @field Get log level (read-only)
        get_level = function() return(private$level)
    ),

    public = list(
        #' @description
        #' Create a new Stenographer instance
        #' @param level The minimum log level to output. Default is LogLevel$INFO.
        #' @param file_path Character; the path to a file to save log entries to. Default is NULL.
        #' @param db_conn DBI connection object; an existing database connection. Default is NULL.
        #' @param table_name Character; the name of the table to log to in the database. Default is "LOGS".
        #' @param print_fn Function; custom print function to use for console output.
        #'   Should accept a single character string as input. Default uses cat with a newline.
        #' @param format_fn Function; custom format function to modify the log message.
        #'   Should accept level and msg as inputs and return a formatted string.
        #' @param context List; initial context for the logger. Default is an empty list.
        #' @return A new `Stenographer` object.
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
        #' Update the minimum logging level
        #' @param level New log level (see `LogLevel`)
        set_level = function(level) {
            if (!valid_log_level(level)) {
                abort("Invalid log level")
            }
            private$level <- level
        },

        #' @description
        #' Add or update contextual data
        #' @param new_context List of context key-value pairs
        update_context = function(new_context) {
            private$context <- modifyList(private$context, new_context)
        },

        #' @description
        #' Remove all contextual data
        clear_context = function() {
            private$context <- list()
        },

        #' @description
        #' Retrieve current context data
        #' @return List of current context
        get_context = function() {
            return(private$context)
        },

        #' @description
        #' Log an error message
        #' @param msg Error message text
        #' @param data Optional data to attach
        #' @param error Optional error object
        error = function(msg, data = NULL, error = NULL) {
            if (private$level >= LogLevel$ERROR) {
                formatted_msg <- private$format_fn("ERROR", msg)
                entry <- private$create_log_entry("ERROR", formatted_msg, data, error)
                private$log_entry(entry)
            }
        },

        #' @description
        #' Log a warning message
        #' @param msg Warning message text
        #' @param data Optional data to attach
        warn = function(msg, data = NULL) {
            if (private$level >= LogLevel$WARNING) {
                formatted_msg <- private$format_fn("WARNING", msg)
                entry <- private$create_log_entry("WARNING", formatted_msg, data)
                private$log_entry(entry)
            }
        },

        #' @description
        #' Log an informational message
        #' @param msg Info message text
        #' @param data Optional data to attach
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
            dir <- path_dir(private$file_path)
            if (!dir_exists(dir)) {
                dir_create(dir, recurse = TRUE)
            }
            if (!file_exists(private$file_path)) {
                file_create(private$file_path)
            }
        },

        ensure_log_table_exists = function() {
            if (!dbExistsTable(private$db_conn, private$table_name)) {
                dbExecute(private$db_conn, sprintf("
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
                    toJSON(entry, auto_unbox = TRUE),
                    "\n",
                    file = private$file_path,
                    append = TRUE
                )
            }
        },

        log_to_db = function(entry) {
            if (!is.null(private$db_conn)) {
                db_entry <- entry
                if (!is.null(db_entry$data)) {
                    db_entry$data <- toJSON(db_entry$data)
                }
                if (!is.null(db_entry$error)) {
                    db_entry$error <- toJSON(db_entry$error)
                }
                if (length(private$context) > 0) {
                    db_entry$context <- toJSON(private$context)
                } else {
                    db_entry$context <- NULL
                }
                # Remove NULL elements from `db_entry`
                db_entry <- db_entry[!sapply(db_entry, is.null)]
                dbWriteTable(private$db_conn, private$table_name, as.data.frame(db_entry), append = TRUE)
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
                msg = msg,
                data = if (!is.null(data)) toJSON(data) else NULL,
                error = if (!is.null(error)) toJSON(private$serialise_error(error)) else NULL,
                context = if (length(private$context) > 0) toJSON(private$context) else NULL
            )
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
            timestamp <- silver(entry$datetime)
            level_color <- switch(
                entry$level,
                ERROR = red,
                WARNING = yellow,
                INFO = blue,
                white
            )
            level <- level_color(sprintf("%-7s", entry$level)) # the %-7s left-aligns the string
            message <- white(entry$msg)

            output <- sprintf("%s %s %s", timestamp, level, message)

            if (!is.null(entry$data)) {
                output <- paste0(
                    output, "\n", cyan("Data:"), "\n",
                    toJSON(fromJSON(entry$data), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            if (!is.null(entry$error)) {
                output <- paste0(
                    output, "\n", red("Error:"), "\n",
                    toJSON(fromJSON(entry$error), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            if (!is.null(entry$context)) {
                output <- paste0(
                    output, "\n", magenta("Context:"), "\n",
                    toJSON(fromJSON(entry$context), auto_unbox = TRUE, pretty = TRUE)
                )
            }

            return(output)
        }
    )
)
