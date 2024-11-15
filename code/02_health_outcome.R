library(tidyverse)
library(ggplot2)
library(dplyr)
library(readr)
library(knitr)
library(kableExtra)
library(here)

# setwd("D:/RToolkit/DATA550-Midterm")
here::i_am("code/02_health_outcome.R")
data <- read_csv("covid_sub.csv")

#covid_enabled <- TRUE
# Load the configuration file based on the WHICH_CONFIG environment variable 
config_list <- config::get( config = Sys.getenv("WHICH_CONFIG") ) 
covid_enabled <- config_list$covid

if(!dir.exists(here("output"))) {
  dir.create(here("output"))
}

head(data)
str(data)
summary(data)

data_clean <- data %>%
  select(-`...1`) %>%  
  rename(
    classification = CLASIFFICATION_FINAL  
  ) %>%
  mutate(
    classification = as.factor(classification),
    patient_type = as.factor(PATIENT_TYPE),
    sex = factor(SEX, levels = c("female", "male"), labels = c("Female", "Male")),
    DATE_DIED = ifelse(DATE_DIED == "NA" | is.na(DATE_DIED), NA, DATE_DIED),
    date_died = as.Date(DATE_DIED, format = "%d/%m/%Y"),
    intubed = factor(INTUBED, levels = c("Yes", "No"), labels = c("Yes", "No")),
    pneumonia = factor(PNEUMONIA, levels = c("Yes", "No"), labels = c("Yes", "No")),
    pregnancy = factor(PREGNANT, levels = c("Yes", "No"), labels = c("Pregnant", "Non-Pregnant")),
    diabetes = factor(DIABETES, levels = c("Yes", "No"), labels = c("Yes", "No")),
    copd = factor(COPD, levels = c("Yes", "No"), labels = c("Yes", "No")),
    asthma = factor(ASTHMA, levels = c("Yes", "No"), labels = c("Yes", "No")),
    inmsupr = factor(INMSUPR, levels = c("Yes", "No"), labels = c("Yes", "No")),
    hypertension = factor(HIPERTENSION, levels = c("Yes", "No"), labels = c("Yes", "No")),
    other_disease = factor(OTHER_DISEASE, levels = c("Yes", "No"), labels = c("Yes", "No")),
    cardiovascular = factor(CARDIOVASCULAR, levels = c("Yes", "No"), labels = c("Yes", "No")),
    obesity = factor(OBESITY, levels = c("Yes", "No"), labels = c("Yes", "No")),
    renal_chronic = factor(RENAL_CHRONIC, levels = c("Yes", "No"), labels = c("Yes", "No")),
    tobacco = factor(TOBACCO, levels = c("Yes", "No"), labels = c("Yes", "No")),
    icu = factor(ICU, levels = c("Yes", "No"), labels = c("Yes", "No")),
    severity = case_when(
      classification == 1 ~ "Mild",
      classification == 2 ~ "Moderate",
      classification == 3 ~ "Severe",
      TRUE ~ NA_character_
    ),
    severity = factor(severity, levels = c("Mild", "Moderate", "Severe"))
  ) %>%
  filter(classification %in% c(1, 2, 3))

if (covid_enabled) {
  classification_plot <- ggplot(data_clean, aes(x = classification)) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  labs(title = "COVID-19 Cases by Classification Level",
       x = "Classification Level",
       y = "Number of Cases")
  
print(classification_plot)
ggsave(here("output/classification_bar_chart.png"), plot = classification_plot, width = 8, height = 6)

diabetes_severity_plot <- ggplot(data_clean, aes(x = diabetes, y = severity)) +
  geom_jitter(alpha = 0.5, width = 0.2, height = 0.2, color = "darkred") +
  theme_minimal() +
  labs(title = "Relationship Between Diabetes and Case Severity",
       x = "Diabetes Status",
       y = "Case Severity")

print(diabetes_severity_plot)
ggsave(here("output/diabetes_severity_scatter_plot.png"), plot = diabetes_severity_plot, width = 8, height = 6)

classification_table <- data_clean %>%
  group_by(classification) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = round((Count / sum(Count)) * 100, 2))

print(classification_table)
write_csv(classification_table, here("output/classification_table.csv"))

patient_outcomes <- data_clean %>%
  group_by(patient_type) %>%
  summarise(
    Mortality_Rate = mean(!is.na(date_died)) * 100,
    ICU_Admission_Rate = mean(icu == "Yes", na.rm = TRUE) * 100,
    Intubation_Rate = mean(intubed == "Yes", na.rm = TRUE) * 100
  )


print(patient_outcomes)
write_csv(patient_outcomes, here("output/patient_outcomes_table.csv"))
}