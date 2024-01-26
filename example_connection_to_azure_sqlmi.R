library(RODBC)
library(odbc)
library(DBI)

con <- dbConnect(
          odbc::odbc(),
          driver = "ODBC Driver 17 for SQL Server",
          server = "sqlmi-sequelae-prod-00.e20b8ffb27b6.database.windows.net",
          database = "sqlmidb_person_im",
          authentication = "ActiveDirectoryPassword",
          port = 1433,
          uid = Sys.getenv("SEQUELAE_MICROSOFT_USERNAME"),
          pwd = Sys.getenv("SEQUELAE_MICROSOFT_PASSWORD")
      )