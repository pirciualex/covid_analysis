library("pacman")
pacman::p_load(shiny, shinydashboard, dashboard, DT, fs, wbstats,
               leaflet, plotly, tidyverse, magrittr)

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
     (difftime(Sys.time(), file.info("data/covid_data.zip")$ctime, units = "hours") > 10)) {
    fetch_data()
  }
}

update_data()

confirmed_data   <- read.csv("data/time_series_covid19_confirmed_global.csv")
deaths_data      <- read.csv("data/time_series_covid19_deaths_global.csv")
recovered_data   <- read.csv("data/time_series_covid19_recovered_global.csv")

last_column <- names(confirmed_data)[ncol(confirmed_data)]
last_date <- substr(last_column, 2, nchar(last_column))
data_last_update <- as.Date(last_date, format = "%m.%d.%y")
files_last_update <- file.info("data/covid_data.zip")$ctime


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

evolution_data <- confirmed_data_proc %>%
                  full_join(deaths_data_proc) %>%
                  full_join(recovered_data_proc) %>%
                  ungroup() %>%
                  mutate(Date = as.Date(Date, "%m.%d.%y")) %>%
                  arrange(Date) %>%
                  group_by(Province.State, Country.Region, Lat, Long) %>%
                  mutate(Active = Confirmed - Recovered - Deceased) %>%
                  ungroup()

rm(confirmed_data, confirmed_data_proc, deaths_data, deaths_data_proc, recovered_data, recovered_data_proc)

latest_data <-  evolution_data[which(evolution_data$Date == data_last_update),] %>%
                distinct()

top_5_countries <-  evolution_data %>%
                    filter(Date == data_last_update) %>%
                    group_by(Country.Region) %>%
                    summarise(Active = sum(Active, na.rm = TRUE)) %>%
                    arrange(desc(Active)) %>%
                    top_n(5) %>%
                    select(Country.Region)