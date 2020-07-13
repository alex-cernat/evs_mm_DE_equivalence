

# Set-up  -----------------------------------------------------------------

# clean memory
rm(list = ls())

# use local packages on work machine
if (Sys.getenv("USERNAME") == "msassac6") {.libPaths(c(
  paste0(
    "C:/Users/",
    Sys.getenv("USERNAME"),
    "/Dropbox (The University of Manchester)/R/package"
  ),
  .libPaths()[-1]
))}



pkg <- c("tidyverse", "haven", "MplusAutomation")

#install.packages(pkg)
sapply(pkg, library , character.only = T)

# load local functions
map(list.files("./scripts/functions/", full.names = T),
    source) %>% suppressMessages()




# Creat folder structure --------------------------------------------------




## run just once
# dir.create("./data")
# dir.create("./data/raw")
# dir.create("./data/clean")
# dir.create("./output")
# dir.create("./output/fig")
# dir.create("./output/tab")
# dir.create("./documentation")
# dir.create("./paper")
# dir.create("./scripts")


# unzip data
# unzip("./data/raw/ZA7500_v3-0-0.dta.zip",
#       exdir = "./data/raw")
# unzip("./data/raw/ZA7502_v1-0-0.dta.zip",
#       exdir = "./data/raw")


# read data ---------------------------------------------------------------


meta_data <- readxl::read_xlsx(
  "./data/clean/EVS_Data_Quality_Overview_v2.xlsx")

za7500 <- read_dta("./data/raw/ZA7500_v3-0-0.dta")
za7502 <- read_dta("./data/raw/ZA7502_v1-0-0.dta")
evs_clean <- read_dta("./data/clean/ger_evs_data.dta")

# kick out people with that break off (5320 cases)
evs <- evs_clean %>%
  filter(break_off == 0)

# get the scales we want
vars_scales <- filter(meta_data, `Measurement Invariance` == "1") %>%
  select(variables, Topic, scale) %>%
  na.omit()

# get other vars of interest
vars_int <- c("weight", "mode", "wei_mms", "wei_mmf")

# make group variables
# comp_mode -> 0 = single mode and 1 = mixed mode full length
# com_len -> 0 = full length and 1 = short
evs <- evs %>%
  mutate(comp_mode = case_when(mode == 1 ~ 0,
                               mm_matrix_group == 7 ~ 1),
         comp_len = case_when(mm_matrix_group == 7 ~ 0,
                              mm_matrix_group > 7 ~ 1))

# code 6 as missing for CAPI
evs <- evs %>%
  mutate_at(vars(vars_scales$variables[vars_scales$Topic == "childhood"]),
            ~ifelse(. == 6, NA, .))


# get other vars of interest
vars_int <- c("weight", "comp_mode", "comp_len",
              "mode", "mm_matrix_group", "wei_mmf")

# make smaller data only with variables we want to look at
inv_data <- select(evs, id_cocas, vars_int, vars_scales$variables)

# code all missings
inv_data2 <- inv_data %>%
  mutate_all(~ ifelse(. < 0, NA, .))

# take attributes from old data
for (i in 1:ncol(inv_data)) {
  attributes(inv_data2[[i]]) <- attributes(inv_data[[i]])
}

# look at data
scales <- unique(vars_scales$Topic[!is.na(vars_scales$Topic)])

# function to do fast desccriptives by scale
scale_explore <- function(scale) {
  vars_explore <- vars_scales$variables[vars_scales$Topic == scale]
  vars_explore <- vars_explore[!is.na(vars_explore)]

  map(vars_explore, function(x) desc_tab(inv_data2[[x]]))
}

map(scales, scale_explore)

# run base CFA models -----------------------------------------------------

# make data numeric for export
inv_data3 <- mutate_all(inv_data2, ~as.numeric(.))

make_cfa <- function(scale) {
  vars_explore <- vars_scales$variables[vars_scales$Topic %in% scale]
  cat <- vars_scales$scale[vars_scales$variables == vars_explore[1]] %>%
    as.numeric() < 5
  mplus_cfa(inv_data3, vars_explore, categorical = cat, weights = weight)
}

# make models
map(scales, make_cfa)


# changes to original models ----------------------------------------------

# from importance we excluded: v1, v5, v6 due to the low correlaiton with the
# rest of the variables

# based on the fit redo the norms scale in 2:
#   f1 by v149 v150 v152 v159 v162;
#   f2 by v151 v153 v154 v155 v156 v157 v158 v160 v161;
# exclude !v163 ;

# split democracy in two groups:
# f1 by v133 v135 v136 v138 v141;
# f2 by v134 v137 v139 v140;

# exclude v168 due to low correlaiton with rest of models

# from parents remove v270 and v274 (slightly different topic and worse fit)
# add v212 WITH v213; and v215 WITH v216;
# exclude v219 low loading, probably cpature issues around migration
# exclude 190 due to low loadings

# religion was excluded because it had estmation issues

# run models --------------------------------------------------------------


# run models
MplusAutomation::runModels("./mplus/cfa/", showOutput = T, local_tmpdir = T)

# read models
cfa_models <- MplusAutomation::readModels(
  list.files("./mplus/cfa/", pattern = "out", full.names = T)
)


# Import ------------------------------------------------------------------


# import fit
fit_cfa <- map_df(cfa_models, read_fit_mlr)

# put scale name
fit_cfa <- fit_cfa %>%
  mutate(name = str_remove_all(Filename, "inv_data3_|\\.out"))

fit_cfa <- fit_cfa %>%
  left_join(vars_scales, by = c("name" = "variables")) %>%
  select(Topic, everything(), -Filename, -name) %>%
  rename_all(~ str_remove_all(., "M_|Value|_Estimate"))


View(fit_cfa)

# save fit

write_csv(fit_cfa, "./data/clean/cfa_fit.csv")


# make codebook

labs <- evs_clean[, -c(1,2)] %>%
  map(function(x) attributes(x)$label)

labs <- map(labs, function(x) ifelse(is.null(x), "NA", x))

codebook <- tibble(Code = names(labs),
       Label = unlist(labs)) %>%
  right_join(vars_scales, by = c("Code" = "variables"))

# save codebook
write_csv(codebook, "./data/clean/scales_codebook.csv")




# Equivalence testing -----------------------------------------------------

vars_use_list <- list(NULL)
for (i in unique(vars_scales$Topic)) {
  vars_use_list[[i]] <- vars_scales$variables[vars_scales$Topic == i]
}

vars_use_list <- vars_use_list[-1]

cat_vector <- vars_scales %>%
  mutate(scale = as.numeric(scale),
         cat = ifelse(scale < 5, T, F)) %>%
  group_by(Topic) %>%
  filter(row_number() == 1) %>%
    .[["cat"]]

vars_arg <- tibble(vars_use = vars_use_list, topic = names(vars_use_list),
                   categorical = cat_vector)

groups <- tibble(group_var = c("comp_mode", "comp_len"),
                 group_name = list(c("sm", "mm"), c("full", "short")))

args <- expand_grid(vars_arg, groups) %>%
  expand_grid(model = c("config", "metric", "scalar")) %>%
  select(-topic)

pmap(args, mplus_cfa_eq, df_use = inv_data3, weights = "weight")


# mplus_cfa_eq(df_use = inv_data3, categorical = T, vars_use = vars_use_list[[1]],
#              weights = "weight", group_var = "comp_mode",
#              group_name = c("sm", "mm"), model = "config")


# Import ------------------------------------------------------------------


# read models
eq_models <- MplusAutomation::readModels(
  list.files("./mplus/eq/", pattern = "out", full.names = T)
)


# set V82 with no weights due to convergence issues


# import fit

fit_eq <- map_df(eq_models, read_fit_mlr)

# put scale name
fit_eq <- fit_eq %>%
  mutate(name = str_remove_all(Filename, "inv_data3_|\\.out|comp_"))

fit_eq <- fit_eq %>%
  separate(col = "name", into = c("var", "group", "model"), sep = "_") %>%
  left_join(vars_scales, by = c("var" = "variables")) %>%
  rename_all(~ str_remove_all(., "M_|Value|_Estimate")) %>%
  select(Topic, group, model, everything(), scale, var, Filename) %>%
  arrange(Topic, group, model) %>%
  group_by(Topic, group) %>%
  mutate(CFI_dif = CFI - lag(CFI),
         sig_CFI = CFI_dif < -0.01,
         sig_grp = lead(sig_CFI, n = 1),
         sig_grp = ifelse(is.na(sig_grp), F, sig_grp),
         group = ifelse(group == "len", "Length", "Mode design")) %>%
  ungroup()


fit_eq %>%
  count(group, model, sig_CFI)

fit_eq %>%
#  filter(sig_CFI == T|sig_grp == T) %>%
  View()


# Show differences --------------------------------------------------------

sig_models <- eq_models[fit_eq$Filename[fit_eq$sig_grp == T]]


get_dif_par <- function(model) {
  nm <- model$summaries$Filename

  param_dif <- model$parameters$unstandardized %>%
    as_tibble() %>%
    select(paramHeader, param, est, se, Group) %>%
    filter(!paramHeader %in% c("Means", "Residual.Variances", "Variances")) %>%
    mutate(Group = as.numeric(as.factor(Group))) %>%
    pivot_wider(names_from = Group, values_from = c(est, se)) %>%
    mutate(name = nm,
           name = str_remove_all(name, "inv_data3_|\\.out|comp_")) %>%
    separate(col = "name", into = c("first_var", "group", "model"),
             sep = "_") %>%
    rename(coef = paramHeader, variable = param)

  if (param_dif$model[1] == "metric") {
    param_dif %>%
      filter(!str_detect(coef, "BY"))
  } else {
    param_dif %>%
      filter(str_detect(coef, "BY"))
  }

}

sig_parameters <- map_df(sig_models, get_dif_par)

View(sig_parameters)

# Do some overall sig testing ---------------------------------------------

fit_eq_small <- fit_eq %>%
  filter(model != "config") %>%
  mutate(cat = ifelse(scale > 4, F, T))

# type of comparison
count(fit_eq_small, sig_CFI, model) %>%
  mutate(prop = n/sum(n))
chisq.test(fit_eq_small$sig_CFI, fit_eq_small$model)

# type of comparison
count(fit_eq_small, sig_CFI, group) %>%
  mutate(prop = n/sum(n))
chisq.test(fit_eq_small$sig_CFI, fit_eq_small$group)


count(fit_eq_small, sig_CFI, cat) %>%
  mutate(prop = n/sum(n))
chisq.test(fit_eq_small$sig_CFI, fit_eq_small$cat)



# save results ------------------------------------------------------------
write_csv(fit_eq, "./data/clean/eq_fit.csv")
write_csv(sig_parameters, "./data/clean/sig_parameters.csv")
write_rds(inv_data3, "./data/clean/evs_clean2.rds" )
