# Data Source

The dataset was provided by the [Mexican government](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico). This dataset contains an enormous number of anonymized patient-related information including pre-conditions. The raw dataset consists of 21 unique features and 1,048,576 unique patients.

The *covid_sub.csv* contains data from 20% of the population, and we will provide data Covid Data_full.csv for the full population to check the reproducibility of code.


# Project Description

The Covid-19 report has four analysis parts.

- `code/01_demograhy.R` 
- `code/02_health_outcome.R`
- `code/03_association.R`
- `code/04_temporal_trend.R`

The analysis parts are combined in `covid_report.Rmd`.

`code/00_render_report.R` is used for rendering the combined report from the command line