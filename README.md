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

- `code/03_association.R` from [zye229zye](https://github.com/zye229zye/DATA550-Midterm) is
  - 
  - 

- `code/04_temporal_trend.R` from [Shicy621](https://github.com/Shicy621/DATA550-Midterm) is Temporal Trends and Outcome Analysis
  - Case Trends Over Time `daily_cases.png` `weekly_cases.png` `monthly_cases.png`
    - Visuals and summary statistics showing case counts across intervals (daily, weekly, monthly), with insights on significant fluctuations during key periods.
  - Mortality and Hospitalization Trends `mortality_hospitalization_rates.png`
    - Charts showing mortality and hospitalization rate changes over time, highlighting any significant increases or decreases across different periods.
  - ICU Admission and Intubation Rates `icu_intubation_rates.png`
    - Analysis of ICU and intubation rates during seasonal and pandemic peaks, with comparisons to low-demand periods to assess resource strain.
  - Date-of-Death and Severe Case Prediction `death_trends.png`
    - Death trends over time, with potential predictive insights for severe cases, aimed at aiding resource planning for peak periods.
  - Summary `summary_statistics.rds`
    - Key findings and recommendations on managing resources effectively during high-demand intervals.

The analysis parts are combined in `covid_report.Rmd`.

`code/00_render_report.R` is used for rendering the combined report from the command line