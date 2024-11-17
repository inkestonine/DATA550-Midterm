# Data Source

The dataset was provided by the [Mexican government](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico). This dataset contains an enormous number of anonymized patient-related information including pre-conditions. The raw dataset consists of 21 unique features and 1,048,576 unique patients.

The *covid_sub.csv* contains data from 20% of the population, and we will provide data Covid Data_full.csv for the full population to check the reproducibility of code.


# Project Description

The Covid-19 report has four analysis parts.

- `code/01_demograhy.R` 

- `code/02_health_outcome.R` from [kmg1024](https://github.com/kmg1024/DATA550-Midterm) is Case Severity and Health Outcomes Analysis
  - Distribution of COVID-19 Cases by Classification Levels `output/classification_bar_chart.png`
    - Generates a bar chart showing the number of cases categorized as mild, moderate, and severe.
  - Relationship Between Pre-existing Health Conditions and Case Severity `output/diabetes_severity_scatter_plot.png`
    - Creates a scatter plot illustrating the association between conditions like diabetes and hypertension with the severity of COVID-19 cases.
  - Classification Distribution Table `output/classification_table.csv`
    - Summarizes the number and percentage of cases in each classification level.
  - Patient Type Outcomes Table `output/patient_outcomes_table.csv`
    - Compares mortality rates, ICU admissions, and intubation rates between different patient types (e.g., hospitalized vs. returned home).

- `code/03_association.R`
  - `severity_results.csv`
    - Contains logistic regression results for ICU admission factors (e.g., diabetes, renal chronic disease, hypertension).
  - `severity_odds_ratios.png`
    - Visualizes the odds ratios from the logistic regression analysis of ICU admissions.
  - `mortality_results.csv`
    - Summarizes logistic regression results for mortality factors (e.g., age, hypertension, diabetes, obesity).
  - `mortality_odds_ratios.png`
    - Displays odds ratios for factors influencing mortality.
  - `tobacco_obesity_results.csv`
    - Contains logistic regression results for the impact of tobacco use and obesity on ICU admissions.
  - `tobacco_obesity_odds_ratios.png`
    - Visualizes odds ratios for tobacco use and obesity in predicting ICU admissions.
  - `tobacco_obesity_stacked_bar.png`
    - Shows a stacked bar chart of ICU admissions categorized by tobacco use and obesity status.


- `code/04_temporal_trend.R`

The analysis parts are combined in `covid_report.Rmd`.

`code/00_render_report.R` is used for rendering the combined report from the command line