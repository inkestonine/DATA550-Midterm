library(here)
library(ggplot2)
library(dplyr)
library(gt)
library(tibble)
library(tidyr)
library(gridExtra)

# Load data
here::i_am("code/01_demography.R")
data <- read.csv("covid_sub.csv")

########################################################################################
# Pie chart: Displaying the proportion of two genders
sex_counts <- data %>%
  count(SEX) %>%
  mutate(proportion = n / sum(n), 
         label = paste0(SEX, ": ", scales::percent(proportion, accuracy = 0.1)))

pie_chart_sex <- ggplot(sex_counts, aes(x = "", y = proportion, fill = SEX)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  geom_text(aes(label = label), 
            position = position_stack(vjust = 0.5), 
            color = "white", size = 4) + 
  labs(title = "Sex Proportion", x = NULL, y = NULL) +
  scale_fill_manual(values = c("female" = "#FF9999", "male" = "#9999FF")) +
  theme_void()

ggsave(here::here("output/pie_chart_sex.png"), plot = pie_chart_sex, width = 8, height = 6)

########################################################################################
# Bar chart: Displaying the distribution of different ages
bar_chart_age <- ggplot(data, aes(x = AGE)) +
  geom_bar(fill = "#69b3a2", color = "black") +
  labs(title = "Age Distribution", x = "age", y = "count") +
  theme_minimal()

ggsave(here::here("output/bar_chart_age.png"), plot = bar_chart_age, width = 8, height = 6)

########################################################################################
# Box plot: Displaying the distribution of different ages
box_plot_age <- ggplot(data, aes(x = SEX, y = AGE, fill = SEX)) +
  geom_boxplot() +
  labs(title = "Age Distribution by Sex", x = "sex", y = "age") +
  scale_fill_manual(values = c("female" = "#FF9999", "male" = "#9999FF")) +
  theme_minimal()

ggsave(here::here("output/box_plot_age.png"), plot = box_plot_age, width = 8, height = 6)

########################################################################################
# Classification table1: Displaying the proportion of pregnant/non-pregnant in each patient_type
## rename the values to text format
data_rename <- data %>%
  mutate(PREGNANT = case_when(
    PREGNANT == "Yes" ~ "Pregnant",
    PREGNANT == "No" ~ "Non-pregnant",
    PREGNANT == "NA" ~ "NA"
  ))

## create the classification table
classification_table1 <- table(data_rename$PATIENT_TYPE, data_rename$PREGNANT)

## change to format that can be stored as png
classification_df_pregnancy <- as.data.frame.matrix(classification_table1) %>%
  rownames_to_column(var = "Patient Type")

classification_table_pregnancy <- classification_df_pregnancy %>%
  gt() %>%
  tab_header(
    title = "Classification Table by Pregnancy Status"
  ) %>%
  fmt_number(
    columns = everything(), decimals = 0
  )

gtsave(
  classification_table_pregnancy, 
  here::here("output/classification_table_pregnancy.png")
)

########################################################################################
# Classification table2: Displaying the proportion of immunosuppressed/not immunosuppressed in each patient_type
## rename the values to text format
data_rename <- data_rename %>%
  mutate(INMSUPR = case_when(
    INMSUPR == "Yes" ~ "Immunosuppressed",
    INMSUPR == "No" ~ "Non-immunosuppressed",
    INMSUPR == "NA" ~ "NA"
  ))

## create the classification table
classification_table2 <- table(data_rename$PATIENT_TYPE, data_rename$INMSUPR)

## change to format that can be stored as png
classification_df_immu <- as.data.frame.matrix(classification_table2) %>%
  rownames_to_column(var = "Patient Type")

classification_table_immu <- classification_df_immu %>%
  gt() %>%
  tab_header(
    title = "Classification Table by Immunosuppressed Status"
  ) %>%
  fmt_number(
    columns = everything(), decimals = 0
  )

gtsave(
  classification_table_immu, 
  here::here("output/classification_table_immu.png")
)