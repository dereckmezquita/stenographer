#' @title Concatenate Vector Elements with Optional Separator
#'
#' @description
#' Concatenates vector elements into a single string. Unlike `paste0`, it handles
#' single-element vectors without adding a trailing separator.
#'
#' @param vector A character vector to be concatenated
#' @param collapse String to use as separator between elements (default: " ")
#'
#' @return A character string containing the concatenated elements
#'
#' @examples
#' # Multiple elements
#' collapse(c("a", "b", "c"), ", ")  # Returns "a, b, c"
#'
#' # Single element - no trailing separator
#' collapse("a", ", ")  # Returns "a"
#'
#' # With default separator
#' collapse(c("Hello", "World"))  # Returns "Hello World"
#'
#' # Empty vector
#' collapse(character(0), ", ")  # Returns character(0)
#'
#' @importFrom rlang abort
#' @export
collapse <- function(vector, collapse = " ") {
    if (!is.character(collapse) || length(collapse) != 1) {
        abort("'collapse' must be a single string")
    }
    if (!is.vector(vector)) {
        abort("'vector' must be a vector")
    }
    if (length(vector) < 1) {
        return(vector)
    }
    return(paste0(vector, collapse = collapse))
}
