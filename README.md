# Investigating the impact of mode design on measurement quality

Using an experiment in the European Value Study Germany we do the following comparisons:
- compare single- vs. mixed-mode designs (full length FTF vs. full length mixed-mode)
- compare short vs. long questionnaire (matrix vs. full length)


# To do

- [x] set-up GitHub (Alex)
- [x] provide data (Tobias/Pablo)
- [x] alternative quality indicators (Tobias/Pablo)
- [ ] check scales fit and choose for invariance (Alex)
- [ ] do invariance testing (Alex)
- [ ] write intro and lit review (Joe)
- [ ] write data section (Tobias/Pablo)
- [ ] write methods quality indicators (Tobias/Pablo)
- [ ] write methods invariance (Alex)
- [ ] write up results (Joe)
- [ ] write conclusions (Joe)



# To discuss

- results from Pablo and Tobias
- scales with 0 in the excel
- what scales to use

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
R version 4.0.0 (2020-04-24)
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
 [1] haven_2.2.0     forcats_0.5.0   stringr_1.4.0  
 [4] dplyr_0.8.5     purrr_0.3.4     readr_1.3.1    
 [7] tidyr_1.0.2     tibble_3.0.1    ggplot2_3.3.0  
[10] tidyverse_1.3.0

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.4.6     cellranger_1.1.0 pillar_1.4.4    
 [4] compiler_4.0.0   dbplyr_1.4.3     tools_4.0.0     
 [7] packrat_0.5.0    jsonlite_1.6.1   lubridate_1.7.8 
[10] lifecycle_0.2.0  nlme_3.1-147     gtable_0.3.0    
[13] lattice_0.20-41  pkgconfig_2.0.3  rlang_0.4.5     
[16] reprex_0.3.0     cli_2.0.2        DBI_1.1.0       
[19] rstudioapi_0.11  withr_2.2.0      xml2_1.3.2      
[22] httr_1.4.1       fs_1.4.1         generics_0.0.2  
[25] vctrs_0.2.4      hms_0.5.3        grid_4.0.0      
[28] tidyselect_1.0.0 glue_1.4.0       R6_2.4.1        
[31] fansi_0.4.1      readxl_1.3.1     modelr_0.1.7    
[34] magrittr_1.5     backports_1.1.6  scales_1.1.0    
[37] ellipsis_0.3.0   rvest_0.3.5      assertthat_0.2.1
[40] colorspace_1.4-1 utf8_1.1.4       stringi_1.4.6   
[43] munsell_0.5.0    broom_0.5.6      crayon_1.3.4 

```
