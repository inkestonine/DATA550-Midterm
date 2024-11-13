# Load necessary libraries
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

# Load data
covid_sub <- read_csv("DATA550-Midterm/covid_sub.csv")

# Convert 'DATE_DIED' to Date format and handle missing values
covid_sub <- covid_sub %>%
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

# Create 'cases' column (assuming 'CLASIFFICATION_FINAL' values 1-3 indicate diagnosed cases)
covid_sub <- covid_sub %>%
  mutate(cases = ifelse(CLASIFFICATION_FINAL >= 1 & CLASIFFICATION_FINAL <= 3, 1, 0))

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

# Plotting Case Trends
# Daily
ggplot(daily_cases, aes(x = day, y = daily_cases)) +
  geom_line(color = "blue") +
  labs(title = "Daily Case Trends",
       x = "Date",
       y = "Number of Cases") +
  theme_minimal()

# Weekly
ggplot(weekly_cases, aes(x = week, y = weekly_cases)) +
  geom_line(color = "green") +
  labs(title = "Weekly Case Trends",
       x = "Week",
       y = "Number of Cases") +
  theme_minimal()

# Monthly
ggplot(monthly_cases, aes(x = month, y = monthly_cases)) +
  geom_line(color = "purple") +
  labs(title = "Monthly Case Trends",
       x = "Month",
       y = "Number of Cases") +
  theme_minimal()

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

# Plotting Mortality and Hospitalization Trends
ggplot(mortality_hospitalization_trends, aes(x = week)) +
  geom_line(aes(y = mortality_rate, color = "Mortality Rate")) +
  geom_line(aes(y = hospitalization_rate, color = "Hospitalization Rate")) +
  labs(title = "Mortality and Hospitalization Rates Over Time",
       x = "Week",
       y = "Rate (%)") +
  scale_color_manual(values = c("Mortality Rate" = "red", "Hospitalization Rate" = "orange")) +
  theme_minimal()

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

ggplot(icu_trends, aes(x = week)) +
  geom_line(aes(y = icu_admissions, color = "ICU Admissions")) +
  geom_line(aes(y = intubations, color = "Intubations")) +
  labs(title = "ICU Admissions and Intubation Rates Over Time",
       x = "Week",
       y = "Count") +
  scale_color_manual(values = c("ICU Admissions" = "blue", "Intubations" = "green")) +
  theme_minimal()

# 4. Date-of-Death Trends
death_trends <- covid_sub %>%
  filter(!is.na(DATE_DIED)) %>%
  group_by(week = floor_date(DATE_DIED, unit = "week")) %>%
  summarise(total_deaths = n())

ggplot(death_trends, aes(x = week, y = total_deaths)) +
  geom_line(color = "red") +
  labs(title = "Death Trends Over Time",
       x = "Week",
       y = "Total Deaths") +
  theme_minimal()

# 5. Summary of Findings
summary_statistics <- covid_sub %>%
  summarise(
    total_cases = sum(cases, na.rm = TRUE),
    total_deaths = sum(deaths, na.rm = TRUE),
    earliest_death = min(DATE_DIED, na.rm = TRUE),
    latest_death = max(DATE_DIED, na.rm = TRUE)
  )

print(summary_statistics)
