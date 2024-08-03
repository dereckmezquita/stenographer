#' Convert a data.frame printout to a string
#'
#' This function captures the output of printing an object as a data.frame and returns it as a single string.
#' It's particularly useful for including tabular data in error messages or log entries as strings.
#'
#' @param obj An R object to be printed and captured.
#'
#' @return Character string
#'
#' @details
#' The function performs the following steps:
#' 1. Converts the input object to a data frame using `as.data.frame()`.
#' 2. Prints the resulting data.frame.
#' 3. Captures the print output using `capture.output()`.
#' 4. Collapses the captured output into a single string with newline characters.
#'
#' This function is particularly useful when you need to include the contents of a table or data frame
#' in a single string, such as when throwing an error message or creating a log entry. It allows you
#' to easily combine textual information with tabular data in a format that can be printed as a cohesive message.
#'
#' @examples
#' # Create a sample data frame
#' df <- data.frame(a = 1:3, b = letters[1:3])
#' 
#' # Use tableToString to get the output as a string
#' output <- tableToString(df)
#' cat(output)
#'
#' # Example of using tableToString in error handling
#' tryCatch({
#'     # Some operation that might fail
#'     if (sum(df$a) > 5) {
#'         stop(
#'             paste("Sum of column 'a' is too high. Current data:",
#'             tableToString(df))
#'         )
#'   }
#' }, error = function(e) {
#'     message("An error occurred: ", e$message)
#' })
#'
#' @export
tableToString <- function(obj) {
    return(paste(utils::capture.output(print(as.data.frame(obj))), collapse = "\n"))
}