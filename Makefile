# render report
report.html: code/covid_report.Rmd demography_analysis health_outcome association temporal_trend
	Rscript code/00_render_report.R 


# 01 demography analysis
bar_chart_age.png classification_table_immu.png pie_chart_sex.png box_plot_age.png classification_table_pregnancy.png&: \
 code/01_demography.R covid_sub.csv
	Rscript code/01_demography.R

.PHONY: demography_analysis
demography_analysis: bar_chart_age.png classification_table_immu.png \
pie_chart_sex.png box_plot_age.png classification_table_pregnancy.png



# 02 healthy outcome analysis
output/classification_bar_chart.png output/diabetes_severity_scatter_plot.png output/classification_table.csv output/patient_outcomes_table.csv&: \
 code/02_health_outcome.R covid_sub.csv
	Rscript code/02_health_outcome.R

.PHONY: health_outcome
health_outcome: output/classification_bar_chart.png \
 output/diabetes_severity_scatter_plot.png output/classification_table.csv \
 output/patient_outcomes_table.csv


# 03 association analysis
output/severity_results.csv output/severity_odds_ratios.png output/mortality_results.csv output/mortality_odds_ratios.png output/tobacco_obesity_results.csv output/tobacco_obesity_odds_ratios.png output/tobacco_obesity_stacked_bar.png&: \
 code/03_association.R covid_sub.csv
	Rscript code/03_association.R

.PHONY: association
association: output/severity_results.csv output/severity_odds_ratios.png \
 output/mortality_results.csv output/mortality_odds_ratios.png \
 output/tobacco_obesity_results.csv output/tobacco_obesity_odds_ratios.png \
 output/tobacco_obesity_stacked_bar.png


# 04 temporal trend analysis
output/daily_cases.png output/monthly_cases.png output/weekly_cases.png output/death_trends.png output/mortality_hospitalization_rates.png output/icu_intubation_rates.png output/summary_statistics.rds&:\
 code/04_temporal_trend.R covid_sub.csv
	Rscript code/04_temporal_trend.R

.PHONY: temporal_trend
temporal_trend: output/daily_cases.png output/monthly_cases.png \
 output/weekly_cases.png output/death_trends.png \
 output/mortality_hospitalization_rates.png output/icu_intubation_rates.png \
 output/summary_statistics.rds


# update required packages
.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"

# clean	
.PHONY: clean
clean:
	rm -f output/* && touch output/.gitkeep && rm -f *.html