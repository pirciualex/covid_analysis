about_body <- dashboardBody(
  fluidRow(
    column(
      box(
        title = "ABOUT",
        p("This is an application that analyses covid cases and present them in
        a visual manner. It uses data provided by Johns Hopkins University
          on their Center for Systems Science and Engineering (CSSE)",
          a("github repository", href = "https://github.com/CSSEGISandData/COVID-19"),
          "."),
        width = 6
      ),
      box(
        title = "Technologies used",
        p("This app was made using:"),
        a(img(src = "img/r_logo.png", alt = "R logo"),
          href = "https://www.r-project.org/"),
        a(img(src = "img/shiny_logo.jpg", alt = "Shiny logo"),
          href = "https://shiny.rstudio.com/"),
        a(img(src = "img/plotly_logo.png", alt = "Plotly logo"),
          href = "https://plotly.com/"),
        width = 6,
        class = "technologies"
      ),
      width = 12
    )
  ),
  class = "about-page"
)

page_about <- dashboardPage(
  title = "About",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = about_body
)
