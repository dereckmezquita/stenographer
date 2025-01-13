#' @title Print Messages from Parallel Processes
#'
#' @description
#' Enables message output from forked processes during parallel computation using
#' the system's echo command. Primarily designed for use with `parallel` `future`
#' and `future.apply` parallel processing.
#'
#' @param ... Arguments to be concatenated into a single character string for printing
#'
#' @return Invisible NULL, called for its side effect of printing
#'
#' @note
#' This function may have significant resource overhead when used frequently or
#' with large amounts of output. Use sparingly in performance-critical code.
#'
#' @examples
#' # Basic usage
#' messageParallel("Hello World")
#'
#' # Multiple arguments are concatenated
#' messageParallel("Hello", " ", "World")
#' 
#' \donttest{
#' if (requireNamespace("future", quietly = TRUE)) {
#'   future::plan(future::multisession)
#'   f <- future::future({
#'     messageParallel("Message from parallel process")
#'   })
#'   future::value(f)
#'   future::plan(future::sequential)
#' }
#' }
#' @export
messageParallel <- function(...) {
    system(sprintf('echo "%s"', paste0(..., collapse = "")))
}
