source("Pages/page_home.R", local = TRUE)
source("Pages/page_table.R", local = TRUE)
source("Pages/page_graphics.R", local = TRUE)
source("Pages/page_about.R", local = TRUE)

ui <- fluidPage(
  title = "COVID-19 Statistics",
  tags$head(
    tags$link(rel = "shortcut icon", type = "image/png", href = "logo.png"),
    tags$link(rel = "stylesheet", href = "css/style.css")
  ),
  navbarPage(
    title = div("COVID-19 Statistical Analysis App"),
    collapsible = TRUE,
    # tabPanel("Home", page_home, value = "page-home"),
    # tabPanel("Table View", page_table, value = "page-table"),
    # tabPanel("Graphics", page_graphics, value = "page-graphics"),
    tabPanel("About", page_about, value = "page-about")
  )
)
server <- function(input, output) { }

shinyApp(ui, server)
