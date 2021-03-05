output$cases_evolution <- renderPlotly({
  data <- evolution_data %>%
    group_by(Date)  %>%
    summarise(
      Confirmed = sum(Confirmed, na.rm = T),
      Deceased = sum(Deceased, na.rm = T),
      Recovered = sum(Recovered, na.rm = T),
      Active = sum(Active, na.rm = T)
    ) %>%
    as.data.frame()
  
  p <- plot_ly(
    data,
    x = ~Date,
    y = ~Confirmed,
    name = "Confirmed",
    type = 'scatter',
    mode = 'lines') %>%
    add_trace(
      y = ~Deceased,
      name = "Deceased"
    ) %>%
    add_trace(
      y = ~Recovered,
      name = "Recovered"
    ) %>%
    add_trace(
      y = ~Active,
      name = "Active"
    ) %>%
    layout(
      yaxis = list(title = "# Cases"),
      xaxis = list(title = "Date"),
      colorway = c('#271cb6', '#f00c29', '#0edc28', '#e57d00')
    )
  
  if (input$checkbox_log_case_evolution) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  p
})

output$graphics <- renderUI({
  tagList(
    fluidRow(
      title = "Evolution of Cases since Outbreak",
      plotlyOutput("cases_evolution"),
      div(
        checkboxInput("checkbox_log_case_evolution", label = "Logarithmic Display", value = FALSE),
        class = "log-checkbox"
      ),
      class = "cases-graphic"
    )
  )
})