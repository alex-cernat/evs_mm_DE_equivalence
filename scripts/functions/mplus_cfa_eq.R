

mplus_cfa_eq <- function(df_use,
                      vars_use,
                      categorical = F,
                      weights = F,
                      group_var = NULL,
                      group_name = NULL,
                      model = c("config", "metric", "scalar")) {


  base_text <- MplusAutomation::prepareMplusData(df_use,
                                                 filename =
                                                   "./mplus/eq/data.dta")

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

  group_level <- table(df_use[[group_var]]) %>% names()

  syn_group <- str_c("\n GROUPING IS ", group_var, " (",
                     str_c(group_level, "=", group_name, collapse = " "),
                     ");\n\n")

  # add optional weights
  syn_weights <- ""
  if (weights != F) {
    syn_weights <- str_c("WEIGHT IS ", weights, "; \n ")
  }

  # add estimation info for categorical
  syn_analysis <- ""
  if (categorical == T) {
  syn_analysis <- "\n Analysis: \n
                ESTIMATOR = WLSMV;\n
                ITERATIONS = 100000;\n
                PARAMETERIZATION = THETA;\n\n"
}

  ### here starting to add equivalence

  nr_vars <- length(vars_use)

  nr_cat <- map(vars_use, function(x) df_use[[x]] %>%
                  na.omit() %>%
                  unique() %>%
                  length()) %>%
    unlist()


# Make model syntax -------------------------------------------------------



  var_syntax <- function(vars_use, nr_cat, grp) {

    syn_loading <- str_c("f1 BY ",
                         str_c(vars_use[1], "@1\n"))

# add different loading if configural or metric
extr_load <- ""
if (model == "config") extr_load <- str_c("_", grp)

    for (i in 2:length(vars_use)) {
      syn_loading <- str_c(syn_loading,
                           vars_use[i], " (L", i,
                           extr_load,
                           ")\n")
    }

    syn_loading <- str_c(syn_loading, ";\n\n")


# Intercepts --------------------------------------------------------------

if (categorical == F) {
  # add different intercepts if configural or metric
  extr_int <- ""
  if (model %in% c("config", "metric")) extr_int <- str_c("_", grp)


  syn_mean <- map_chr(vars_use, function(x) {
    str_c("[", x, "] ",
          "(i", match(x, vars_use),
          extr_int,
          ");\n")
  }) %>%
    reduce(str_c)

  # fix mean to 0 in first group for estimation
  syn_mean <- str_c(syn_mean, "\n [f1@0];")
}



# Thesholds ---------------------------------------------------------------

if (categorical == T) {

    # threshold function
    syn_unique_threshold <- function(var_use, nr_cat, group) {
      out <- ""
      for (i in 1:(as.numeric(nr_cat[1]) - 1)) {

        # make exception for first variable as it is fixed
        if (i == 1) {
          out <- str_c(out,
                       str_c("[", var_use, "$", i, "] (t_", var_use,
                             "_", i,
                             ");\n"))
        } else {
          out <- str_c(out,
                       str_c("[", var_use, "$", i, "] (t_", var_use,
                             "_", i,
                             "_", group,
                             ");\n"))
        }

      }
      out
    }
    # threshold function without group
    syn_unique_threshold_nogroup <- function(var_use, nr_cat) {
      out <- ""
      for (i in 1:(as.numeric(nr_cat[1]) - 1)) {
        out <- str_c(out,
                     str_c("[", var_use, "$", i, "] (t_", var_use,
                           "_", i,
                           ");\n"))
      }
      out
    }




    # make thresholds for all variables within group
    # no group restrictions for the first variable and first thresholds

    # add different loading if configural or metric
    extr_thr <- ""
    if (model %in% c("config", "metric")) extr_thr <- str_c("_", grp)


    syn_mean <- ""

    for (i in seq_along(vars_use)) {
      if (i == 1) {
        syn_mean <- str_c(syn_mean, "\n",
                                syn_unique_threshold_nogroup(vars_use[i],
                                                             nr_cat[i]))
      } else if (model %in% c("config", "metric")) {
        syn_mean <- str_c(syn_mean, "\n",
                                syn_unique_threshold(vars_use[i],
                                                             nr_cat[i],
                                                             grp))
      } else {
        syn_mean <- str_c(syn_mean, "\n",
                                syn_unique_threshold_nogroup(vars_use[i],
                                                     nr_cat[i]))
      }

      # fix mean to 0 in first group for estimation
      syn_mean <- str_c(syn_mean, "\n [f1@0];")
    }

}


# Bring model together ----------------------------------------------------

    str_c(str_c("\nModel ", grp, ":\n\n", collapse = ""),
          syn_loading, syn_mean, collapse = "\n")

}


  syn_model_full <- map(group_name, function(x)
    var_syntax(vars_use, nr_cat, x)) %>%
    unlist() %>% str_c(collapse = "\n")



  # remove first line to have a general model
  syn_model_full <- str_remove(syn_model_full, "Model.+\n")
  syn_model_full <- str_c("Model: \n", syn_model_full)

  syn_save <- str_c("\n\n SAVEDATA: DIFFTEST IS ",
                    vars_use[1], "_", model, ".dat;",
                    collapse = "")


  syn_output <- str_c("\n \n OUTPUT: SAMPSTAT; \n
                                MODINDICES; \n
                                STDYX; \n")

  # bring everything together
  out <- str_c(str_c(base_text, collapse = "\n"),
               syn_use, syn_cat, syn_group,
               syn_weights, syn_analysis, syn_model_full,
               syn_save, syn_output,
               collapse = "\n")

  nm <- deparse(substitute(df_use))

  # write .inp file
  write.table(out,
              str_c("./mplus/eq/", nm, "_",
                    vars_use[1], "_", group_var, "_", model,".inp"),
              quote = F,
              row.names = F,
              col.names = F)

}

