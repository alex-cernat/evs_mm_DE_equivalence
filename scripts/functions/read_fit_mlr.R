# read fit indices for MLR
read_fit_mlr <- function(model) {

  fit <- model$summaries

  indices <- c("Filename", "Observations",
               "ChiSqM_Value", "ChiSqM_DF", "ChiSqM_PValue",
               "CFI", "RMSEA_Estimate")

  # if ("ChiSqDiffTest_Value" %in% names(fit)) {
  #   indices <- c(indices, "ChiSqDiffTest_Value", "ChiSqDiffTest_DF",
  #                "ChiSqDiffTest_PValue")
  # }


  fit[indices] %>% as_tibble()

}
