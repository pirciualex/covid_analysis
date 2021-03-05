home_body <- dashboardBody(
  fluidPage(
    fluidRow(
      uiOutput("box_quick_data")
    ),
    fluidRow(
      fluidRow(
        column(
          leafletOutput("map"),
          width = 8
        )
      ),
      fluidRow(
        sliderInput(
          "time_slider",
          label = "Select the date",
          min = min(evolution_data$Date),
          max = max(evolution_data$Date),
          value = max(evolution_data$Date),
          width = "100%",
          timeFormat = "%d-%m-%Y"
        )
      )
    )
  )
)

page_home <- dashboardPage(
  title = "Graphics",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = home_body
)