# 加载必要的包
library(ggplot2)
library(dplyr)
library(broom)
library(here)
library(RColorBrewer)
library(tidyr)
library(scales) # 用于生成动态颜色
library(config) # 用于动态加载配置

# 设置环境变量（根据需要加载 "healthy" 或 "default" 配置）
#Sys.setenv(WHICH_CONFIG = "default")  # 或者 "healthy"

## set work path
here::i_am("code/03_association.R")

# 读取配置文件
config_list <- config::get(config = Sys.getenv("WHICH_CONFIG"))

# 检查是否启用 COVID 相关分析
covid_enabled <- config_list$covid

# 加载数据文件
data_clean_covid <- read.csv(here::here("covid_sub.csv"))


# 设置全局主题
theme_set(theme_bw(base_size = 15))

# 创建输出目录（如果不存在）
if (!dir.exists(here::here("output"))) {
  dir.create(here::here("output"), recursive = TRUE)
}

# 转换 ICU 和 DATE_DIED 变量
data_clean_covid <- data_clean_covid %>%
  mutate(
    # 将 ICU 编码为 0 和 1
    ICU = ifelse(ICU == "Yes", 1, ifelse(ICU == "No", 0, NA)),
    
    # 将 DATE_DIED 转换为 MORTALITY (0 = 存活, 1 = 死亡)
    MORTALITY = ifelse(is.na(DATE_DIED), 0, 1)
  )

if (covid_enabled) {
  # 分析 COVID 病例（CLASIFICATION_FINAL 1-3）
  temp_data_covid <- data_clean_covid %>%
    filter(CLASIFICATION_FINAL >= 1 & CLASIFICATION_FINAL <= 3)
  
  #### 1. 糖尿病、慢性肾病对 ICU 入住的影响 ####
  severity_model <- glm(ICU ~ DIABETES + RENAL_CHRONIC + SEX + AGE + HIPERTENSION,
                        data = temp_data_covid %>% filter(!is.na(ICU)),
                        family = binomial)
  
  severity_results <- tidy(severity_model, conf.int = TRUE)
  
  # 保存模型结果
  write.csv(severity_results, file = here::here("output/severity_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(severity_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(severity_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for ICU Admission (COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/severity_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  #### 2. 年龄和高血压对死亡率的影响 ####
  mortality_model <- glm(MORTALITY ~ AGE + HIPERTENSION + SEX + DIABETES + COPD + OBESITY,
                         data = temp_data_covid %>% filter(!is.na(MORTALITY)),
                         family = binomial)
  
  mortality_results <- tidy(mortality_model, conf.int = TRUE)
  
  # 保存结果
  write.csv(mortality_results, file = here::here("output/mortality_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(mortality_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(mortality_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for Mortality (COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/mortality_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  #### 3. 吸烟和肥胖对 ICU 入住的影响 ####
  tobacco_obesity_model <- glm(ICU ~ TOBACCO + OBESITY + SEX + AGE,
                               data = temp_data_covid %>% filter(!is.na(ICU), !is.na(TOBACCO), !is.na(OBESITY)),
                               family = binomial)
  
  tobacco_obesity_results <- tidy(tobacco_obesity_model, conf.int = TRUE)
  
  # 保存结果
  write.csv(tobacco_obesity_results, file = here::here("output/tobacco_obesity_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(tobacco_obesity_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(tobacco_obesity_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for ICU Admission (Tobacco and Obesity - COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/tobacco_obesity_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  # 叠加条形图
  temp_bar_data <- temp_data_covid %>%
    filter(!is.na(ICU), !is.na(TOBACCO), !is.na(OBESITY)) %>%
    group_by(ICU, TOBACCO, OBESITY) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(ICU = factor(ICU, levels = c(0, 1), labels = c("No", "Yes")))
  
  ggplot(temp_bar_data, aes(x = TOBACCO, y = count, fill = OBESITY)) +
    geom_bar(stat = "identity", position = "fill") +
    facet_wrap(~ICU) +
    labs(
      title = "Stacked Bar Plot: Tobacco and Obesity vs ICU Admission (COVID Cases)",
      x = "Tobacco Use",
      y = "Proportion",
      fill = "Obesity"
    ) +
    scale_fill_brewer(palette = "Set2") +
    theme_minimal()
  
  # 保存叠加条形图
  ggsave(here::here("output/tobacco_obesity_stacked_bar.png"), width = 10, height = 6, dpi = 300)
  
} else {
  temp_data_non_covid <- data_clean_covid %>%
    filter(CLASIFICATION_FINAL >= 4)
  

  #### 1. 糖尿病、慢性肾病对 ICU 入住的影响 ####
  severity_model <- glm(ICU ~ DIABETES + RENAL_CHRONIC + SEX + AGE + HIPERTENSION,
                        data = temp_data_non_covid %>% filter(!is.na(ICU)),
                        family = binomial)
  
  severity_results <- tidy(severity_model, conf.int = TRUE)
  
  # 保存模型结果
  write.csv(severity_results, file = here::here("output/severity_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(severity_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(severity_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for ICU Admission (Non-COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/severity_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  #### 2. 年龄和高血压对死亡率的影响 ####
  mortality_model <- glm(MORTALITY ~ AGE + HIPERTENSION + SEX + DIABETES + COPD + OBESITY,
                         data = temp_data_non_covid %>% filter(!is.na(MORTALITY)),
                         family = binomial)
  
  mortality_results <- tidy(mortality_model, conf.int = TRUE)
  
  # 保存结果
  write.csv(mortality_results, file = here::here("output/mortality_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(mortality_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(mortality_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for Mortality (Non-COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/mortality_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  #### 3. 吸烟和肥胖对 ICU 入住的影响 ####
  tobacco_obesity_model <- glm(ICU ~ TOBACCO + OBESITY + SEX + AGE,
                               data = temp_data_non_covid %>% filter(!is.na(ICU), !is.na(TOBACCO), !is.na(OBESITY)),
                               family = binomial)
  
  tobacco_obesity_results <- tidy(tobacco_obesity_model, conf.int = TRUE)
  
  # 保存结果
  write.csv(tobacco_obesity_results, file = here::here("output/tobacco_obesity_results.csv"))
  
  # 绘制模型结果
  num_terms <- nrow(tobacco_obesity_results %>% filter(term != "(Intercept)"))
  custom_colors <- hue_pal()(num_terms)
  
  ggplot(tobacco_obesity_results %>% filter(term != "(Intercept)"),
         aes(x = term, y = exp(estimate), ymin = exp(conf.low), ymax = exp(conf.high), color = term)) +
    geom_pointrange() +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(
      title = "Odds Ratios for ICU Admission (Tobacco and Obesity - Non-COVID Cases)",
      x = "Variable",
      y = "Odds Ratio (Exp(Estimate))"
    ) +
    scale_color_manual(values = custom_colors) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  
  # 保存图像
  ggsave(here::here("output/tobacco_obesity_odds_ratios.png"), width = 10, height = 6, dpi = 300)
  
  #### 4. 叠加条形图分析吸烟和肥胖对 ICU 入住的影响 ####
  temp_bar_data <- temp_data_non_covid %>%
    filter(!is.na(ICU), !is.na(TOBACCO), !is.na(OBESITY)) %>%
    group_by(ICU, TOBACCO, OBESITY) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(ICU = factor(ICU, levels = c(0, 1), labels = c("No", "Yes")))
  
  ggplot(temp_bar_data, aes(x = TOBACCO, y = count, fill = OBESITY)) +
    geom_bar(stat = "identity", position = "fill") +
    facet_wrap(~ICU) +
    labs(
      title = "Stacked Bar Plot: Tobacco and Obesity vs ICU Admission (Non-COVID Cases)",
      x = "Tobacco Use",
      y = "Proportion",
      fill = "Obesity"
    ) +
    scale_fill_brewer(palette = "Set2") +
    theme_minimal()
  
  # 保存叠加条形图
  ggsave(here::here("output/tobacco_obesity_stacked_bar.png"), width = 10, height = 6, dpi = 300)
}