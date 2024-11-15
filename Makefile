
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