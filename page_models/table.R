get_table_data <- function(group_by_field) {
  data <- latest_data %>%
    select(-Date, -Lat, -Long) %>%
    add_row(
      "Province.State"  = "World",
      "Country.Region"  = "World",
      "Population"      = 7800000000,
      "Confirmed"       = sum(.$Confirmed, na.rm = TRUE),
      "Confirmed_New"   = sum(.$Confirmed_New, na.rm = TRUE),
      "Deceased"        = sum(.$Deceased, na.rm = TRUE),
      "Deceased_New"    = sum(.$Deceased_New, na.rm = TRUE),
      "Recovered"       = sum(.$Recovered, na.rm = TRUE),
      "Recovered_New"   = sum(.$Recovered_New, na.rm = TRUE),
      "Active"          = sum(.$Active, na.rm = TRUE),
      "Active_New"      = sum(.$Active_New, na.rm = TRUE)
    ) %>%
    group_by(!!sym(group_by_field), Population) %>%
    summarise(
      Confirmed       = sum(Confirmed, na.rm = TRUE),
      Confirmed_New   = sum(Confirmed_New, na.rm = TRUE),
      Confirmed_Norm  = round(sum(Confirmed, na.rm = TRUE) / max(Population, na.rm = TRUE) * 1000, 2),
      Deceased        = sum(Deceased, na.rm = TRUE),
      Deceased_New    = sum(Deceased_New, na.rm = TRUE),
      Recovered       = sum(Recovered, na.rm = TRUE),
      Recovered_New   = sum(Recovered_New, na.rm = TRUE),
      Active          = sum(Active, na.rm = TRUE),
      Active_New      = sum(Active_New, na.rm = TRUE),
      Active_Norm     = round(sum(Active, na.rm = TRUE) / max(Population, na.rm = TRUE) * 1000, 2)
    ) %>%
    select(-Population) %>%
    as.data.frame()
}

output$table <- renderDataTable({
  data <- get_table_data("Country.Region")
  column_names = c(
    "Country",
    "Confirmed Total",
    "Newly Confirmed",
    "Confirmed Total<br>(per 1000)",
    "Deceased Total",
    "Newly Deceased",
    "Recovered Total",
    "Newly Recovered",
    "Active Total",
    "Newly Active",
    "Active Total<br>(per 1000)"
  )
  datatable(
    data,
    rownames = FALSE,
    colnames = column_names,
    escape = FALSE,
    selection = "none",
    options = list(
      pageLength  = -1,
      order = list(8, "desc"),
      scrollX        = TRUE,
      scrollY        = "65vh",
      scrollCollapse = TRUE
    )
  ) %>%
    formatStyle(
      columns = "Country.Region",
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns         = "Confirmed_New",
      valueColumns    = "Confirmed_New",
      backgroundColor = styleInterval(c(50, 500, 1000, 5000, 10000), c("NULL", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(5000, c("#000000", "#FFFFFF"))
    ) %>%
    formatStyle(
      columns         = "Deceased_New",
      valueColumns    = "Deceased_New",
      backgroundColor = styleInterval(c(10, 50, 100, 500, 1000), c("NULL", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(500, c("#000000", "#FFFFFF"))
    ) %>%
    formatStyle(
      columns         = "Active_New",
      valueColumns    = "Active_New",
      backgroundColor = styleInterval(c(-1000, -500, -50, 50, 500, 1000, 5000, 10000), c("#66B066", "#99CA99", "#CCE4CC", "NULL", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(5000, c("#000000", "#FFFFFF"))
    ) %>%
    formatStyle(
      columns         = "Recovered_New",
      valueColumns    = "Recovered_New",
      backgroundColor = styleInterval(c(50, 500, 1000), c("NULL", "#CCE4CC", "#99CA99", "#66B066"))
    )
})
