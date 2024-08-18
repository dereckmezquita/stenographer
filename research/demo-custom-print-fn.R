box::use(./R/Logger[ Logger, LogLevel ])
box::use(./R/messageParallel[ messageParallel ])
box::use(./R/collapse[ collapse ])

logger <- Logger$new(
    level = LogLevel$INFO,
    file_path = "logs.log",
    print_fn = function(x) {
        messageParallel(x)
    },
    format_fn = function(level, msg) {
        prefix <- switch(level,
            "ERROR" = "E ",
            "WARNING" = "W ",
            "INFO" = "S ",
            "Q "
        )
        return(collapse(c(prefix, msg)))
    }
)

logger$info("This is an info message")


logger <- Logger$new(
    LogLevel$INFO,
    file = "logs.log",
    print_fn = messageParallel,
    format_fn = function(level, msg) {
        return(collapse(c("BOT ID ", "self$id", ": ", msg)))
    }
)

logger$info("This is an info message")
