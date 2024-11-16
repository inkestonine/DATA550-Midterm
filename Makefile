report.html: code/covid_report.Rmd 
	Rscript code/00_render_report.R

# 02 healthy outcome analysis
output/classification_bar_chart.png output/diabetes_severity_scatter_plot.png \
output/classification_table.csv output/patient_outcomes_table.csv: \
code/02_health_outcome.R covid_sub.csv
	Rscript code/02_health_outcome.R

.PHONY: health_outcome
health_outcome: output/classification_bar_chart.png \
output/diabetes_severity_scatter_plot.png \
output/classification_table.csv output/patient_outcomes_table.csv


# 04 temporal trend analysis
output/daily_cases.png output/monthly_cases.png output/weekly_cases.png \
 output/death_trends.png output/mortality_hospitalization_rates.png \
 output/icu_intubation_rates.png output/summary_statistics.rds&: \
 code/04_temporal_trend.R covid_sub.csv
	Rscript code/04_temporal_trend.R

.PHONY: temporal_trend
temporal_trend: output/daily_cases.png output/monthly_cases.png output/weekly_cases.png \
 output/death_trends.png output/mortality_hospitalization_rates.png \
 output/icu_intubation_rates.png output/summary_statistics.rds

	
.PHONY: clean
clean:
	rm -f output/* && rm -f *.html && rm -f *.pdf