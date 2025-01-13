#' @title Default Equality Function for valueCoordinates
#'
#' @description
#' A helper function that performs equality checks between values, with special
#' handling for NA values.
#'
#' @param x A value from the data frame being searched
#' @param y The target value to compare against
#'
#' @return A logical value: TRUE if the values match according to the comparison rules,
#'         FALSE otherwise
#'
#' @keywords internal
value_check <- function(x, y) {
    if (is.na(y)) {
        return(is.na(x))
    } else {
        return(identical(x, y))
    }
}

#' @title Locate Specific Values in a Data Frame
#'
#' @description
#' Finds the positions (row and column indices) of values in a data.frame that match
#' specified criteria. This function is useful for locating particular values within
#' large datasets.
#'
#' @param df A data.frame to search
#' @param value The target value to find (default: NA)
#' @param eq_fun A comparison function that takes two parameters: the current value
#'        from the data.frame and the target value. Returns TRUE for matches.
#'        Default uses internal value_check function; handles NA values.
#'
#' @return A data.frame with two columns:
#' \describe{
#'   \item{column}{Column indices where matches were found}
#'   \item{row}{Row indices where matches were found}
#' }
#' Results are sorted by column, then by row.
#'
#' @examples
#' # Sample data.frame
#' df <- data.frame(
#'   a = c(1, NA, 3),
#'   b = c(NA, 2, NA),
#'   c = c(3, 2, 1)
#' )
#'
#' # Find NA positions
#' valueCoordinates(df)
#'
#' # Find positions of value 2
#' valueCoordinates(df, 2)
#'
#' # Find positions where values exceed 2
#' valueCoordinates(df, 2, function(x, y) x > y)
#'
#' # Find positions of values in range [1,3]
#' valueCoordinates(df, c(1, 3), function(x, y) x >= y[1] & x <= y[2])
#'
#' @importFrom rlang abort
#' @export
valueCoordinates <- function(df, value = NA, eq_fun = value_check) {
    if (!is.data.frame(df)) {
        abort("'df' must be a data.frame")
    }

    if (!is.function(eq_fun)) {
        abort("'eq_fun' must be a function")
    }
    
    # Rest of the original code remains exactly the same
    truths <- apply(df, c(1, 2), function(x) eq_fun(x, value))

    r <- apply(truths, 2, function(x) {
        if(any(which(x))) {
            return(unname(which(x)))
        } else {
            return(NA)
        }
    })

    c <- apply(truths, 1, function(y) {
        if(any(which(y))) {
            return(unname(which(y)))
        } else {
            return(NA)
        }
    })

    r <- unname(r[!is.na(r)])
    c <- unname(c[!is.na(c)])

    result_df <- data.frame(column = unlist(c), row = unlist(r))

    if (nrow(result_df) == 0) {
        return(data.frame(column = integer(), row = integer()))
    }

    return(result_df[order(result_df$column, result_df$row), ])
}
