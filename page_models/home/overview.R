sum_data <- function(date) {
  if (date >= min(evolution_data$Date)) {
    data <- data_at_date(date) %>% summarise(
      Confirmed = sum(Confirmed, na.rm = T),
      Recovered = sum(Recovered, na.rm = T),
      Deceased  = sum(Deceased, na.rm = T),
      Countries = n_distinct(Country.Region)
    )
    return(data)
  }
  return(NULL)
}

key_figures <- reactive({
  data           <- sum_data(input$time_slider)
  data_yesterday <- sum_data(input$time_slider - 1)
  
  data_new <- list(
    new_confirmed = (data$Confirmed - data_yesterday$Confirmed) / data_yesterday$Confirmed * 100,
    new_recovered = (data$Recovered - data_yesterday$Recovered) / data_yesterday$Recovered * 100,
    new_deceased  = (data$Deceased - data_yesterday$Deceased) / data_yesterday$Deceased * 100,
    new_countries = data$Countries - data_yesterday$Countries
  )
  
  keyFigures <- list(
    "confirmed" = HTML(paste(format(data$Confirmed, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new$new_confirmed))),
    "recovered" = HTML(paste(format(data$Recovered, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new$new_recovered))),
    "deceased"  = HTML(paste(format(data$Deceased, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new$new_deceased))),
    "countries" = HTML(paste(format(data$Countries, big.mark = " "), "/ 195", sprintf("<h4>(%+d)</h4>", data_new$new_countries)))
  )
  keyFigures
})

output$valueBox_confirmed <- renderValueBox({
  valueBox(
    key_figures()$confirmed,
    subtitle = "Confirmed",
    icon     = icon("file-medical"),
    color    = "yellow",
    width    = NULL
  )
})


output$valueBox_recovered <- renderValueBox({
  valueBox(
    key_figures()$recovered,
    subtitle = "Estimated Recoveries",
    icon     = icon("heart"),
    color    = "yellow"
  )
})

output$valueBox_deceased <- renderValueBox({
  valueBox(
    key_figures()$deceased,
    subtitle = "Deceased",
    icon     = icon("heartbeat"),
    color    = "yellow"
  )
})

output$valueBox_countries <- renderValueBox({
  valueBox(
    key_figures()$countries,
    subtitle = "Affected Countries",
    icon     = icon("flag"),
    color    = "yellow"
  )
})

output$box_quick_data <- renderUI(box(
  title = paste0("Overview (", strftime(input$time_slider, format = "%d.%m.%Y"), ")"),
  fluidRow(
    column(
      valueBoxOutput("valueBox_confirmed", width = 3),
      valueBoxOutput("valueBox_recovered", width = 3),
      valueBoxOutput("valueBox_deceased", width = 3),
      valueBoxOutput("valueBox_countries", width = 3),
      width = 12,
      style = "margin-left: -20px"
    )
  ),
  div("Last updated: ", strftime(files_last_update, format = "%d.%m.%Y - %R %Z")),
  width = 12
))