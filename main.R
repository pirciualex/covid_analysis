library("pacman")
pacman::p_load(shiny, shinydashboard, dashboard, DT, fs, wbstats,
               leaflet, plotly, tidyverse, magrittr, htmltools)

source("utils.R")


# Fetch and read the data
fetch_data <- function() {
  download.file(
    url = "https://github.com/CSSEGISandData/COVID-19/archive/master.zip",
    destfile = "data/covid_data.zip")
  
  data_path <- "COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_"
  
  unzip(
    zipfile = "data/covid_data.zip",
    files = paste0(data_path, c("confirmed_global.csv", "deaths_global.csv", "recovered_global.csv")),
    exdir = "data",
    junkpaths = TRUE
  )
}

update_data <- function() {
  if (!dir.exists("data")) {
    dir.create("data")
  }
  if((!file.exists("data/covid_data.zip")) ||
     (difftime(Sys.time(), file.info("data/covid_data.zip")$ctime, units = "hours") > 24)) {
    fetch_data()
  }
}

read_data <- function() {
  update_data()
  
  confirmed_data   <- read.csv("data/time_series_covid19_confirmed_global.csv")
  deaths_data      <- read.csv("data/time_series_covid19_deaths_global.csv")
  recovered_data   <- read.csv("data/time_series_covid19_recovered_global.csv")
  
  last_column <- names(confirmed_data)[ncol(confirmed_data)]
  last_date <- substr(last_column, 2, nchar(last_column))
  data_last_update <- as.Date(last_date, format = "%m.%d.%y")
  assign("data_last_update", data_last_update, envir = .GlobalEnv)
  files_last_update <- file.info("data/covid_data.zip")$ctime
  assign("files_last_update", files_last_update, envir = .GlobalEnv)
  
  
  # Preprocessing the data
  confirmed_data_proc <-  confirmed_data %>%
    pivot_longer(names_to = "Date", cols = 5:ncol(confirmed_data) )%>%
    group_by(Province.State, Country.Region, Date, Lat, Long) %>%
    summarise("Confirmed" = sum(value, na.rm = TRUE)) %>%
    mutate(Date = substr(Date, 2, nchar(Date)))
  
  deaths_data_proc <-     deaths_data %>%
    pivot_longer(names_to = "Date", cols = 5:ncol(deaths_data) )%>%
    group_by(Province.State, Country.Region, Date, Lat, Long) %>%
    summarise("Deceased" = sum(value, na.rm = TRUE)) %>%
    mutate(Date = substr(Date, 2, nchar(Date)))
  
  recovered_data_proc <-  recovered_data %>%
    pivot_longer(names_to = "Date", cols = 5:ncol(recovered_data) )%>%
    group_by(Province.State, Country.Region, Date, Lat, Long) %>%
    summarise("Recovered" = sum(value, na.rm = TRUE)) %>%
    mutate(Date = substr(Date, 2, nchar(Date)))
  
  population <- wb(country = "countries_only", indicator = "SP.POP.TOTL", startdate = 2019, enddate = 2020) %>%
    select(country, value) %>%
    rename(Population = value)
  country_names_set <- c("Brunei Darussalam", "Congo, Dem. Rep.", "Congo, Rep.",
                       "Czech Republic", "Egypt, Arab Rep.", "Iran, Islamic Rep.",
                       "Korea, Rep.", "St. Lucia", "West Bank and Gaza",
                       "Russian Federation", "Slovak Republic", "United States",
                       "St. Vincent and the Grenadines", "Venezuela, RB")
  country_names_data  <- c("Brunei", "Congo (Kinshasa)", "Congo (Brazzaville)",
                        "Czechia", "Egypt", "Iran", "Korea, South", "Saint Lucia",
                        "occupied Palestinian territory", "Russia", "Slovakia",
                        "US", "Saint Vincent and the Grenadines", "Venezuela")
  population[which(population$country %in% country_names_set), "country"] <- country_names_data
  countries_with_no_data <- data.frame(
    country = c("Bahamas", "Burma", "Diamond Princess", "Eritrea", "Gambia",
                   "Guadeloupe", "Guernsey", "Holy See", "Jersey", "Kyrgyzstan",
                   "Laos", "Martinique", "Micronesia", "MS Zaandam", "Reunion",
                   "Saint Kitts and Nevis", "Syria", "Taiwan*", "West Bank and Gaza", "Yemen"),
    Population = c(385637, 53582855, 1100, 6081196, 2173999, 395700, 63026, 800,
                   106800, 6586600, 7123205, 376480, 112640, 615, 859959, 52441,
                   17500657, 23780452, 3340143, 28498683)
  )
  population <- bind_rows(population, countries_with_no_data)
  
  evolution_data <- confirmed_data_proc %>%
    full_join(deaths_data_proc) %>%
    full_join(recovered_data_proc) %>%
    ungroup() %>%
    mutate(Date = as.Date(Date, "%m.%d.%y")) %>%
    arrange(Date) %>%
    group_by(Province.State, Country.Region, Lat, Long) %>%
    mutate(Active = Confirmed - Recovered - Deceased) %>%
    ungroup() %>%
    group_by(Province.State, Country.Region) %>%
    mutate(Confirmed_New = Confirmed - lag(Confirmed, 1, default = 0)) %>%
    mutate(Deceased_New = Deceased - lag(Deceased, 1, default = 0)) %>%
    mutate(Recovered_New = Recovered - lag(Recovered, 1, default = 0)) %>%
    mutate(Active_New = Active - lag(Active, 1, default = 0)) %>%
    ungroup() %>%
    left_join(population, by = c(Country.Region = "country"))
  ?left_join
  assign("evolution_data", evolution_data, envir = .GlobalEnv)
  
  latest_data <-  evolution_data[which(evolution_data$Date == data_last_update),] %>%
    distinct()
  assign("latest_data", latest_data, envir = .GlobalEnv)
  
  top_5_countries <-  evolution_data %>%
    filter(Date == data_last_update) %>%
    group_by(Country.Region) %>%
    summarise(Active = sum(Active, na.rm = TRUE)) %>%
    arrange(desc(Active)) %>%
    top_n(5) %>%
    select(Country.Region)
}

data_at_date <- function(input_date) {
  evolution_data[which(evolution_data$Date == input_date),] %>%
    distinct()
}

read_data()
source("ui.R", local = FALSE)
source("server.R", local = FALSE)
shinyApp(ui, server)
