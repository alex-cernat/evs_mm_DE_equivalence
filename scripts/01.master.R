

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



pkg <- c("tidyverse", "haven")

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
unzip("./data/raw/ZA7500_v3-0-0.dta.zip",
      exdir = "./data/raw")
unzip("./data/raw/ZA7502_v1-0-0.dta.zip",
      exdir = "./data/raw")


# read data ---------------------------------------------------------------


meta_data <- readxl::read_xlsx("./data/clean/EVS_Data_Quality_Overview.xlsx")

za7500 <- read_dta("./data/raw/ZA7500_v3-0-0.dta")
za7502 <- read_dta("./data/raw/ZA7502_v1-0-0.dta")

za7500



vars_scales <- filter(meta_data, `Measurement Invariance` == "1") %>%
  select(variables, Topic, scale)

# make smaller data only with variables we want to look at
inv_data <- select(za7500, id_cocas, caseno, vars_scales$variables)

# code all missings
inv_data2 <- inv_data %>%
  mutate_all(~ ifelse(. < 0, NA, .))

# take attributes from old data
for (i in 1:ncol(inv_data)) {
  attributes(inv_data2[[i]]) <- attributes(inv_data[[i]])
}

# look at data
scales <- unique(vars_scales$Topic)

# function to do fast desccriptives by scale
scale_explore <- function(scale) {
  vars_explore <- vars_scales$variables[vars_scales$Topic == scale]
  map(vars_explore, function(x) desc_tab(inv_data2[[x]]))
}


# run base CFA models -----------------------------------------------------

# make data numeric for export
inv_data3 <- mutate_all(inv_data2, ~as.numeric(.))

make_cfa <- function(scale) {
  vars_explore <- vars_scales$variables[vars_scales$Topic == scale]
  cat <- vars_scales$scale[vars_scales$variables == vars_explore[1]] %>%
    as.numeric() < 5
  mplus_cfa(inv_data3, vars_explore, categorical = cat)
}

# make models
map(scales, make_cfa)

# run models
MplusAutomation::runModels("./mplus/cfa/", showOutput = T, local_tmpdir = T)

# read models
cfa_models <- MplusAutomation::readModels(
  list.files("./mplus/cfa/", pattern = "out", full.names = T)
)

cfa_models$inv_data3_v1_.out

# import fit
fit_cfa <- map_df(cfa_models, read_fit_mlr)

View(fit_cfa)

read_fit_mlr(cfa_models[[1]])

# based on the fit redo the norms scale in 2:
#   f1 by v149 v150 v152 v159 v162;
#   f2 by v151 v153 v154 v155 v156 v157 v158 v160 v161;
# exclude !v163 ;

# split demography in two groups:
# f1 by v133 v135 v136 v138 v139 v141;
# f2 by v134 v137 v140;
