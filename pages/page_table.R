table_body <- dashboardBody(
  fluidPage(
    h3(paste0("Table containing data for ", strftime(data_last_update, format = "%d-%m-%Y"))),
    div(
      dataTableOutput("table"),
      class = "table"
    )
  ),
  class = "table-page"
)

page_table <- dashboardPage(
  title = "Table",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = table_body
)