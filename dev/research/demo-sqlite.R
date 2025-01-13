box::use(./R/Logger[ Logger ])
box::use(RSQLite[ dbConnect, dbDisconnect, SQLite ])

db <- dbConnect(SQLite(), "my_database.sqlite")

# Create a logger that logs to the database
db_logger <- Logger$new(
    context = list(app_name = "MyApp", version = "1.0.0"),
    db_conn = db,
    table_name = "application_logs"
)
db_logger$info("Database operation completed", data = list(rows_affected = 10))
db_logger$warn("Low disk space", data = list(available_mb = 100))

# Don't forget to close the connection when you're done
dbDisconnect(db)
