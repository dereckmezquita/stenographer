#' Default Equality Function for valueCoordinates
#'
#' This helper function is used as the default equality check in valueCoordinates.
#' It handles NA values and uses identical() for non-NA comparisons.
#'
#' @param x The current value in the data.frame
#' @param y The value to compare against (from the `value` parameter of valueCoordinates)
#'
#' @return Logical value indicating whether the condition is met
#'
#' @keywords internal
value_check <- function(x, y) {
    if (is.na(y)) {
        return(is.na(x))
    } else {
        return(identical(x, y))
    }
}

#' Find Coordinates of Specific Values in a data.frame
#'
#' This function locates the row and column coordinates of values in a data.frame
#' that satisfy a given condition. It's particularly useful for identifying the
#' positions of specific or problematic values in large datasets.
#'
#' @param df A data.frame to be searched.
#' @param value The value to search for. Default is NA.
#' @param eq_fun A function used to check equality. It should take two arguments:
#'   the current value in the data.frame and the `value` parameter. 
#'   Default is the internal `eq_fun` function that uses `identical()` for non-NA values and `is.na()` for NA.
#'
#' @return A data.frame with two columns:
#'   \item{column}{The column numbers where the specified condition was met}
#'   \item{row}{The row numbers where the specified condition was met}
#'   The returned data.frame is sorted first by column, then by row.
#'
#' @details
#' The function performs the following steps:
#' 1. Creates a logical matrix where TRUE indicates values meeting the specified condition.
#' 2. Finds the row and column indices of TRUE values.
#' 3. Combines these indices into a data.frame.
#' 4. Sorts the results by column, then by row.
#'
#' If no custom equality function is provided, the function uses the internal `eq_fun`
#' which checks for NA values with `is.na()` and uses `identical()` for all other values.
#'
#' @examples
#' # Create a sample data.frame
#' df <- data.frame(
#'   a = c(1, NA, 3),
#'   b = c(NA, 2, NA),
#'   c = c(3, 2, 1)
#' )
#'
#' # Find coordinates of NA values
#' valueCoordinates(df)
#'
#' # Find coordinates of the value 2
#' valueCoordinates(df, 2)
#'
#' # Find coordinates of values greater than 2
#' valueCoordinates(df, 2, function(x, y) x > y)
#'
#' # Find coordinates of values within a range
#' valueCoordinates(df, c(1, 3), function(x, y) x >= y[1] & x <= y[2])
#'
#' @export
valueCoordinates <- function(df, value = NA, eq_fun = value_check) {
    if (!is.data.frame(df)) {
        rlang::abort("'df' must be a data frame")
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
    return(result_df[order(result_df$column, result_df$row), ])
}
