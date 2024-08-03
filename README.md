
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- <img src="./.graphics/512-20240803_logger-logo.png" align="right" height="140" /> -->

# Logger <a href="https://dereckmezquita.github.io/R-Logger"></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/dereckmezquita/kucoin.svg?branch=master)](https://travis-ci.org/dereckmezquita/kucoin)
<!-- badges: end -->

Logger is a flexible and powerful logging system for R applications. It
provides a `Logger` class for creating customisable loggers, as well as
helper functions for debugging and error reporting.

## Installation

You can install Logger from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("Logger")
```

## Basic Usage

Here’s a quick example of how to use Logger:

``` r
box::use(Logger[Logger, LogLevel])

# Create a basic logger
log <- Logger$new()

# Log some messages
log$info("This is an informational message")
#> 2024-08-03T10:44:09.280Z INFO    This is an informational message
log$warn("This is a warning")
#> 2024-08-03T10:44:09.287Z WARNING This is a warning
log$error("This is an error")
#> 2024-08-03T10:44:09.309Z ERROR   This is an error
```

## Features

### Customisable Logging

You can customise the logger by specifying the minimum log level, output
file, and custom print function:

``` r
log_file <- tempfile("app_log")

custom_log <- Logger$new(
    level = LogLevel$WARNING,
    file_path = log_file,
    print_fn = message
)

custom_log$info("This won't be logged")
custom_log$warn("This will be logged to console and file")
#> 2024-08-03T10:44:09.508Z WARNING This will be logged to console and file
custom_log$error("This is an error message")
#> 2024-08-03T10:44:09.524Z ERROR   This is an error message
```

Logs are written to the specified file as JSON objects:

``` r
cat(readLines(log_file), sep = "\n")
#> {"datetime":"2024-08-03T10:44:09.508Z","level":"WARNING","msg":"This will be logged to console and file"} 
#> {"datetime":"2024-08-03T10:44:09.524Z","level":"ERROR","msg":"This is an error message"}
```

### Helper Functions

Logger includes helper functions like `valueCoordinates` and
`tableToString` to provide detailed context in log messages:

``` r
box::use(Logger[valueCoordinates, tableToString])

# Create a sample dataset with some issues
df <- data.frame(
    a = c(1, NA, 3, 4, 5),
    b = c(2, 4, NA, 8, 10),
    c = c(3, 6, 9, NA, 15)
)

# Find coordinates of NA values
na_coords <- valueCoordinates(df)

if (nrow(na_coords) > 0) {
    log$warn(
        "NA values found in the dataset",
        data = list(
            na_locations = na_coords,
            dataset_preview = tableToString(df)
        )
    )
}
#> 2024-08-03T10:44:09.538Z WARNING NA values found in the dataset
#> Data:
#> {
#>   "na_locations": [
#>     {
#>       "column": 1,
#>       "row": 2
#>     },
#>     {
#>       "column": 2,
#>       "row": 3
#>     },
#>     {
#>       "column": 3,
#>       "row": 4
#>     }
#>   ],
#>   "dataset_preview": "   a  b  c\n1  1  2  3\n2 NA  4  6\n3  3 NA  9\n4  4  8 NA\n5  5 10 15"
#> }
```

### Error Logging with Context

Logger makes it easy to log errors with context:

``` r
process_data <- function(df) {
    tryCatch({
        result <- df$a / df$b
        if (any(is.infinite(result))) {
            inf_coords <- valueCoordinates(data.frame(result), Inf)
            log$error(
                "Division by zero occurred",
                data = list(
                    infinite_values = inf_coords,
                    dataset_preview = tableToString(df)
                )
            )
            stop("Division by zero error")
        }
        return(result)
    }, error = function(e) {
        log$error(
            paste("An error occurred while processing data:", e$message),
            data = list(dataset_preview = tableToString(df)),
            error = e
        )
        stop(e)
    })
}

# Test the function with problematic data
df <- data.frame(a = c(1, 2, 3), b = c(0, 2, 0))
process_data(df)
#> 2024-08-03T10:44:09.550Z ERROR   Division by zero occurred
#> Data:
#> {
#>   "infinite_values": [
#>     {
#>       "column": 1,
#>       "row": 1
#>     },
#>     {
#>       "column": 1,
#>       "row": 3
#>     }
#>   ],
#>   "dataset_preview": "  a b\n1 1 0\n2 2 2\n3 3 0"
#> } 
#> 2024-08-03T10:44:09.574Z ERROR   An error occurred while processing data: Division by zero error
#> Data:
#> {
#>   "dataset_preview": "  a b\n1 1 0\n2 2 2\n3 3 0"
#> }
#> Error:
#> {
#>   "name": "simpleError",
#>   "message": "Division by zero error",
#>   "call": "doTryCatch(return(expr), name, parentenv, handler)"
#> }
#> Error in doTryCatch(return(expr), name, parentenv, handler): Division by zero error
```

### Parallel Processing Support

Logger provides support for logging in parallel environments:

``` r
box::use(future)
box::use(future.apply[future_lapply])
box::use(Logger[messageParallel])

log <- Logger$new(print_fn = messageParallel)

future::plan(future::multisession, workers = 2)

result <- future_lapply(1:5, function(i) {
    messageParallel(sprintf("Processing item %d", i))
    if (i == 3) {
        log$warn(sprintf("Warning for item %d", i))
    }
    return(i * 2)
})

future::plan(future::sequential)
```

## Contributing

Contributions to Logger are welcome! Please refer to the
[CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

## License

Logger is released under the MIT License. See the [LICENSE](LICENSE)
file for details.

## More Information

For more detailed information and examples, please refer to the package
vignette:

``` r
vignette("getting-started-with-Logger", package = "Logger")
```
