graphics_body <- dashboardBody(
  fluidPage(
    uiOutput("graphics")
  )
)

page_graphics <- dashboardPage(
  title = "Graphics",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = graphics_body
)