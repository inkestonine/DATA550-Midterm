
# 03 association analysis
output/severity_results.csv output/severity_odds_ratios.png output/mortality_results.csv output/mortality_odds_ratios.png output/tobacco_obesity_results.csv output/tobacco_obesity_odds_ratios.png output/tobacco_obesity_stacked_bar.png&: \
 code/03_association.R covid_sub.csv
	Rscript code/03_association.R

.PHONY: association
association: output/severity_results.csv output/severity_odds_ratios.png \
 output/mortality_results.csv output/mortality_odds_ratios.png \
 output/tobacco_obesity_results.csv output/tobacco_obesity_odds_ratios.png \
 output/tobacco_obesity_stacked_bar.png


# 02 healthy outcome analysis
output/classification_bar_chart.png output/diabetes_severity_scatter_plot.png \
output/classification_table.csv output/patient_outcomes_table.csv: \
code/02_health_outcome.R covid_sub.csv
	Rscript code/02_health_outcome.R

.PHONY: health_outcome
health_outcome: output/classification_bar_chart.png \
output/diabetes_severity_scatter_plot.png \
output/classification_table.csv output/patient_outcomes_table.csv


	
.PHONY: clean
clean:
	rm -f output/* && rm -f *.html && rm -f *.pdf