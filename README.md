# Investigating the impact of mode design on measurement quality

Using an experiment in the European Value Study Germany we do the following comparisons:
- compare single- vs. mixed-mode designs (full length FTF vs. full length mixed-mode)
- compare short vs. long questionnaire mixed modes (matrix vs. full length)


# To do

- [x] set-up GitHub (Alex)
- [x] provide data (Tobias/Pablo)
- [x] alternative quality indicators (Tobias/Pablo)
- [x] create weights (Tobias will do the weights)
- [x] check scales fit and choose for invariance (Alex)
- [x] check problematic models
- [x] add corrlation for that one model
- [x] do the analysis with weight
- [x] do table where we have differences (Alex)
- [x] topic, if categorical/topic, if it explains significant models
- [ ] to add topic and if there is showcards (Pablo)
- [ ] write intro and lit review (Joe)
- [ ] write data section (Tobias/Pablo)
- [ ] write methods quality indicators (Tobias/Pablo)
- [ ] write methods invariance (Alex)
- [ ] write up results (Joe)
- [ ] write conclusions (Joe)






# To discuss

- I excluded breakoffs but should we exclude partials?        

- what scales to use and the changes made
- agree on groups, sequance of models and weighting`

# Data used

We started the analysis using two datasets which can be accessed from the GESIS data archive.

- ZA7500_v3-0-0
- ZA7502_v1-0-0

# Software

We used a number of softwares:

- Stata 14? for the alternative data quality indicators
- R 4.0 for data cleaning and batch analysis for invariance testing
- Mplus 8.3 for equivalence testing

`R` session info:

```
R version 4.0.2 (2020-06-22)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 17134)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.1252 
[2] LC_CTYPE=English_United Kingdom.1252   
[3] LC_MONETARY=English_United Kingdom.1252
[4] LC_NUMERIC=C                           
[5] LC_TIME=English_United Kingdom.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets 
[6] methods   base     

other attached packages:
 [1] haven_2.3.1     forcats_0.5.0   stringr_1.4.0  
 [4] dplyr_1.0.0     purrr_0.3.4     readr_1.3.1    
 [7] tidyr_1.1.0     tibble_3.0.1    ggplot2_3.3.2  
[10] tidyverse_1.3.0

loaded via a namespace (and not attached):
 [1] tidyselect_1.1.0      pander_0.6.3         
 [3] lattice_0.20-41       colorspace_1.4-1     
 [5] vctrs_0.3.1           generics_0.0.2       
 [7] utf8_1.1.4            blob_1.2.1           
 [9] rlang_0.4.6           pillar_1.4.4         
[11] glue_1.4.1            withr_2.2.0          
[13] DBI_1.1.0             dbplyr_1.4.4         
[15] gsubfn_0.7            modelr_0.1.8         
[17] readxl_1.3.1          lifecycle_0.2.0      
[19] plyr_1.8.6            munsell_0.5.0        
[21] gtable_0.3.0          cellranger_1.1.0     
[23] rvest_0.3.5           coda_0.19-3          
[25] parallel_4.0.2        fansi_0.4.1          
[27] MplusAutomation_0.7-3 proto_1.0.0          
[29] broom_0.5.6           Rcpp_1.0.4.6         
[31] xtable_1.8-4          scales_1.1.1         
[33] backports_1.1.8       jsonlite_1.7.0       
[35] fs_1.4.1              texreg_1.37.5        
[37] hms_0.5.3             packrat_0.5.0        
[39] digest_0.6.25         stringi_1.4.6        
[41] grid_4.0.2            cli_2.0.2            
[43] tools_4.0.2           magrittr_1.5         
[45] crayon_1.3.4          pkgconfig_2.0.3      
[47] ellipsis_0.3.1        data.table_1.12.8    
[49] xml2_1.3.2            reprex_0.3.0         
[51] lubridate_1.7.9       assertthat_0.2.1     
[53] httr_1.4.1            rstudioapi_0.11      
[55] R6_2.4.1              boot_1.3-25          
[57] nlme_3.1-148          compiler_4.0.2 

```
