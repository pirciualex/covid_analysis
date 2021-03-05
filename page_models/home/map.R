add_label <- function(data) {
  data$label <- paste0(
    '<b>', ifelse(is.na(data$Province.State), data$Country.Region, data$Province.State), '</b><br>
    <table>
    <tr><td>Confirmed:</td><td', data$Confirmed, '</td></tr>
    <tr><td>Deceased:</td><td align="right">', data$Deceased, '</td></tr>
    <tr><td>Recovered:</td><td align="right">', data$Recovered, '</td></tr>
    <tr><td>Active:</td><td align="right">', data$Active, '</td></tr>
    </table>'
  )
  data$label <- lapply(data$label, HTML)
  data
}

map <- leaflet() %>%
  setMaxBounds(-180, -90, 180, 90) %>%
  setView(0, 20, zoom = 2) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Light") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satellite") %>%
  addLayersControl(
    baseGroups    = c("Light", "Satellite"),
    overlayGroups = c("Confirmed", "Deceased", "Recovered", "Active")
  ) %>%
  hideGroup("Deceased") %>%
  hideGroup("Recovered") %>%
  hideGroup("Active") %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-globe", title = "Reset zoom",
    onClick = JS("function(btn, map){ map.setView([20, 0], 2); }"))) %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-map-marker", title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true, maxZoom: 6}); }")))

# print(evolution_data[which(evolution_data$Date == input$time_slider),] %>% add_label())
observe({
  req(input$time_slider, input$overview_map_zoom)
  zoomLevel <- input$overview_map_zoom
  data <- data_at_date(input$timeSlider) %>% add_label()
  print(data)
  # data$confirmedPerCapita <- data$confirmed / data$population * 100000
  # data$activePerCapita    <- data$active / data$population * 100000

  leafletProxy("map", data = data) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng = ~Long,
      lat = ~Lat,
      radius = ~log(Confirmed^(zoomLevel / 2)),
      stroke = FALSE,
      fillOpacity = 0.5,
      label = ~label,
      labelOptions = labelOptions(textsize = 15),
      group = "Confirmed"
    ) %>%
    # addCircleMarkers(
    #   lng          = ~Long,
    #   lat          = ~Lat,
    #   radius       = ~log(confirmedPerCapita^(zoomLevel)),
    #   stroke       = FALSE,
    #   color        = "#00b3ff",
    #   fillOpacity  = 0.5,
    #   label        = ~label,
    #   labelOptions = labelOptions(textsize = 15),
    #   group        = "Confirmed (per capita)"
    # ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(Recovered^(zoomLevel)),
      stroke       = FALSE,
      color        = "#000000",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group = "Recovered"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(Deceased^(zoomLevel)),
      stroke       = FALSE,
      color        = "#EEEEEE",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Deceased"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(Active^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#000000",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Active"
    )
  # %>%
  #   addCircleMarkers(
  #     lng          = ~Long,
  #     lat          = ~Lat,
  #     radius       = ~log(activePerCapita^(zoomLevel)),
  #     stroke       = FALSE,
  #     color        = "#EEEEEE",
  #     fillOpacity  = 0.5,
  #     label        = ~label,
  #     labelOptions = labelOptions(textsize = 15),
  #     group        = "Active (per capita)"
  #   )
})

output$map <- renderLeaflet(map)