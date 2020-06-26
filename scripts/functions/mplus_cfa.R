
mplus_cfa <- function(df_use, vars_use,
                       categorical = F,
                       weights = F) {


  base_text <- MplusAutomation::prepareMplusData(df_use,
                                                 filename = "./mplus/cfa/data.dta")

  base_text <- str_remove_all(base_text, '\\"') %>%
    str_c(collapse = " \n ") %>%
    str_remove_all("./mplus/")

  syn_use1 <- str_c(str_c(vars_use, collapse = " \n "), ";\n ")
  syn_use <- str_c(" \n USEVARIABLES ARE \n ", syn_use1)

  # add categorical option if
  syn_cat <- ""

  if (categorical == T) {
    syn_cat <- str_c(" \n CATEGORICAL ARE \n ", syn_use1)
  }


  # add optional weights
  syn_weights <- ""
  if (weights != F) {
    syn_weights <- str_c("WEIGHT IS ", weights, "; \n ")
  }


  syn_model <- "\n \n Model:\n\n" %>%
    str_c("f by ", syn_use1)


  # add correlated errors for v212
  if ("v212" %in% vars_use) {
    syn_model <- str_c(syn_model, "v212 WITH v213; \n v215 WITH v216;")
  }



  syn_output <- str_c("\n \n OUTPUT: SAMPSTAT; \n
                                MODINDICES; \n
                                STDYX; \n")

  # bring everything together
  out <- str_c(str_c(base_text, collapse = "\n"),
               syn_use, syn_cat,
               syn_weights, syn_model,
               syn_output,
               collapse = "\n")

  nm <- deparse(substitute(df_use))

  # write .inp file
  write.table(out,
              str_c("./mplus/cfa/", nm, "_", vars_use[1], ".inp"),
              quote = F,
              row.names = F,
              col.names = F)

}

