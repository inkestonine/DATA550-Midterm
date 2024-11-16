here::i_am(
  "code/00_render_report.R"
)

config_list <- config::get(config = Sys.getenv("WHICH_CONFIG"))
if (config_list$covid) {
  covid_enabled <- "covid"
} else {
  covid_enabled <- "non-covid"
}
   

rmarkdown::render(
  here::here("code/covid_report.Rmd"),
  output_file = here::here(paste0(
    "output/Analysis Report for ", covid_enabled, ".pdf"
  ))
)