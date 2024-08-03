#' Print from parallel forked processes
#'
#' Uses `sprintf` `C` function to echo messages back up to the R console during parallel computation
#' with `future` and `future.apply`.
#' 
#' Beware this function may consume large amounts of resources.
#'
#' @param ... Character vector of messages to print.
#' 
#' @examples
#' messageParallel("Send this message back up.")
#'
#' @export
messageParallel <- function(...) {
    system(sprintf('echo "%s"', paste0(..., collapse = "")))
}