# Load 
library(ggplot2)
library(dplyr)
library(broom)
library(here)
library(RColorBrewer)

here::i_am("code/03_association.R")

data <- read.csv(here::here("covid_sub.csv"))

data_clean <- data %>%
  mutate(
    DIABETES = factor(DIABETES, levels = c("No", "Yes")),
    TOBACCO = factor(TOBACCO, levels = c("No", "Yes")),
    OBESITY = factor(OBESITY, levels = c("No", "Yes")),
    SEX = factor(SEX, levels = c("male", "female")),
    MORTALITY = ifelse(is.na(DATE_DIED), 0, 1),  # 0 = Survived, 1 = Deceased (based on presence of DATE_DIED)
    ICU = factor(ICU, levels = c("No", "Yes")),
    CLASIFFICATION_FINAL = as.numeric(CLASIFFICATION_FINAL)  
  ) %>%
  filter(
    !is.na(DIABETES),
    !is.na(TOBACCO),
    !is.na(OBESITY),
    !is.na(MORTALITY),
    !is.na(ICU),
    !is.na(CLASIFFICATION_FINAL)
  )

theme_set(theme_bw(base_size = 15))

# 1. Multiple Regression Analysis: Diabetes, Smoking, Obesity vs Mortality (MORTALITY)
mortality_model <- glm(MORTALITY ~ DIABETES + TOBACCO + OBESITY + SEX, data = data_clean, family = binomial)

mortality_results <- tidy(mortality_model, conf.int = TRUE)

# Save the regression coefficients and confidence intervals
write.csv(mortality_results, file = here::here("output/logit_mortality_results.csv"))

# Plot the Odds Ratios for mortality with white background and black axis lines
ggplot(mortality_results, aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  labs(
    title = "Odds Ratios for Factors Associated with Mortality",
    x = "Variable",
    y = "Odds Ratio (Exp(Estimate))"
  ) +
  scale_color_brewer(palette = "Set2") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for better readability
        legend.position = "none",  # Remove the legend as it is not needed
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        axis.line = element_line(color = "black", size = 0.5))  # Black axis lines


ggsave(here::here("output/mortality_logit_results.png"), width = 10, height = 6, dpi = 300)

# 2. Diabetes and ICU Relation Analysis: Chi-Square Test
chi_test <- chisq.test(table(data_clean$DIABETES, data_clean$ICU))

# Save Chi-Square test results
chi_results <- data.frame(
  Chi_Square = chi_test$statistic,
  Degrees_of_Freedom = chi_test$parameter,
  p_value = chi_test$p.value
)

write.csv(chi_results, file = here::here("output/diabetes_icu_results.csv"))

# 3. Smoking, Obesity, and CLASIFFICATION_FINAL Relationship: Linear Regression
severity_model <- lm(CLASIFFICATION_FINAL ~ TOBACCO + OBESITY + SEX, data = data_clean)

# Extract regression coefficients for severity model
severity_results <- tidy(severity_model)

write.csv(severity_results, file = here::here("output/lm_severity_results.csv"))

# Plot the regression coefficients for severity with white background and black axis lines
ggplot(severity_results, aes(x = term, y = estimate, fill = term)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(
    title = "Regression Coefficients for Factors Associated with Severity (CLASIFFICATION_FINAL)",
    x = "Variable",
    y = "Estimate"
  ) +
  scale_fill_brewer(palette = "Set1") +  # Use a color palette from RColorBrewer for better fill colors
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for better readability
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        axis.line = element_line(color = "black", size = 0.5))  # Black axis lines

ggsave(here::here("output/severity_lm_results.png"), width = 10, height = 6, dpi = 300)

# Diabetes vs Classification Final
ggplot(data_clean, aes(x = DIABETES, fill = as.factor(CLASIFFICATION_FINAL))) +
  geom_bar(position = "fill") +
  labs(
    title = "Stacked Bar Plot: Diabetes vs Classification Final",
    x = "Diabetes Status",
    y = "Proportion",
    fill = "Classification Final"
  ) +
  theme_minimal(base_size = 14) -> diabetes_classification_plot  # Save the plot object

# Save the plot as PNG
ggsave(here::here("output/diabetes_classification_stack_bar_plot.png"), 
       plot = diabetes_classification_plot, 
       width = 8, height = 6, dpi = 300)
