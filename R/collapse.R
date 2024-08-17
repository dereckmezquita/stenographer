#' @title Concatenate a vector of strings
#'
#' @description
#' Helper function for pretty printing vectors. Avoids repetitive paste0 code. If only one element does not add the separator at the end.
#'
#' @param vector Character vector.
#' @param collapse A separator.
#'
#' @return character
#' @export
#'
#' @examples
#' collapse(letters, ", ")
#' collapse(letters[1], ", ")
collapse <- function(vector, collapse = " ") {
    if(length(vector) < 1) {
        return(vector)
    } else {
        return(paste0(vector, collapse = collapse))
    }
}
