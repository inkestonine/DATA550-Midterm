# Data Source

The dataset was provided by the [Mexican government](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico). This dataset contains an enormous number of anonymized patient-related information including pre-conditions. The raw dataset consists of 21 unique features and 1,048,576 unique patients.

The *covid_sub.csv* contains data from 20% of the population, and we will provide data Covid Data_full.csv for the full population to check the reproducibility of code.


# Project Description

The Covid-19 report has four analysis parts.


## 1. `code/01_demography.R` from [L9otus](https://github.com/L9otus/DATA550-Midterm) is Demographic Analysis
- Analyze the distribution of different demographic characteristics, such as age and gender.
  - Pie chart `output/pie_chart_sex.png` : Displaying the proportion of two genders.
  - Bar chart `output/bar_chart_age.png` and box plot `output/box_plot_age.png` : Displaying the distribution of different ages.
- Examine the distribution of pregnant and immunosuppressed patients, focusing on their proportions among hospitalized or not.
  - Classification table `output/classification_table_immu.png` : Displaying the proportion of immunosuppressed/non-immunosuppressed patients in each patient_type.
  - Classification table `output/classification_table_pregnancy.png`: Displaying the proportion of pregnant/non-pregnant in each patient_type.


## 2. `code/02_health_outcome.R` from [kmg1024](https://github.com/kmg1024/DATA550-Midterm) is Case Severity and Health Outcomes Analysis
- Distribution of COVID-19 Cases by Classification Levels `output/classification_bar_chart.png`
  - Generates a bar chart showing the number of cases categorized as mild, moderate, and severe.
- Relationship Between Pre-existing Health Conditions and Case Severity `output/diabetes_severity_scatter_plot.png`
  - Creates a scatter plot illustrating the association between conditions like diabetes and hypertension with the severity of COVID-19 cases.
- Classification Distribution Table `output/classification_table.csv`
  - Summarizes the number and percentage of cases in each classification level.
- Patient Type Outcomes Table `output/patient_outcomes_table.csv`
  - Compares mortality rates, ICU admissions, and intubation rates between different patient types (e.g., hospitalized vs. returned home).


## 3. `code/03_association.R` from [zye229zye](https://github.com/zye229zye/DATA550-Midterm) is Association Analysis
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


## 4. `code/04_temporal_trend.R` from [Shicy621](https://github.com/Shicy621/DATA550-Midterm) is Temporal Trends and Outcome Analysis
- Case Trends Over Time `output/daily_cases.png` `output/weekly_cases.png` `output/monthly_cases.png`
  - Visuals and summary statistics showing case counts across intervals (daily, weekly, monthly), with insights on significant fluctuations during key periods.
- Mortality and Hospitalization Trends `output/mortality_hospitalization_rates.png`
  - Charts showing mortality and hospitalization rate changes over time, highlighting any significant increases or decreases across different periods.
- ICU Admission and Intubation Rates `output/icu_intubation_rates.png`
  - Analysis of ICU and intubation rates during seasonal and pandemic peaks, with comparisons to low-demand periods to assess resource strain.
- Date-of-Death and Severe Case Prediction `output/death_trends.png`
  - Death trends over time, with potential predictive insights for severe cases, aimed at aiding resource planning for peak periods.
- Summary `output/summary_statistics.rds`
  - Key findings and recommendations on managing resources effectively during high-demand intervals.


The analysis parts are combined in `covid_report.Rmd`.

`code/00_render_report.R` is used for rendering the combined report in the `output/` directory from the command line.


# Report Building Instruction

To compile the report using `make`, follow these steps:

### 1. To generate the default report (COVID-19 cases):

Run the following command:

```{bash}
make
```

This will automatically analyze COVID-19 cases, as `WHICH_CONFIG=default` is the default setting.

### 2. To generate the non-COVID-19 cases report:

Set the `WHICH_CONFIG` parameter to `healthy` and run:

```{bash}
WHICH_CONFIG=healthy make
```

If you do not set the `WHICH_CONFIG` parameter, it will default to analyzing COVID-19 cases.

### 3. To clean the output files in the output/ directory and other unnecessary by-products, run:

```{bash}
make clean
```

# Synchronize Package Repository

When you clone this repository for the first time, use the following command to restore the required packages:

```{bash}
make install
```

If you add, remove, or update any packages during development, use the following command to update the project library and synchronize the renv.lock file:

```{r}
renv::snapshot()
```

