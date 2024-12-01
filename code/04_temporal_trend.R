# Load necessary libraries
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(here)
library(config)

# Load the configuration file based on the WHICH_CONFIG environment variable
config_list <- config::get(config = Sys.getenv("WHICH_CONFIG"))
covid_enabled <- config_list$covid

# Load data
here::i_am("code/04_temporal_trend.R")
data <- read_csv("covid_sub.csv")

# Ensure the 'output' directory inside 'DATA550-Midterm' exists
output_dir <- here::here("output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

if (covid_enabled) {
  # Convert 'DATE_DIED' to Date format and handle missing values
  covid_sub <- data %>%
    mutate(
      DATE_DIED = ifelse(DATE_DIED == "9999-99-99" | DATE_DIED == "NA", NA, DATE_DIED),
      DATE_DIED = as.Date(DATE_DIED, format = "%d/%m/%Y")
    )
  
  # Create a 'deaths' column (1 if patient died, 0 otherwise)
  covid_sub <- covid_sub %>%
    mutate(deaths = ifelse(!is.na(DATE_DIED), 1, 0))
  
  # Create a 'hospitalizations' column based on 'PATIENT_TYPE' text values
  covid_sub <- covid_sub %>%
    mutate(hospitalizations = ifelse(PATIENT_TYPE == "hospitalization", 1, 0))
  
  # Create 'cases' column (assuming 'CLASIFICATION_FINAL' values 1-3 indicate diagnosed cases)
  covid_sub <- covid_sub %>%
    mutate(cases = ifelse(CLASIFICATION_FINAL >= 1 & CLASIFICATION_FINAL <= 3, 1, 0))
  
  # 1. Case Trends Over Time
  # Aggregating daily, weekly, and monthly case trends using 'DATE_DIED' as proxy
  daily_cases <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    group_by(day = DATE_DIED) %>%
    summarise(daily_cases = sum(cases, na.rm = TRUE))
  
  weekly_cases <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    group_by(week = floor_date(DATE_DIED, unit = "week")) %>%
    summarise(weekly_cases = sum(cases, na.rm = TRUE))
  
  monthly_cases <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    group_by(month = floor_date(DATE_DIED, unit = "month")) %>%
    summarise(monthly_cases = sum(cases, na.rm = TRUE))
  
  # Plotting and saving Case Trends
  # Daily cases plot
  daily_plot <- ggplot(daily_cases, aes(x = day, y = daily_cases)) +
    geom_line(color = "blue") +
    labs(title = "Daily Case Trends", x = "Date", y = "Number of Cases") +
    theme_minimal()
  ggsave(filename = here::here("output", "daily_cases.png"), plot = daily_plot, width = 8, height = 6)
  
  # Weekly cases plot
  weekly_plot <- ggplot(weekly_cases, aes(x = week, y = weekly_cases)) +
    geom_line(color = "green") +
    labs(title = "Weekly Case Trends", x = "Week", y = "Number of Cases") +
    theme_minimal()
  ggsave(filename = here::here("output", "weekly_cases.png"), plot = weekly_plot, width = 8, height = 6)
  
  # Monthly cases plot
  monthly_plot <- ggplot(monthly_cases, aes(x = month, y = monthly_cases)) +
    geom_line(color = "purple") +
    labs(title = "Monthly Case Trends", x = "Month", y = "Number of Cases") +
    theme_minimal()
  ggsave(filename = here::here("output", "monthly_cases.png"), plot = monthly_plot, width = 8, height = 6)
  
  # 2. Mortality and Hospitalization Trends
  mortality_hospitalization_trends <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    group_by(week = floor_date(DATE_DIED, unit = "week")) %>%
    summarise(
      total_cases = sum(cases, na.rm = TRUE),
      mortality_rate = ifelse(total_cases > 0, sum(deaths, na.rm = TRUE) / total_cases * 100, NA),
      hospitalization_rate = ifelse(total_cases > 0, sum(hospitalizations, na.rm = TRUE) / total_cases * 100, NA)
    ) %>%
    filter(!is.na(mortality_rate) & !is.na(hospitalization_rate))
  
  mortality_hosp_plot <- ggplot(mortality_hospitalization_trends, aes(x = week)) +
    geom_line(aes(y = mortality_rate, color = "Mortality Rate")) +
    geom_line(aes(y = hospitalization_rate, color = "Hospitalization Rate")) +
    labs(title = "Mortality and Hospitalization Rates", x = "Week", y = "Rate (%)") +
    scale_color_manual(values = c("Mortality Rate" = "red", "Hospitalization Rate" = "orange")) +
    theme_minimal()
  ggsave(filename = here::here("output", "mortality_hospitalization_rates.png"), plot = mortality_hosp_plot, width = 8, height = 6)
  
  # 3. ICU Admission and Intubation Rates (assuming 'ICU' and 'INTUBED' are available)
  icu_trends <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    mutate(
      icu_admission = ifelse(ICU == "Yes", 1, 0),
      intubation = ifelse(INTUBED == "Yes", 1, 0)
    ) %>%
    group_by(week = floor_date(DATE_DIED, unit = "week")) %>%
    summarise(
      icu_admissions = sum(icu_admission, na.rm = TRUE),
      intubations = sum(intubation, na.rm = TRUE)
    )
  
  icu_plot <- ggplot(icu_trends, aes(x = week)) +
    geom_line(aes(y = icu_admissions, color = "ICU Admissions")) +
    geom_line(aes(y = intubations, color = "Intubations")) +
    labs(title = "ICU Admissions and Intubation Rates", x = "Week", y = "Count") +
    scale_color_manual(values = c("ICU Admissions" = "blue", "Intubations" = "green")) +
    theme_minimal()
  ggsave(filename = here::here("output", "icu_intubation_rates.png"), plot = icu_plot, width = 8, height = 6)
  
  # 4. Date-of-Death Trends
  death_trends <- covid_sub %>%
    filter(!is.na(DATE_DIED)) %>%
    group_by(week = floor_date(DATE_DIED, unit = "week")) %>%
    summarise(total_deaths = n())
  
  death_trend_plot <- ggplot(death_trends, aes(x = week, y = total_deaths)) +
    geom_line(color = "red") +
    labs(title = "Death Trends", x = "Week", y = "Total Deaths") +
    theme_minimal()
  ggsave(filename = here::here("output", "death_trends.png"), plot = death_trend_plot, width = 8, height = 6)
  
  # 5. Summary of Findings
  summary_statistics <- covid_sub %>%
    summarise(
      total_cases = sum(cases, na.rm = TRUE),
      total_deaths = sum(deaths, na.rm = TRUE),
      earliest_death = min(DATE_DIED, na.rm = TRUE),
      latest_death = max(DATE_DIED, na.rm = TRUE)
    )
  
  # Save summary table to an RDS file
  saveRDS(summary_statistics, file = here::here("output", "summary_statistics.rds"))
  
  print(summary_statistics)
}
