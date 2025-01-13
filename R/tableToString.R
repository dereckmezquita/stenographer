#' @title Convert a Data Frame or R Object to a String Representation
#'
#' @description
#' Captures the printed output of a data.frame or an R object (coerced to a data.frame)
#' as a single string with preserved formatting. Useful for error messages, logging,
#' and string-based output.
#'
#' @param obj An R object that can be coerced to a data.frame
#'
#' @return A character string containing the formatted table output with newlines
#'
#' @examples
#' # Basic usage with a data.frame
#' df <- data.frame(
#'   numbers = 1:3,
#'   letters = c("a", "b", "c")
#' )
#' str_output <- tableToString(df)
#' cat(str_output)
#'
#' # Using in error messages
#' df <- data.frame(value = c(10, 20, 30))
#' if (any(df$value > 25)) {
#'   msg <- sprintf(
#'     "Values exceed threshold:\n%s",
#'     tableToString(df)
#'   )
#'   message(msg)
#' }
#'
#' @importFrom utils capture.output
#' @export
tableToString <- function(obj) {
    return(paste(capture.output(print(as.data.frame(obj))), collapse = "\n"))
}
