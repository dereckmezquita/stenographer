# stenographer [v1.1.0](https://github.com/dereckmezquita/stenographer/milestone/2)

## BREAKING CHANGES

- **N/A**

## NEW FEATURES

1. **Access set LogLevel:** Use `Stenographer$get_level` to read the current logging level; active field.

## IMPROVEMENTS

1. **Stenographer$set_level method checks value:** The `set_level` method now validates the input value to ensure it is a valid logging level.

## DOCUMENTATION

## DEVELOPMENT

## NOTES

# stenographer [v1.0.0](https://github.com/dereckmezquita/stenographer/milestone/1) (12 January 2025)

## BREAKING CHANGES

- **N/A**

## NEW FEATURES

1. **Hierarchical Logging Levels:** Implemented multiple logging levels (`ERROR`, `WARNING`, `INFO`, `OFF`) to control message output granularity.
2. **File-Based Logging:** Added support for logging messages to user-specified file paths, enabling persistent log storage.
3. **Database Logging Integration:** Integrated database support using `DBI` and `RSQLite` for efficient and scalable log management.
4. **Contextual Logging:** Introduced contextual logging capabilities to attach metadata to log entries, enhancing traceability.
5. **Customisable Message Formatting:** Enabled custom message formatting functions to tailor log output according to user preferences.
6. **Coloured Console Output:** Incorporated `crayon` for colour-coded console messages, improving readability and distinguishing log levels.
7. **Parallel Processing Support:** Developed the `messageParallel` function to handle message output from parallel processes seamlessly.
8. **Structured Error Reporting:** Implemented JSON formatting for structured error reporting, facilitating easier parsing and analysis of log data.
9. **Comprehensive Documentation:** Created detailed vignettes and function documentation to guide users through package features and usage scenarios.

## IMPROVEMENTS

1. **Enhanced Package Structure:** Optimized the internal organization of the package for better maintainability and scalability.
2. **Robust Error Handling:** Improved error handling mechanisms to provide more informative and consistent error messages across the package.
3. **Performance Optimization:** Streamlined logging operations to minimize performance overhead, ensuring efficient execution even in high-throughput environments.
4. **Refined R6 Class Implementation:** Strengthened the `Stenographer` R6 class for more reliable and flexible logging functionality.
5. **Dependency Management:** Managed package dependencies effectively, ensuring that all required packages are correctly specified and utilized within the package codebase.

## DOCUMENTATION

1. **Detailed Vignettes:** Developed comprehensive vignettes demonstrating various use cases, configuration options, and best practices for using the `stenographer` package.
2. **Enhanced Function Documentation:** Expanded function documentation with extensive examples and clearer explanations to assist users in understanding and utilizing package functions effectively.
3. **Comprehensive README:** Updated the `README.md` with installation instructions, feature overviews, and quick start guides to provide users with a clear entry point to the package.

## DEVELOPMENT

1. **Continuous Integration Setup:** Established GitHub Actions workflows for automated testing, coverage reporting, and package checks to ensure code quality and reliability.
2. **Comprehensive Test Suite:** Implemented a robust test suite using `testthat` to validate package functionality and prevent regressions.
3. **CRAN Policy Compliance:** Ensured that the package adheres to CRAN submission policies, facilitating smooth package release and maintenance.
4. **Dependency Management:** Managed package dependencies effectively, ensuring that all required packages are correctly specified and utilized within the package codebase.

## NOTES

1. **First Official Release:** This is the inaugural release of the `stenographer` package, marking its availability for CRAN submission and general use.
2. **R Version Compatibility:** The package is compatible with R versions 4.1.0 and above, ensuring broad usability across different R environments.