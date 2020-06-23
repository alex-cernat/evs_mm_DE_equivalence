*************************************************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*																											*
*			                               EVS 2017 Data Quality Indicators								    *
*      			                                                 											*			
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*																						 	  				*			
* Authors: 			Pablo Christmann, Tobias Gummer       						                     	    *
* Contact: 			pablo.christmann@gesis.org, tobias.gummer@gesis.org                    					*
* Date: 			June 19, 2020                                                  					        *
* Software:			Stata 15.1                                                              				*                                                                          
* Datasets:         ZA7500_v3-0-0.dta     																	*
*					ZA7502_v1-0-0.dta                                           		  					*		
*																											*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*************************************************************************************************************

set more off
clear all

*** Graphics
set scheme s1mono
graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

*** Install required packages
*ssc install TAB_CHI
*ssc install ciplot

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\"

*** Load dataset: Main Dataset
use "data/ZA7500_v3-0-0.dta", clear

keep if c_abrv=="DE"
keep if mm_mixed_mode == 5 // cases for the full-length self-administered mixed-mode survey are included in both datasets, keep only face-to-face data

save "data/temp/face2face.dta", replace

*** Load dataset: Mixed-Mode Dataset
use "data/ZA7502_v1-0-0.dta", clear
keep if c_abrv=="DE"
save "data/temp/mixedmode.dta", replace

append using "data/temp/face2face.dta"
save "data/evs_data_quality.dta", replace

use "data/evs_data_quality.dta", clear

*------------------*
* Data Preparation * 
*------------------*

gen survey_mode =.
replace survey_mode = 1 if mm_mixed_mode ==5
replace survey_mode = 2 if mm_mixed_mode ==4
replace survey_mode = 3 if mm_mixed_mode ==1

label variable survey_mode "Survey mode"
label define survey_mode 1 "Face-to-Face" 2 "Mi-Mo Matrix" 3 "Mi-Mo Full" 
label values survey_mode survey_mode
tab survey_mode mm_mixed_mode, m

********
global varlist v1	v2	v3	v4	v5	v6	v7	v8	v9	v10	v11	v12	v13	v14	v15 ///
				v16	v17	v18	v19	v20	v21	v22	///
				v23	v24	v25	v26	v27	v28	v29	v30 /// full list q6
				v31	v32	v33	v34	v35	v36	v37	v38	v39	v40	 ///
				v41 v42 v43 v44 v45 v45a /// // full list q11
				v46	v47	v48	v49	v50	v51	v52	v53	v54	v55	v56	v57	v58	///
				v59	v60	v61	v62	v63	v64	v65	v66	v67	v68	v69	v70	v71	v72	v73	///
				v74	v75	v76	v77	v78	v79	v80	v81	v82	v83	v84	v85		///  
				v86	v87	v88	v89	v90	v91	v92	v93	v94	v95	v96 /// full list q28
				v72_DE v73_DE v74_DE v75_DE v76_DE v77_DE v78_DE v79_DE /// This is specific for Germany
				v97	v98	v99	v100	v101	///
				v102	v103	v104	v105	v106	v107	v108	///
				v109	v110	v111	v112	v113	v114	v115	///
				v116	v117	v118	v119	v120	v121	v122	///
				v123	v124	v125	v126	v127	v128	v129	///
				v130	v131	v132	v133	v134	v135	v136	///
				v137	v138	v139	v140	v141	v142	v143	///
				v144	v145	v146	v147	v148	v149	v150	///
				v151	v152	v153	v154	v155	v156	v157	///
				v158	v159	v160	v161	v162	v163	v164	///
				v165	v166	v167	v168	v169	v170	v171	///
				v172	v173	v174_cs	v175_cs	v176	v177	v178	///
				v179	v180	v181	v182	v183	v184	v185	///
				v186	v187	v188	v189	v190	v191	v192	///
				v193	v194	v195	v196	v197	v198	v199	///
				v200	v201 	v202	v203	v204	v205	v206	///
				v207	v208	v209	v210	v211	v212	v213	///
				v214	v215	v216	v217	v218	v219	v220	///
				v221	v222	v223	v224	v225	v226	v227	///
				v228b_r	v229	v230	v231b_r	v232	v233b_r	v234	///
				v235	v236	v237 v238	v239a	v239b	v240	///
				v241	v242	v243_ISCED_3	v244	v245 v246_ISCO_2	///
				v247	v248	v248a	v249	v250     v251b_r	///
				v252_ISCED_3	 v253	v254	v255_ISCO_2	v256	v257	///
				v258	v259	v260	v261 v262_ISCED_3	v263_ISCED_3	v264	///
				v265	v266	v267	v268	v269	v270 v271	v272	///
				v273	v274

				
// double check number of variables				
unab vars : $varlist 
di `: word count `vars''   // n = 285

// count number of valid values per respondent
egen nonmiss=rownonmiss($varlist)
ta nonmiss

// check distribution of incomplete cases and break offs 
*ta fmissings 
*ta mm_select_sample

// there are 17 cases in DE without any valid answer (nonmiss=0) > Dropped
*list c_abrv caseno mode mm_select_sample v1 v45 v132 v225 if nonmiss==0
*drop if nonmiss==0
*drop if caseno==2107006

// COUNT no. of item non response (DK + NA)	
egen n_mv=anycount($varlist), v(-1,-2)
ta n_mv

// COUNT no. of DK
egen n_dk=anycount($varlist), v(-1)
ta n_dk

// COUNT no. of NA
egen n_na=anycount($varlist), v(-2)
ta n_na

// COUNT no. of MULTI
egen n_multiple=anycount($varlist), v(-10)
ta n_multiple

// count number of (not)asked questions (thus removing not applicable, not asked and 
// no follow up questions)
* -3 = Not applicable; -4 = question not asked; -9 = no follow up

egen n_notasked=anycount($varlist), v(-3, -4, -9)
ta n_notasked

// count number of asked questions
gen n_totq = 285 - n_notasked
sum n_totq

// count share mv
gen mv_share=(n_mv/n_totq)
*sum n_mv n_totq mv_share if filter==1

// count share dk
gen dk_share=(n_dk/n_totq)
*sum n_dk n_totq dk_share if filter==1

// count share na
gen na_share=(n_na/n_totq)
*sum n_na n_totq na_share if filter==1

// count share multiple
gen multiple_share=(n_multiple/n_totq)
*sum n_na n_totq na_share if filter==1

gen break_off = 0 
replace break_off =1 if  na_share>0.50
tab break_off, m

gen partial = 0 
replace partial=1 if na_share>=0.20 & na_share<=0.50
tab partial, m

// Generate Filter Variable for Full Cases
gen filter=1
lab def filter 1 "Full & Incomplete" 2 "Breakoff"
lab val filter filter
replace filter=1 if partial==1
replace filter=2 if break_off==1
tab filter
	
*----------------------------------------------------------------------------*
* Figures for Survey Break-Off, Partial Interviews, dk, na, multiple answers *
*----------------------------------------------------------------------------*

// Break Off Rates
ciplot break_off , binomial by(survey_mode) title("Survey break-off rate", size(medlarge) margin(medsmall)) subtitle("") note("")  saving(figures/break_off, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off)  
// Partial Rates
ciplot partial , binomial by(survey_mode) title("Partial interview rate", size(medlarge) margin(medsmall)) subtitle("") note("")  saving(figures/partial, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off)  
// Don't know
ciplot dk_share if filter==1, poisson by(survey_mode) title("Percentage don't know (DK)", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/dk, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))   xlabel(,labsize(small)) ylabel(0 (0.02) 0.1, grid glcolor(gs13) tlwidth(vthin)) legend(off)   
// No Answer
ciplot na_share if filter==1, poisson by(survey_mode) title("Percentage no answer (NA)", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/na, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off) 
// Multiple Answers
ciplot multiple_share if filter==1, poisson by(survey_mode) title("Multiple answers mail", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/multiple, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0)) xlabel(,labsize(small)) ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off) 

*--------------*
* Acquiescence * 
*--------------*
global acquiescence_5 v46 v47 v48 v49 v50 v80 v81 v82 v83 v84 v199 v200 v201 v202 v203

// double check number of variables				
unab vars : $acquiescence_5  
di `: word count `vars''   // n = 15

egen acquiescence_5 = anycount($acquiescence_5), values(1, 2)  
egen acquiescence_5_mi = anycount($acquiescence_5), values(-2, -1, -10, -3, -4, -9)

gen n_acquiescence_5 = 15 - acquiescence_5_mi

gen acquiescence_5_share = (acquiescence_5/n_acquiescence_5)
*hist acquiescence_5_share

// Acquiescence 5pt
ciplot acquiescence_5_share if filter==1 , by(survey_mode) title("Acquiescence", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/acquiescence_5, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) legend(off) ylabel(0.35 (0.02) 0.45, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*-------------------*
* Middle Categories * 
*-------------------*

*** 5 Point Scale
// Eligible items with 5pt rating scales, where ‘3’ is equal to the middle response category.	26 items in 8 questions:

global middle_5  v8	v46	v47	v48	v49	v50	v80	v81	v82	v83	v84	v184	v199	v200	v201	v202	v203	v212	v213	v214	v215	v216	v217	v218	v219	v220

unab vars : $middle_5  
di `: word count `vars''   // n = 26

egen middle_5 = anycount($middle_5), values(3)  
egen middle_5_mi = anycount($middle_5), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_5 = 26 - middle_5_mi

gen middle_5_share = (middle_5/n_middle_5)
*hist middle_5_share

*** 10 Point Scale
// Eligible items with 10pt rating scales, where 5 to 6 is equal to the middle response category.	41 items in 12 questions:

global middle_10  v38	v39	v63	v102	v103	v104	v105	v106	v107	v133	v134	v135	v136	v137	v138	v139	v140	v141	v142	v143	v144	v149	v150	v151	v152	v153	v154	v155	v156	v157	v158	v159	v160	v161	v162	v163	v185	v186	v187	v188	v198

unab vars : $middle_10  
di `: word count `vars''   // n = 41

egen middle_10 = anycount($middle_10), values(5, 6)  
egen middle_10_mi = anycount($middle_10), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_10 = 41 - middle_10_mi

gen middle_10_share = (middle_10/n_middle_10)
*hist middle_10_share

// All
global middle_all v8	v46	v47	v48	v49	v50	v80	v81	v82	v83	v84	v184	v199	v200	v201	v202	v203	v212	v213	v214	v215	v216	v217	v218	v219	v220 v38	v39	v63	v102	v103	v104	v105	v106	v107	v133	v134	v135	v136	v137	v138	v139	v140	v141	v142	v143	v144	v149	v150	v151	v152	v153	v154	v155	v156	v157	v158	v159	v160	v161	v162	v163	v185	v186	v187	v188	v198

unab vars : $middle_all  
di `: word count `vars''   // n = 67

gen middle_all =  middle_5 + middle_10

egen middle_all_mi = anycount($middle_all), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_all = 67 - middle_all_mi

gen middle_all_share = (middle_all/n_middle_all)

// Middle Categories All
ciplot middle_all_share if filter==1, by(survey_mode) title("Middle answers", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/middle_all, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small))  ylabel(0.15 (0.02) 0.25, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*------------------------*
* Extreme Response Style * 
*------------------------*

*** 5 Point Scale
// Eligible items with 5pt rating scale, where the lowest response category = ‘1’, and the highest = ‘5’.	26 items in 8 questions:

global ers_5  v8	v46	v47	v48	v49	v50	v80	v81	v82	v83	v84	v184	v199	v200	v201	v202	v203	v212	v213	v214	v215	v216	v217	v218	v219	v220

unab vars : $ers_5  
di `: word count `vars''   // n = 26

egen ers_5 = anycount($ers_5), values(1,5)  
egen ers_5_mi = anycount($ers_5), values(-2, -1, -10, -3, -4, -9)  

gen n_ers_5 = 26 - ers_5_mi

gen ers_5_share = (ers_5/n_ers_5)
*hist ers_5_share
table survey_mode if filter==1 , c(mean ers_5_share count ers_5_share)				
	
*** 10 Point Scale
// Eligible items with a 10pt rating scale, where the lowest response category = ‘1’, and the highest = ‘10’.	41 items in 12 questions:

global ers_10  v38	v39	v63	v102	v103	v104	v105	v106	v107	v133	v134	v135	v136	v137	v138	v139	v140	v141	v142	v143	v144	v149	v150	v151	v152	v153	v154	v155	v156	v157	v158	v159	v160	v161	v162	v163	v185	v186	v187	v188	v198

unab vars : $ers_10  
di `: word count `vars''   // n = 41

egen ers_10 = anycount($ers_10), values(1, 10)  
egen ers_10_mi = anycount($ers_10), values(-2, -1, -10, -3, -4, -9)  

gen n_ers_10 = 41 - ers_10_mi

gen ers_10_share = (ers_10/n_ers_10)
*hist ers_10_share
table survey_mode if filter==1 , c(mean ers_10_share count ers_10_share)		

// All
global ers_all v8	v46	v47	v48	v49	v50	v80	v81	v82	v83	v84	v184	v199	v200	v201	v202	v203	v212	v213	v214	v215	v216	v217	v218	v219	v220 v38	v39	v63	v102	v103	v104	v105	v106	v107	v133	v134	v135	v136	v137	v138	v139	v140	v141	v142	v143	v144	v149	v150	v151	v152	v153	v154	v155	v156	v157	v158	v159	v160	v161	v162	v163	v185	v186	v187	v188	v198

unab vars : $ers_all  
di `: word count `vars''   // n = 67

gen ers_all =  ers_5 + ers_10

egen ers_all_mi = anycount($ers_all), values(-2, -1, -10, -3, -4, -9)  

gen n_ers_all = 67 - ers_all_mi

gen ers_all_share = (ers_all/n_ers_all)
*hist ers_all_share

table survey_mode if filter==1 , c(mean ers_all_share count ers_all_share)				
	
// Extreme Response Style All
ciplot ers_all_share if filter==1, by(survey_mode) title("Extreme Response Style", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/ers_all, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small))  ylabel(0.3 (0.02) 0.4, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*----------------------*
* Straightlining : All * 
*----------------------*

** 4point Scale: Without dk's
egen v1_v6_lining = diff(v1-v6) if (v1>-1 & v2>-1 &  v3>-1 &  v4>-1 & v5>-1 & v6>-1)
egen v32_v37_lining = diff(v32-v37) if (v32>-1 & v33>-1 &  v34>-1 &  v35>-1 & v36>-1 & v37>-1)
egen v72_v79_lining_A = diff(v72 v73 v74 v75 v76 v77 v78 v79) if (v72>-1 & v73>-1 &  v74>-1 &  v75>-1 & v76>-1 & v77>-1 & v78>-1 & v79>-1)
egen v115_v132_lining = diff(v115-v132) if (v115>-1 & v116>-1 &  v117>-1 &  v118>-1 & v119>-1 & v120>-1 & v121>-1 & v122>-1 & v123>-1 & v124>-1 & v125>-1 & v126>-1 & v127>-1 & v128>-1 & v129>-1 & v130>-1 & v131>-1 & v132>-1)  
egen v145_v148_lining = diff(v145-v148) if (v145>-1 & v146>-1 &  v147>-1 &  v148>-1) 
egen v164_v168_lining = diff(v164-v168) if (v164>-1 & v165>-1 &  v166>-1 &  v167>-1 &  v168>-1) 
egen v176_v183_lining = diff(v176-v183) if (v176>-1 & v177>-1 &  v178>-1 &  v179>-1 &  v180>-1  &  v181>-1  &  v182>-1  &  v183>-1) 
egen v189_v193_lining = diff(v189-v193) if (v189>-1 & v190>-1 &  v191>-1 &  v192>-1 &  v193>-1 )
egen v194_v197_lining = diff(v194-v197) if (v194>-1 & v195>-1 &  v196>-1 &  v197>-1 ) 
egen v205_v207_lining = diff(v205-v207) if (v205>-1 & v206>-1 &  v207>-1) 
egen v221_v224_lining = diff(v221-v224) if (v221>-1 & v222>-1 &  v223>-1 &  v224>-1) 

egen count_lining_4 = anycount(v1_v6_lining v32_v37_lining v72_v79_lining_A v115_v132_lining v145_v148_lining v164_v168_lining v176_v183_lining v189_v193_lining v194_v197_lining v205_v207_lining v221_v224_lining),values(0)
tab count_lining_4, m

recode v1_v6_lining (.=-99)
recode v32_v37_lining (.=-99)
recode v72_v79_lining_A (.=-99)
recode v115_v132_lining (.=-99)
recode v145_v148_lining (.=-99)
recode v164_v168_lining (.=-99)
recode v176_v183_lining (.=-99)
recode v189_v193_lining (.=-99)
recode v194_v197_lining (.=-99)
recode v205_v207_lining (.=-99)
recode v221_v224_lining (.=-99)

egen lining_missing_4 = anycount(v1_v6_lining v32_v37_lining v72_v79_lining_A v115_v132_lining v145_v148_lining v164_v168_lining v176_v183_lining v189_v193_lining v194_v197_lining v205_v207_lining v221_v224_lining ), values(-99)

gen N_valid_items_lining_4 = 11 - lining_missing_4

gen lining_4_share =  count_lining_4 / N_valid_items_lining_4
sum lining_4_share, detail
*hist lining_4_share

// Straightlining 4point
*ciplot lining_4_share if filter==1, poisson by(survey_mode) title("Straightlining (4pt)", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/lining_4_share, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) legend(off)  

** 5point Scale: Without dk's
egen v46_v50_lining = diff(v46-v50) if (v46>-1 & v47>-1 &  v48>-1 &  v49>-1 & v50>-1) 
egen v72_v79_lining_B = diff(v72_DE v73_DE v74_DE v75_DE v76_DE v77_DE v78_DE v79_DE) if (v72_DE>-1 & v73_DE>-1 &  v74_DE>-1 &  v75_DE>-1 & v76_DE>-1 & v77_DE>-1 & v78_DE>-1 & v79_DE>-1)
egen v82_v84_lining = diff(v82-v84) if (v82>-1 & v83>-1 &  v84>-1)
egen v199_v203_lining = diff(v199-v203) if (v199>-1 & v200>-1 &  v201>-1 &  v202>-1  &  v203>-1 ) 
egen v208_v211_lining = diff(v208-v211) if (v208>-1 & v209>-1 &  v210>-1 &  v211>-1  )
egen v212_v216_lining = diff(v212-v216) if (v212>-1 & v213>-1 &  v214>-1 &  v215>-1  &  v216>-1) 
egen v217_v220_lining = diff(v217-v220) if (v217>-1 & v218>-1 &  v219>-1 &  v220>-1  )

egen count_lining_5 = anycount(v46_v50_lining v72_v79_lining_B v82_v84_lining v199_v203_lining v208_v211_lining v212_v216_lining v217_v220_lining),values(0)
tab count_lining_5, m

recode v46_v50_lining (.=-99)
recode v72_v79_lining_B (.=-99)
recode v82_v84_lining (.=-99)
recode v199_v203_lining (.=-99)
recode v208_v211_lining (.=-99)
recode v212_v216_lining (.=-99)
recode v217_v220_lining (.=-99)

egen lining_missing_5 = anycount(v46_v50_lining v72_v79_lining_B v82_v84_lining v199_v203_lining v208_v211_lining v212_v216_lining v217_v220_lining), values(-99)

gen N_valid_items_lining_5 = 7 - lining_missing_5

gen lining_5_share =  count_lining_5 / N_valid_items_lining_5
sum lining_5_share, detail
*hist lining_5_share

// Straightlining 5point
*ciplot lining_5_share if filter==1, poisson by(survey_mode) title("Straightlining (5pt)", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/lining_5_share, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) legend(off)  

** 10point Scale: Without dk's
egen v103_v107_lining = diff(v103-v107) if (v103>-1 & v104>-1 &  v105>-1 &  v106>-1 & v107>-1) 
egen v133_v141_lining = diff(v133-v141) if (v133>-1 & v134>-1 &  v135>-1 &  v136>-1   &  v137>-1  &  v138>-1  &  v139>-1  &  v140>-1   &  v141>-1 ) 
egen v149_v163_lining = diff(v149-v163) if (v149>-1 & v150>-1 &  v151>-1 &  v152>-1   &  v153>-1  &  v154>-1  &  v155>-1  &  v156>-1   &  v157>-1  &  v158>-1 &  v159>-1 &  v160>-1 &  v161>-1  &  v162>-1 &  v163>-1)  

egen count_lining_10 = anycount(v103_v107_lining v133_v141_lining v149_v163_lining),values(0)
tab count_lining_10, m

recode v103_v107_lining (.=-99)
recode v133_v141_lining (.=-99)
recode v149_v163_lining (.=-99)

egen lining_missing_10 = anycount(v103_v107_lining v133_v141_lining v149_v163_lining), values(-99)

gen N_valid_items_lining_10 = 3 - lining_missing_10

gen lining_10_share =  count_lining_10 / N_valid_items_lining_10
sum lining_10_share, detail
*hist lining_10_share

// Straightlining 5point
*ciplot lining_10_share if filter==1, poisson by(survey_mode) title("Straightlining (5pt)", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/lining_10_share, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small)) legend(off)  

** All Scales: Without dk's
egen count_lining_all = anycount(v1_v6_lining v32_v37_lining v72_v79_lining_A v115_v132_lining v145_v148_lining v164_v168_lining v176_v183_lining v189_v193_lining v194_v197_lining v205_v207_lining v221_v224_lining v46_v50_lining v72_v79_lining_B v82_v84_lining v199_v203_lining v208_v211_lining v212_v216_lining v217_v220_lining v103_v107_lining v133_v141_lining v149_v163_lining),values(0)
egen lining_missing_all = anycount(v1_v6_lining v32_v37_lining v72_v79_lining_A v115_v132_lining v145_v148_lining v164_v168_lining v176_v183_lining v189_v193_lining v194_v197_lining v205_v207_lining v221_v224_lining v46_v50_lining v72_v79_lining_B v82_v84_lining v199_v203_lining v208_v211_lining v212_v216_lining v217_v220_lining v103_v107_lining v133_v141_lining v149_v163_lining), values(-99)

gen N_valid_items_lining_all = 21 - lining_missing_all

gen lining_all_share =  count_lining_all / N_valid_items_lining_all
sum lining_all_share, detail
*hist lining_all_share

// Straightlining: all scale points
ciplot lining_all_share if filter==1, poisson by(survey_mode) title("Straightlining", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/lining_all_share, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small))  ylabel(0.05 (0.02) 0.15, grid glcolor(gs13) tlwidth(vthin)) legend(off) 

*-------------------------------------------*
* Straightlining : Coefficient of Variation * 
*-------------------------------------------*
** SD
* 4pt
egen v1_v6_lining_sd = rowsd(v1-v6) if (v1>-1 & v2>-1 &  v3>-1 &  v4>-1 & v5>-1 & v6>-1)
egen v32_v37_lining_sd = rowsd(v32-v37) if (v32>-1 & v33>-1 &  v34>-1 &  v35>-1 & v36>-1 & v37>-1)
egen v72_v79_lining_A_sd = rowsd(v72 v73 v74 v75 v76 v77 v78 v79) if (v72>-1 & v73>-1 &  v74>-1 &  v75>-1 & v76>-1 & v77>-1 & v78>-1 & v79>-1)
egen v115_v132_lining_sd = rowsd(v115-v132) if (v115>-1 & v116>-1 &  v117>-1 &  v118>-1 & v119>-1 & v120>-1 & v121>-1 & v122>-1 & v123>-1 & v124>-1 & v125>-1 & v126>-1 & v127>-1 & v128>-1 & v129>-1 & v130>-1 & v131>-1 & v132>-1)  
egen v145_v148_lining_sd = rowsd(v145-v148) if (v145>-1 & v146>-1 &  v147>-1 &  v148>-1) 
egen v164_v168_lining_sd = rowsd(v164-v168) if (v164>-1 & v165>-1 &  v166>-1 &  v167>-1 &  v168>-1) 
egen v176_v183_lining_sd = rowsd(v176-v183) if (v176>-1 & v177>-1 &  v178>-1 &  v179>-1 &  v180>-1  &  v181>-1  &  v182>-1  &  v183>-1) 
egen v189_v193_lining_sd = rowsd(v189-v193) if (v189>-1 & v190>-1 &  v191>-1 &  v192>-1 &  v193>-1 )
egen v194_v197_lining_sd = rowsd(v194-v197) if (v194>-1 & v195>-1 &  v196>-1 &  v197>-1 ) 
egen v205_v207_lining_sd = rowsd(v205-v207) if (v205>-1 & v206>-1 &  v207>-1) 
egen v221_v224_lining_sd = rowsd(v221-v224) if (v221>-1 & v222>-1 &  v223>-1 &  v224>-1) 
* 5pt
egen v46_v50_lining_sd = rowsd(v46-v50) if (v46>-1 & v47>-1 &  v48>-1 &  v49>-1 & v50>-1) 
egen v72_v79_lining_B_sd = rowsd(v72_DE v73_DE v74_DE v75_DE v76_DE v77_DE v78_DE v79_DE) if (v72_DE>-1 & v73_DE>-1 &  v74_DE>-1 &  v75_DE>-1 & v76_DE>-1 & v77_DE>-1 & v78_DE>-1 & v79_DE>-1)
egen v82_v84_lining_sd = rowsd(v82-v84) if (v82>-1 & v83>-1 &  v84>-1)
egen v199_v203_lining_sd = rowsd(v199-v203) if (v199>-1 & v200>-1 &  v201>-1 &  v202>-1  &  v203>-1 ) 
egen v208_v211_lining_sd = rowsd(v208-v211) if (v208>-1 & v209>-1 &  v210>-1 &  v211>-1  )
egen v212_v216_lining_sd = rowsd(v212-v216) if (v212>-1 & v213>-1 &  v214>-1 &  v215>-1  &  v216>-1) 
egen v217_v220_lining_sd = rowsd(v217-v220) if (v217>-1 & v218>-1 &  v219>-1 &  v220>-1  )
* 10pt
egen v103_v107_lining_sd = rowsd(v103-v107) if (v103>-1 & v104>-1 &  v105>-1 &  v106>-1 & v107>-1) 
egen v133_v141_lining_sd = rowsd(v133-v141) if (v133>-1 & v134>-1 &  v135>-1 &  v136>-1   &  v137>-1  &  v138>-1  &  v139>-1  &  v140>-1   &  v141>-1 ) 
egen v149_v163_lining_sd = rowsd(v149-v163) if (v149>-1 & v150>-1 &  v151>-1 &  v152>-1   &  v153>-1  &  v154>-1  &  v155>-1  &  v156>-1   &  v157>-1  &  v158>-1 &  v159>-1 &  v160>-1 &  v161>-1  &  v162>-1 &  v163>-1)  
** Mean
* 4pt
egen v1_v6_lining_mean = rowmean(v1-v6) if (v1>-1 & v2>-1 &  v3>-1 &  v4>-1 & v5>-1 & v6>-1)
egen v32_v37_lining_mean = rowmean(v32-v37) if (v32>-1 & v33>-1 &  v34>-1 &  v35>-1 & v36>-1 & v37>-1)
egen v72_v79_lining_A_mean = rowmean(v72 v73 v74 v75 v76 v77 v78 v79) if (v72>-1 & v73>-1 &  v74>-1 &  v75>-1 & v76>-1 & v77>-1 & v78>-1 & v79>-1)
egen v115_v132_lining_mean = rowmean(v115-v132) if (v115>-1 & v116>-1 &  v117>-1 &  v118>-1 & v119>-1 & v120>-1 & v121>-1 & v122>-1 & v123>-1 & v124>-1 & v125>-1 & v126>-1 & v127>-1 & v128>-1 & v129>-1 & v130>-1 & v131>-1 & v132>-1)  
egen v145_v148_lining_mean = rowmean(v145-v148) if (v145>-1 & v146>-1 &  v147>-1 &  v148>-1) 
egen v164_v168_lining_mean = rowmean(v164-v168) if (v164>-1 & v165>-1 &  v166>-1 &  v167>-1 &  v168>-1) 
egen v176_v183_lining_mean = rowmean(v176-v183) if (v176>-1 & v177>-1 &  v178>-1 &  v179>-1 &  v180>-1  &  v181>-1  &  v182>-1  &  v183>-1) 
egen v189_v193_lining_mean = rowmean(v189-v193) if (v189>-1 & v190>-1 &  v191>-1 &  v192>-1 &  v193>-1 )
egen v194_v197_lining_mean = rowmean(v194-v197) if (v194>-1 & v195>-1 &  v196>-1 &  v197>-1 ) 
egen v205_v207_lining_mean = rowmean(v205-v207) if (v205>-1 & v206>-1 &  v207>-1) 
egen v221_v224_lining_mean = rowmean(v221-v224) if (v221>-1 & v222>-1 &  v223>-1 &  v224>-1) 
* 5pt
egen v46_v50_lining_mean = rowmean(v46-v50) if (v46>-1 & v47>-1 &  v48>-1 &  v49>-1 & v50>-1) 
egen v72_v79_lining_B_mean = rowmean(v72_DE v73_DE v74_DE v75_DE v76_DE v77_DE v78_DE v79_DE) if (v72_DE>-1 & v73_DE>-1 &  v74_DE>-1 &  v75_DE>-1 & v76_DE>-1 & v77_DE>-1 & v78_DE>-1 & v79_DE>-1)
egen v82_v84_lining_mean = rowmean(v82-v84) if (v82>-1 & v83>-1 &  v84>-1)
egen v199_v203_lining_mean = rowmean(v199-v203) if (v199>-1 & v200>-1 &  v201>-1 &  v202>-1  &  v203>-1 ) 
egen v208_v211_lining_mean = rowmean(v208-v211) if (v208>-1 & v209>-1 &  v210>-1 &  v211>-1  )
egen v212_v216_lining_mean = rowmean(v212-v216) if (v212>-1 & v213>-1 &  v214>-1 &  v215>-1  &  v216>-1) 
egen v217_v220_lining_mean = rowmean(v217-v220) if (v217>-1 & v218>-1 &  v219>-1 &  v220>-1  )
* 10pt
egen v103_v107_lining_mean = rowmean(v103-v107) if (v103>-1 & v104>-1 &  v105>-1 &  v106>-1 & v107>-1) 
egen v133_v141_lining_mean = rowmean(v133-v141) if (v133>-1 & v134>-1 &  v135>-1 &  v136>-1   &  v137>-1  &  v138>-1  &  v139>-1  &  v140>-1   &  v141>-1 ) 
egen v149_v163_lining_mean = rowmean(v149-v163) if (v149>-1 & v150>-1 &  v151>-1 &  v152>-1   &  v153>-1  &  v154>-1  &  v155>-1  &  v156>-1   &  v157>-1  &  v158>-1 &  v159>-1 &  v160>-1 &  v161>-1  &  v162>-1 &  v163>-1)  
** CV
foreach var of varlist v1_v6_lining v32_v37_lining v72_v79_lining_A v115_v132_lining v145_v148_lining v164_v168_lining ///
	v176_v183_lining v189_v193_lining v194_v197_lining v205_v207_lining v221_v224_lining ///
	v46_v50_lining v72_v79_lining_B v82_v84_lining v199_v203_lining v208_v211_lining v212_v216_lining ///
	v217_v220_lining v103_v107_lining v133_v141_lining v149_v163_lining ///
{
	gen `var'_cv = `var'_sd / `var'_mean
}

egen lining_cv_all = rowmean(v1_v6_lining_cv-v149_v163_lining_cv)

table survey_mode if filter==1 , c(mean lining_cv_all count lining_cv_all)				
	
*----------------------*
* Straightlining : Rho * 
*----------------------*
** 4pt
local g_scale = 4
* v1_v6
local g_items = 6
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v1-v6), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v1_v6_lining_rho = 1 - temp_rhosum
replace v1_v6_lining_rho = . if v1_v6_lining == -99
drop temp_rhosum

* v32_v37
local g_items = 6
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v32-v37), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v32_v37_lining_rho = 1 - temp_rhosum
replace v32_v37_lining_rho = . if v32_v37_lining == -99
drop temp_rhosum

* v72_v79_A
local g_items = 8
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v72 v73 v74 v75 v76 v77 v78 v79), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v72_v79_lining_A_rho = 1 - temp_rhosum
replace v72_v79_lining_A_rho = . if v72_v79_lining_A == -99
drop temp_rhosum

* v115_v132
local g_items = 18
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v115-v132), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v115_v132_lining_rho = 1 - temp_rhosum
replace v115_v132_lining_rho = . if v115_v132_lining == -99
drop temp_rhosum

* v145_v148
local g_items = 4
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v145-v148), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v145_v148_lining_rho = 1 - temp_rhosum
replace v145_v148_lining_rho = . if v145_v148_lining == -99
drop temp_rhosum

* v164_v168
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v164-v168), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v164_v168_lining_rho = 1 - temp_rhosum
replace v164_v168_lining_rho = . if v164_v168_lining == -99
drop temp_rhosum

* v176_v183
local g_items = 8
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v176-v183), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v176_v183_lining_rho = 1 - temp_rhosum
replace v176_v183_lining_rho = . if v176_v183_lining == -99
drop temp_rhosum

* v189_v193
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v189-v193), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v189_v193_lining_rho = 1 - temp_rhosum
replace v189_v193_lining_rho = . if v189_v193_lining == -99
drop temp_rhosum
 
* v194_v197
local g_items = 4
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v194-v197), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v194_v197_lining_rho = 1 - temp_rhosum
replace v194_v197_lining_rho = . if v194_v197_lining == -99
drop temp_rhosum

* v205_v207
local g_items = 3
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v205-v207), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v205_v207_lining_rho = 1 - temp_rhosum
replace v205_v207_lining_rho = . if v205_v207_lining == -99
drop temp_rhosum

*v221_v224
local g_items = 4
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v221-v224), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v221_v224_lining_rho = 1 - temp_rhosum
replace v221_v224_lining_rho = . if v221_v224_lining == -99
drop temp_rhosum

* 5pt
local g_scale = 5
* v46_v50
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v46-v50), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v46_v50_lining_rho = 1 - temp_rhosum
replace v46_v50_lining_rho = . if v46_v50_lining == -99
drop temp_rhosum

* v72_v79_B
local g_items = 8
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v72_DE v73_DE v74_DE v75_DE v76_DE v77_DE v78_DE v79_DE), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v72_v79_lining_B_rho = 1 - temp_rhosum
replace v72_v79_lining_B_rho = . if v72_v79_lining_B == -99
drop temp_rhosum

* v82_v84
local g_items = 3
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v82-v84), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v82_v84_lining_rho = 1 - temp_rhosum
replace v82_v84_lining_rho = . if v82_v84_lining == -99
drop temp_rhosum

* v199_v203
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v199-v203), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v199_v203_lining_rho = 1 - temp_rhosum
replace v199_v203_lining_rho = . if v199_v203_lining == -99
drop temp_rhosum

* v208_v211
local g_items = 4
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v208-v211), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v208_v211_lining_rho = 1 - temp_rhosum
replace v208_v211_lining_rho = . if v208_v211_lining == -99
drop temp_rhosum

*v212_v216
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v212-v216), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v212_v216_lining_rho = 1 - temp_rhosum
replace v212_v216_lining_rho = . if v212_v216_lining == -99
drop temp_rhosum

*v217-v220
local g_items = 4
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v217-v220), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v217_v220_lining_rho = 1 - temp_rhosum
replace v217_v220_lining_rho = . if v217_v220_lining == -99
drop temp_rhosum

** 10pt
local g_scale = 10
* v103_v107
local g_items = 5
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v103-v107), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v103_v107_lining_rho = 1 - temp_rhosum
replace v103_v107_lining_rho = . if v103_v107_lining == -99
drop temp_rhosum

* v133_v141
local g_items = 9
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v133-v141), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v133_v141_lining_rho = 1 - temp_rhosum
replace v133_v141_lining_rho = . if v133_v141_lining == -99
drop temp_rhosum

*v149_v163
local g_items = 15
gen temp_rhosum = 0
forvalues i = 1 / `g_scale' {
	egen temp_`i'=anycount(v149-v163), v(`i') 
	replace temp_`i'=temp_`i'/`g_items'
	replace temp_rhosum=temp_rhosum+(temp_`i'^2)
	drop temp_`i'
}
gen v149_v163_lining_rho = 1 - temp_rhosum
replace v149_v163_lining_rho = . if v149_v163_lining == -99
drop temp_rhosum

** Rho: all
egen lining_all_rho = rowmean(*_rho)

table survey_mode if filter==1 , c(mean lining_all_rho count lining_all_rho)				
table survey_mode if filter==1 , c(mean lining_all_rho count lining_all_rho)				
		
*-----------------*
* Combined Figure *
*-----------------*

graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

gr combine break_off.gph partial.gph multiple.gph  na.gph dk.gph acquiescence_5.gph middle_all.gph ers_all.gph lining_all_share.gph

graph save  "evs_data_quality.gph", replace
graph export  "evs_data_quality.tif", as(tif) width(2550) replace 
graph export  "evs_data_quality.pdf", as(pdf) replace 

*-------*
* Table *		
*-------*
label variable break_off "Survey break-off rate"
label variable partial "Partial interview rate"
label variable dk_share "Don't know"
label variable na_share "No answer"
label variable multiple_share "Multiple answers mail"
label variable acquiescence_5 "Acquiescence"
label variable middle_all_share "Middle answers"
label variable ers_all_share "Extreme Response Style"
label variable lining_all_share "Straightlining"

tabstat break_off partial , by(survey_mode) stat(mean n) columns(variables)
tabstat dk_share na_share multiple_share acquiescence_5 middle_all_share ers_all_share lining_all_share  if filter==1, by(survey_mode) stat(mean n) columns(variables)
