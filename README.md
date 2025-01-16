
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- <img src="./.graphics/512-stenographer-logo.png" align="right" height="140" /> -->

# stenographer <a href="https://dereckmezquita.github.io/stenographer/"></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/dereckmezquita/stenographer/workflows/R-CMD-check/badge.svg)](https://github.com/dereckmezquita/stenographer/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/stenographer)](https://CRAN.R-project.org/package=stenographer)
[![GitHub
version](https://img.shields.io/github/r-package/v/dereckmezquita/stenographer?label=GitHub)](https://github.com/dereckmezquita/stenographer)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Downloads](https://cranlogs.r-pkg.org/badges/stenographer)](https://cran.r-project.org/package=stenographer)
<!-- badges: end -->

The `stenographer` package provides a flexible logging framework with
hierarchical logging levels, database integration, and contextual
logging capabilities. It includes support for SQLite storage,
colour-coded output, and parallel processing support.

The latest version includes support for `SQLite` database logging and
context management.

## Installation

You can install the released version of stenographer from CRAN:

``` r
install.packages("stenographer")
```

You can install stenographer from
[www.github.com/dereckmezquita/stenographer](https://github.com/dereckmezquita/stenographer)
with:

``` r
# install.packages("remotes")
remotes::install_github("dereckmezquita/stenographer")
```

## Basic Usage

Here’s a quick example of how to use stenographer:

``` r
box::use(stenographer[Stenographer, LogLevel])

# Create a basic logger
steno <- Stenographer$new()

# Log some messages
steno$info("This is an informational message")
#> 2025-01-13T13:55:15.524Z INFO    This is an informational message
steno$warn("This is a warning")
#> 2025-01-13T13:55:15.526Z WARNING This is a warning
steno$error("This is an error")
#> 2025-01-13T13:55:15.549Z ERROR   This is an error
```

## Features

### Customisable Logging

You can customise the stenographer by specifying the minimum log level,
output file, and custom print function:

``` r
log_file <- tempfile("app_log")

custom_steno <- Stenographer$new(
    level = LogLevel$WARNING,
    file_path = log_file,
    print_fn = message
)

custom_steno$info("This won't be logged")
custom_steno$warn("This will be logged to console and file")
#> 2025-01-13T13:55:15.650Z WARNING This will be logged to console and file
custom_steno$error("This is an error message", error = "Some error")
#> 2025-01-13T13:55:15.651Z ERROR   This is an error message
#> Error:
#> "Some error"
```

Logs are written to the specified file as JSON objects:

``` r
cat(readLines(log_file), sep = "\n")
#> {"datetime":"2025-01-13T13:55:15.650Z","level":"WARNING","msg":"This will be logged to console and file","data":{},"error":{},"context":{}} 
#> {"datetime":"2025-01-13T13:55:15.651Z","level":"ERROR","msg":"This is an error message","data":{},"error":"[\"Some error\"]","context":{}}
```

### Database Logging

stenographer now supports logging to a SQLite database and context
management so you can easily track application events. The context is
useful for filtering and querying logs based on specific criteria from
`SQLite`:

``` r
box::use(RSQLite[ SQLite ])
box::use(DBI[ dbConnect, dbDisconnect, dbGetQuery ])

# Create a database connection
db <- dbConnect(SQLite(), "log.sqlite")

# Create a stenographer that logs to the database
db_steno <- Stenographer$new(
    context = list(app_name = "MyApp", fun = "main"),
    db_conn = db,
    table_name = "app_logs"
)

# Log some messages
db_steno$info("This is logged to the database")
#> 2025-01-13T13:55:15.772Z INFO    This is logged to the database
#> Context:
#> {
#>   "app_name": "MyApp",
#>   "fun": "main"
#> }
db_steno$warn("This is a warning", data = list(code = 101))
#> 2025-01-13T13:55:15.778Z WARNING This is a warning
#> Data:
#> {
#>   "code": 101
#> }
#> Context:
#> {
#>   "app_name": "MyApp",
#>   "fun": "main"
#> }
db_steno$error("An error occurred", error = "Division by zero")
#> 2025-01-13T13:55:15.844Z ERROR   An error occurred
#> Error:
#> "Division by zero"
#> Context:
#> {
#>   "app_name": "MyApp",
#>   "fun": "main"
#> }

# Example of querying the logs
query <- "SELECT * FROM app_logs WHERE level = 'ERROR'"
result <- dbGetQuery(db, query)
print(result)
#>   id                 datetime level                               context
#> 1  3 2025-01-12T20:03:40.117Z ERROR {"app_name":["MyApp"],"fun":["main"]}
#> 2  6 2025-01-13T13:54:50.711Z ERROR {"app_name":["MyApp"],"fun":["main"]}
#> 3  9 2025-01-13T13:55:15.844Z ERROR {"app_name":["MyApp"],"fun":["main"]}
#>                 msg data                        error
#> 1 An error occurred <NA> ["[\\"Division by zero\\"]"]
#> 2 An error occurred <NA> ["[\\"Division by zero\\"]"]
#> 3 An error occurred <NA> ["[\\"Division by zero\\"]"]

# Don't forget to close the database connection when you're done
dbDisconnect(db)
```

### Helper Functions

Stenographer includes helper functions like `valueCoordinates` and
`tableToString` to provide detailed context in log messages:

``` r
box::use(stenographer[valueCoordinates, tableToString])

# Create a sample dataset with some issues
df <- data.frame(
    a = c(1, NA, 3, 4, 5),
    b = c(2, 4, NA, 8, 10),
    c = c(3, 6, 9, NA, 15)
)

# Find coordinates of NA values
na_coords <- valueCoordinates(df)

if (nrow(na_coords) > 0) {
    steno$warn(
        "NA values found in the dataset",
        data = list(
            na_locations = na_coords,
            dataset_preview = tableToString(df)
        )
    )
}
#> 2025-01-13T13:55:15.858Z WARNING NA values found in the dataset
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

stenographer makes it easy to log errors with context:

``` r
process_data <- function(df) {
    tryCatch({
        result <- df$a / df$b
        if (any(is.infinite(result))) {
            inf_coords <- valueCoordinates(data.frame(result), Inf)
            steno$error(
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
        steno$error(
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
#> 2025-01-13T13:55:15.883Z ERROR   Division by zero occurred
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
#> 2025-01-13T13:55:15.884Z ERROR   An error occurred while processing data: Division by zero error
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

stenographer provides support for logging in parallel environments:

``` r
box::use(future)
box::use(future.apply[future_lapply])
box::use(stenographer[messageParallel])

steno <- Stenographer$new(print_fn = messageParallel)

future::plan(future$multisession, workers = 2)

result <- future_lapply(1:5, function(i) {
    messageParallel(sprintf("Processing item %d", i))
    if (i == 3) {
        steno$warn(sprintf("Warning for item %d", i))
    }
    return(i * 2)
})

future::plan(future::sequential)
```

    #> Processing item 1
    #> Processing item 2
    #> Processing item 3
    #> 2024-08-03T11:18:03.091Z WARNING Warning for item 3
    #> Processing item 4
    #> Processing item 5

## Contributing

Contributions to stenographer are welcome! Please refer to the
[CONTRIBUTING.md](https://github.com/dereckmezquita/stenographer/blob/master/CONTRIBUTING.md)
file for guidelines.

## License

This package is licensed under the MIT License.

## Citation

If you use this package in your research or work, please cite it as:

Mezquita, D. (2025). stenographer: Flexible and Customisable Logging
System. R package version 1.0.0.
<https://github.com/dereckmezquita/stenographer>
