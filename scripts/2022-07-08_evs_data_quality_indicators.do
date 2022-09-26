*************************************************************************************************************
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*	            Cernat, A., Sakshaug, W., J., Christmann, P & Gummer, T. (2022).                            * 
*  			The Impact of Survey Mode Design and Questionnaire Length on Measurement Quality.               *
*                          	Sociological Methods and Research. 							                    *																								
*			              	                 																*
*							- Estimation of Data Quality Indicators	-							     	    *
*      			                                                 											*			
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*																						 	  				*			
* Authors: 			Cernat, A., Sakshaug, W., J., Christmann, P & Gummer, T.	                     	    *
* Contact: 			pablo.christmann@gesis.org (for questions regarding this syntax file only)				*
* Date: 			July 8, 2022                                                  					   		*
* Software:			Stata 16.1                                                              				*                                                                          
* Datasets:         ZA7500_v3-0-0.dta     																	*
*					ZA7502_v1-0-0.dta                                           		  					*		
*																											*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*************************************************************************************************************

** Note: Some of the combined graphs have been edited manually after estimation to improve its readability.

*** Install required packages
*ssc install TAB_CHI
*ssc install ciplot
*ssc install ipfweight
*ssc install revrs 
*ssc install duncan
*findit grc1leg
*findit esizereg

set more off
clear all

*** Define path
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\"

*cd "\"

*** Graphics
set scheme s1mono
graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

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

*------------------------------------*
* Drop-Break-off cases: Full dataset * 
*------------------------------------*
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

// COUNT no. of item non response (DK + NA)	
egen n_mv=anycount($varlist), v(-1,-2)
ta n_mv

// COUNT no. of NA
egen n_na=anycount($varlist), v(-2)
ta n_na

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

// count share na
gen na_share=(n_na/n_totq)

gen break_off = 0 
replace break_off =1 if  na_share>0.50
tab break_off, m

label variable break_off "Survey break-off"
lab def break_off 1 "Break-off" 0 "No break-off" 
lab val break_off break_off

drop if break_off==1

drop nonmiss n_mv n_na n_notasked n_totq mv_share na_share break_off

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

*---------------------------------------------------*
* Compute post-stratification weights				*
* set all missing to mode of respective variable	*
*---------------------------------------------------* 
gen wei_sex = v225 if v225 > 0
replace wei_sex = 2 if wei_sex == .
gen wei_age = .
replace wei_age = 1 if age >= 18 & age <= 29
replace wei_age = 2 if age >= 30 & age <= 39
replace wei_age = 3 if age >= 40 & age <= 49
replace wei_age = 4 if age >= 50 & age <= 59
replace wei_age = 5 if age >= 60 & age <= 69
replace wei_age = 6 if age >= 70
replace wei_age = 4 if wei_age == .
gen wei_educ = .
replace wei_educ = 1 if v243_ISCED_1 >= 0 & v243_ISCED_1 <=  2
replace wei_educ = 2 if v243_ISCED_1 >= 3 & v243_ISCED_1 <=  4
replace wei_educ = 3 if v243_ISCED_1 >= 5
replace wei_educ = 2 if wei_educ == .
gen wei_hh = .
replace wei_hh = v240 if v240 > 0
replace wei_hh = 5 if wei_hh == 6
replace wei_hh = 2 if wei_hh == .
gen wei_cit = v169 if v169 > 0
replace wei_cit = 1 if wei_cit == .
gen wei_rel = .
replace wei_rel = 1 if v52 == 1
replace wei_rel = 2 if v52 >= 2 & v52 <= 3
replace wei_rel = 3 if v52 >= 4 & v52 <= 9
replace wei_rel = 3 if v52 < 0

ipfweight wei_sex wei_age wei_educ wei_hh wei_cit wei_rel ///
	if survey_mode == 1 , gen(wei_f2f) val( ///
	49.1 50.9 ///
	16.8 15.1 15.5 19.3 14.6 18.8 ///
	18.7 57.0 24.3 ///
	20.9 33.5 18.0 18.5 9.0 ///
	87.9 12.1 ///
	28.6 26.6 44.9) maxit(50) tol(.05) 
ipfweight wei_sex wei_age wei_educ wei_hh wei_cit wei_rel ///
	if survey_mode == 2 , gen(wei_mms) val( ///
	49.1 50.9 ///
	16.8 15.1 15.5 19.3 14.6 18.8 ///
	18.7 57.0 24.3 ///
	20.9 33.5 18.0 18.5 9.0 ///
	87.9 12.1 ///
	28.6 26.6 44.9) maxit(50) tol(.05) 
ipfweight wei_sex wei_age wei_educ wei_hh wei_cit wei_rel ///
	if survey_mode == 3 , gen(wei_mmf) val( ///
	49.1 50.9 ///
	16.8 15.1 15.5 19.3 14.6 18.8 ///
	18.7 57.0 24.3 ///
	20.9 33.5 18.0 18.5 9.0 ///
	87.9 12.1 ///
	28.6 26.6 44.9) maxit(50) tol(.05) 
	
gen weight = wei_f2f
replace weight = wei_mms if survey_mode == 2
replace weight = wei_mmf if survey_mode == 3
sum weight, d
lab var weight "Post-stratification weight, usable for every subsample"

*** Weighted Means and CI
svyset [pw=weight]

**# Varlist Globals
*------------------------------------------------------*
* Set global varlist for NA and DK in analysed scales  *
*------------------------------------------------------*
global varlist	v98 v99 v100 v101																			/// Action 
				v164 v165 v166 v167 v168																	/// Belong
				v267 v268 v269 v270 v271 v272 v273 v274														/// Childhood
				v212 v213 v214 v215 v216																	/// Concern
				v217 v218 v219 v220 																		/// Concern_grp
				v133 v135 v136 v138 v141																	/// Democracy1
				v134 v137 v139 v140																			/// Democracy2
				v176 v177 v178 v179 v180 v181 v182 v183														/// Elections
				v199 v200 v201 v202 v203																	/// Environment 
				v194 v195 v196 v197																			/// European
				v185 v186 v187 v188																			/// Immigration
				v1 v2 v3 v4	v5 v6																			/// Importance
				v65 v66 v67 v68 v69 v70																		/// Marriage
				v189 v190 v191 v192 v193																	/// National 
				v149 v150 v152 v159 v162																	/// Norms1	
				v151 v153 v154 v155 v156 v157 v158 v160 v161 v163 											/// Norms2
				v145 v146 v147 v148																			/// Pol_system
				v208 v209 v210 v211																			/// Pol_watch
				v103 v104 v105 v106 v107																	/// Policy
				v221 v222 v223 v224																			/// Society
				v205 v206 v207																				/// Surveillance
				v82 v83 v84																					/// Traditional_family
				v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 	/// Trust 
				v32 v33 v34 v35 v36 v37																		/// Trust_pl
				v46 v47 v48 v49 v50																			//  Work

*-------------------------------*
* Set global varlist for Scales *
*-------------------------------*
global Action				v98 v99 v100 v101																			
global Belong				v164 v165 v166 v167 v168			
global Childhood			v267 v268 v269 v270 v271 v272 v273 v274			
global Concern				v212 v213 v214 v215 v216										
global Concern_grp			v217 v218 v219 v220 																			
global Democracy1			v133 v135 v136 v138 v141																
global Democracy2			v134 v137 v139 v140																		
global Elections			v176 v177 v178 v179 v180 v181 v182 v183														
global Environment			v199 v200 v201 v202 v203																	
global European				v194 v195 v196 v197																			
global Immigration			v185 v186 v187 v188	
global Importance			v1 v2 v3 v4	v5 v6																		
global Marriage				v65 v66 v67 v68 v69 v70																		
global National				v189 v190 v191 v192 v193																		
global Norms1				v149 v150 v152 v159 v162																	
global Norms2				v151 v153 v154 v155 v156 v157 v158 v160 v161 v163 											
global Pol_system			v145 v146 v147 v148																		
global Pol_watch			v208 v209 v210 v211																		
global Policy				v103 v104 v105 v106 v107																	
global Society				v221 v222 v223 v224																	
global Surveillance			v205 v206 v207																			
global Traditional_family	v82 v83 v84																					
global Trust				v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 	
global Trust_pl				v32 v33 v34 v35 v36 v37																		
global Work					v46 v47 v48 v49 v50															

*---------------------------------------*
* Drop unnecessary variables 			*
*---------------------------------------*
keep $varlist survey_mode weight

*---------------------------------------*
* Save Using Data 				 		*
*---------------------------------------*
save "data/evs_data_quality.dta", replace

*****************************************
*---------------------------------------*
* Analysis#1: Data Quality Indicators	*
*---------------------------------------*
*****************************************

use "data/evs_data_quality.dta", clear

**# Data Quality - Dk/NA
*---------------------------------------*
* No answer and don't know - Item-level * 
*---------------------------------------*				
		
// double check number of variables				
unab vars : $varlist 
di `: word count `vars''   // n = 140

// count number of valid values per respondent
egen nonmiss=rownonmiss($varlist)
ta nonmiss

// COUNT no. of DK
egen n_dk=anycount($varlist), v(-1)
ta n_dk

// COUNT no. of NA
egen n_na=anycount($varlist), v(-2)
ta n_na

// count number of (not)asked questions (thus removing not applicable, not asked and 
// no follow up questions)
* -3 = Not applicable; -4 = question not asked; -9 = no follow up

egen n_notasked=anycount($varlist), v(-3, -4, -9)
ta n_notasked

// count number of asked questions
gen n_totq = 140 - n_notasked
sum n_totq

// count share dk
gen dk_share=(n_dk/n_totq)
*sum n_dk n_totq dk_share if filter==1

// count share na
gen na_share=(n_na/n_totq)
*sum n_na n_totq na_share if filter==1

*--------------------*
* Figures for dk, na *
*--------------------*

svy: mean dk_share , over(survey_mode)
matlist r(table)
matrix dk_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1] \  r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2])
matrix rownames dk_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list dk_share
coefplot (matrix(dk_share[,1]), ci((dk_share[,2] dk_share[,3]))), vertical  title("Don't know (DK)", size(med) margin(medsmall)) subtitle("") note("") saving(figures/dk_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))   xlabel(,labsize(small) angle(45)) ylabel(0 (0.02) 0.1, grid glcolor(gs13) tlwidth(vthin)) legend(off)   

svy: mean na_share , over(survey_mode)
matrix na_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2])
matrix rownames na_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list na_share
coefplot (matrix(na_share[,1]), ci((na_share[,2] na_share[,3]))), vertical ylabel(, grid)  title("No answer (NA)", size(med) margin(medsmall)) subtitle("") note("") saving(figures/na_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45)) ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off) 

*-------------------------*
* No answer - Scale-level * 
*-------------------------*

*** Loop over Globals 
foreach x in  Action Belong Childhood Concern Concern_grp Democracy1 Democracy2 Elections	Environment	European Immigration Importance Marriage National	Norms1	Norms2	Pol_system Pol_watch	Policy	Society Surveillance Traditional_family	Trust Trust_pl Work  {
		
		egen na_`x' = anycount($`x'), values(-2)  
		egen na_`x'_mi = anycount($`x'), values(-3, -4, -9)  
		
		unab vars : $`x'
		di `: word count `vars''
		global N: word count `vars''
		su $`x'
		
		gen n_na_`x' = $N - na_`x'_mi
		gen na_`x'_share = (na_`x'/n_na_`x')	
		*drop  na_`x' na_`x'_mi n_na_`x'
}		

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist na_Action_share na_Belong_share na_Childhood_share na_Concern_share na_Concern_grp_share na_Democracy1_share na_Democracy2_share na_Elections_share	na_Environment_share	na_European_share na_Immigration_share na_Importance_share na_Marriage_share na_National_share	na_Norms1_share	na_Norms2_share	na_Pol_system_share na_Pol_watch_share	na_Policy_share	na_Society_share na_Surveillance_share na_Traditional_family_share	na_Trust_share na_Trust_pl_share na_Work_share {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist na_Action_share na_Belong_share na_Childhood_share na_Concern_share na_Concern_grp_share na_Democracy1_share na_Democracy2_share na_Elections_share	na_Environment_share	na_European_share na_Immigration_share na_Importance_share na_Marriage_share na_National_share	na_Norms1_share	na_Norms2_share	na_Pol_system_share na_Pol_watch_share	na_Policy_share	na_Society_share na_Surveillance_share na_Traditional_family_share	na_Trust_share na_Trust_pl_share na_Work_share {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist na_Action_share na_Belong_share na_Childhood_share na_Concern_share na_Concern_grp_share na_Democracy1_share na_Democracy2_share na_Elections_share	na_Environment_share	na_European_share na_Immigration_share na_Importance_share na_Marriage_share na_National_share	na_Norms1_share	na_Norms2_share	na_Pol_system_share na_Pol_watch_share	na_Policy_share	na_Society_share na_Surveillance_share na_Traditional_family_share	na_Trust_share na_Trust_pl_share na_Work_share {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/na_scale_weighted_v2, replace) title("No answer (NA)", size(medsmall) margin(medsmall)) 

drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long		 
		 
*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen na_scale_share_avg=rmean(na_Action_share na_Belong_share na_Childhood_share na_Concern_share na_Concern_grp_share na_Democracy1_share na_Democracy2_share na_Elections_share	na_Environment_share	na_European_share na_Immigration_share  na_Importance_share na_Marriage_share na_National_share	na_Norms1_share	na_Norms2_share	na_Pol_system_share na_Pol_watch_share	na_Policy_share	na_Society_share na_Surveillance_share na_Traditional_family_share	na_Trust_share na_Trust_pl_share na_Work_share)

*** Weighted Means and CI
svy: mean na_scale_share_avg , over(survey_mode)
matlist r(table)
matrix na_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames na_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list na_scale_share_avg
coefplot (matrix(na_scale_share_avg[,1]), ci((na_scale_share_avg[,2] na_scale_share_avg[,3]))), vertical ylabel(, grid)  title("No answer (NA)", size(med) margin(medsmall)) subtitle("") note("") saving(figures/na_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0 (0.01) 0.05, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*-------------------------*
* Don't know - Scale-level * 
*-------------------------*

*** Loop over Globals 
foreach x in  Action Belong Childhood Concern Concern_grp Democracy1 Democracy2 Elections	Environment	European Immigration Importance Marriage National	Norms1	Norms2	Pol_system Pol_watch	Policy	Society Surveillance Traditional_family	Trust Trust_pl Work  {
		
		egen dk_`x' = anycount($`x'), values(-1)  
		egen dk_`x'_mi = anycount($`x'), values(-3, -4, -9)  
		
		unab vars : $`x'
		di `: word count `vars''
		global N: word count `vars''
		su $`x'
		
		gen n_dk_`x' = $N - dk_`x'_mi
		gen dk_`x'_share = (dk_`x'/n_dk_`x')	
		*drop  na_`x' na_`x'_mi n_na_`x'
}		

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist dk_Action_share dk_Belong_share dk_Childhood_share dk_Concern_share dk_Concern_grp_share dk_Democracy1_share dk_Democracy2_share dk_Elections_share	dk_Environment_share	dk_European_share dk_Immigration_share dk_Importance_share dk_Marriage_share dk_National_share	dk_Norms1_share	dk_Norms2_share	dk_Pol_system_share dk_Pol_watch_share	dk_Policy_share	dk_Society_share dk_Surveillance_share dk_Traditional_family_share	dk_Trust_share dk_Trust_pl_share dk_Work_share {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist dk_Action_share dk_Belong_share dk_Childhood_share dk_Concern_share dk_Concern_grp_share dk_Democracy1_share dk_Democracy2_share dk_Elections_share	dk_Environment_share	dk_European_share dk_Immigration_share dk_Importance_share dk_Marriage_share dk_National_share	dk_Norms1_share	dk_Norms2_share	dk_Pol_system_share dk_Pol_watch_share	dk_Policy_share	dk_Society_share dk_Surveillance_share dk_Traditional_family_share	dk_Trust_share dk_Trust_pl_share dk_Work_share {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist dk_Action_share dk_Belong_share dk_Childhood_share dk_Concern_share dk_Concern_grp_share dk_Democracy1_share dk_Democracy2_share dk_Elections_share	dk_Environment_share	dk_European_share dk_Immigration_share dk_Importance_share dk_Marriage_share dk_National_share	dk_Norms1_share	dk_Norms2_share	dk_Pol_system_share dk_Pol_watch_share	dk_Policy_share	dk_Society_share dk_Surveillance_share dk_Traditional_family_share	dk_Trust_share dk_Trust_pl_share dk_Work_share {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/dk_scale_weighted_v2, replace) title("Don't know (DK)", size(medsmall) margin(medsmall)) 

drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long
			
*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen dk_scale_share_avg=rmean(dk_Action_share dk_Belong_share dk_Childhood_share dk_Concern_share dk_Concern_grp_share dk_Democracy1_share dk_Democracy2_share dk_Elections_share	dk_Environment_share	dk_European_share dk_Immigration_share dk_Importance_share dk_Marriage_share dk_National_share	dk_Norms1_share	dk_Norms2_share	dk_Pol_system_share dk_Pol_watch_share	dk_Policy_share	dk_Society_share dk_Surveillance_share dk_Traditional_family_share	dk_Trust_share dk_Trust_pl_share dk_Work_share)

*** Weighted Means and CI
svy: mean dk_scale_share_avg , over(survey_mode)
matlist r(table)
matrix dk_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames dk_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list dk_scale_share_avg
coefplot (matrix(dk_scale_share_avg[,1]), ci((dk_scale_share_avg[,2] dk_scale_share_avg[,3]))), vertical ylabel(, grid)  title("Don't know (DK)", size(med) margin(medsmall)) subtitle("") note("") saving(figures/dk_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0 (0.02) 0.1, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Middle Answers
*---------------------------------*
* Middle Categories  - Item-level * 
*---------------------------------*

*** 3 Point Scale
// Eligible items with 3pt scale, where ‘2’ is equal to the middle response category.	10 items in 2 scales:
global middle_3  $Action $Marriage
unab vars : $middle_3  
di `: word count `vars''   // n = 10

egen middle_3 = anycount($middle_3), values(2)  
egen middle_3_mi = anycount($middle_3), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_3 = 10 - middle_3_mi

gen middle_3_share = (middle_3/n_middle_3)
*hist middle_3_share

*** 5 Point Scale
// Eligible items with 5pt scale, where ‘3’ is equal to the middle response category.	26 items in 5 scales:

global middle_5 $Concern $Concern_grp $Environment $Pol_watch $Traditional_family $Work
unab vars : $middle_5  
di `: word count `vars''   // n = 26

egen middle_5 = anycount($middle_5), values(3)  
egen middle_5_mi = anycount($middle_5), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_5 = 26 - middle_5_mi

gen middle_5_share = (middle_5/n_middle_5)
*hist middle_5_share

*** 10 Point Scale
// Eligible items with 10pt scale, where 5 to 6 is equal to the middle response category.	33 items in 6 scales:

global middle_10 $Immigration $Norms1 $Norms2 $Policy $Democracy1 $Democracy2
unab vars : $middle_10  
di `: word count `vars''   // n = 33

egen middle_10 = anycount($middle_10), values(5, 6)  
egen middle_10_mi = anycount($middle_10), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_middle_10 = 33 - middle_10_mi

gen middle_10_share = (middle_10/n_middle_10)
*hist middle_10_share

// All Scales
global middle_all $middle_3 $middle_5 $middle_10

unab vars : $middle_all  
di `: word count `vars''   // n = 69

gen middle_all =  middle_3 + middle_5 + middle_10

egen middle_all_mi = anycount($middle_all), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_middle_all = 69 - middle_all_mi

gen middle_all_share = (middle_all/n_middle_all)

// Middle Categories All
ciplot middle_all_share , by(survey_mode) title("Middle answers", size(medlarge) margin(medsmall)) subtitle("") note("") saving(figures/middle_all, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small))  ylabel(0.15 (0.02) 0.25, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*** Weighted Means and CI
svy: mean middle_all_share , over(survey_mode)
matlist r(table)
matrix middle_all_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames middle_all_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list middle_all_share
coefplot (matrix(middle_all_share[,1]), ci((middle_all_share[,2] middle_all_share[,3]))), vertical ylabel(, grid)  title("Middle answers", size(med) margin(medsmall)) subtitle("") note("") saving(figures/middle_all_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.15 (0.02) 0.25, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*---------------------------------*
* Middle Categories - Scale-level * 
*---------------------------------*

*** 3 Point Scale
// Eligible items with 3pt scale, where ‘2’ is equal to the middle response category.	10 items in 2 scales:

* Action
unab vars : $Action  
di `: word count `vars''   // n = 4

egen middle_Action = anycount($Action), values(2)  
egen middle_Action_mi = anycount($Action), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_Action = 4 - middle_Action_mi

gen middle_Action_share = (middle_Action/n_middle_Action)

* Marriage
unab vars : $Marriage  
di `: word count `vars''   // n = 6

egen middle_Marriage = anycount($Marriage), values(2)  
egen middle_Marriage_mi = anycount($Marriage), values(-2, -1, -10, -3, -4, -9)  

gen n_middle_Marriage = 6 - middle_Marriage_mi

gen middle_Marriage_share = (middle_Marriage/n_middle_Marriage)
drop middle_Marriage middle_Marriage_mi n_middle_Marriage


*** 5 Point Scale
// Eligible items with 5pt scale, where ‘3’ is equal to the middle response category. 25 items in 6 scales.
*** Loop over Globals 
foreach x in Concern Concern_grp Environment Pol_watch Traditional_family Work   {
		
		egen middle_`x' = anycount($`x'), values(3)  
		egen middle_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9)  
		
		unab vars : $`x'
		di `: word count `vars''
		global N: word count `vars''
		su $`x'

		gen n_middle_`x' = $N - middle_`x'_mi
		gen middle_`x'_share = (middle_`x'/n_middle_`x')
		drop  middle_`x' middle_`x'_mi n_middle_`x'
}	
	
*** 10 Point Scale
// Eligible items with 10pt scale, where 5 to 6 is equal to the middle response category.	33 items in 6 scales:
*** Loop over Globals 
foreach x in  Democracy1 Democracy2 Immigration Norms1 Norms2 Policy  {
		
		egen middle_`x' = anycount($`x'), values(5, 6)  
		egen middle_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0)  
		
		unab vars : $`x'
		di `: word count `vars''
		global N: word count `vars''
		su $`x'

		gen n_middle_`x' = $N - middle_`x'_mi
		gen middle_`x'_share = (middle_`x'/n_middle_`x')	
		*drop  middle_`x' middle_`x'_mi n_middle_`x'
}		

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist middle_Action_share middle_Concern_share  middle_Concern_grp_share middle_Democracy1_share middle_Democracy2_share middle_Environment_share middle_Immigration_share middle_Marriage_share middle_Norms1_share middle_Norms2_share middle_Pol_watch_share middle_Policy_share middle_Traditional_family_share middle_Work_share       {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist middle_Action_share middle_Concern_share middle_Concern_grp_share middle_Democracy1_share middle_Democracy2_share middle_Environment_share middle_Immigration_share middle_Marriage_share middle_Norms1_share middle_Norms2_share middle_Pol_watch_share middle_Policy_share middle_Traditional_family_share middle_Work_share   {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist middle_Action_share middle_Concern_share middle_Concern_grp_share middle_Democracy1_share middle_Democracy2_share middle_Environment_share middle_Immigration_share middle_Marriage_share middle_Norms1_share middle_Norms2_share middle_Pol_watch_share middle_Policy_share middle_Traditional_family_share middle_Work_share   {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=14
gen item_mm_long = _n+.20 if _n<=14
gen item_mm = _n+.40 if _n<=14
	
mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Action" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Marriage" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
*matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Marriage" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Action" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Marriage" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/middle_scale_weighted_v2, replace) title("Middle answers", size(medsmall) margin(medsmall)) 
		 		 
drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long
	 
*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen middle_scale_share_avg=rmean(middle_Action_share middle_Marriage_share middle_Concern_share middle_Concern_grp_share middle_Environment_share middle_Pol_watch_share middle_Traditional_family_share middle_Work_share middle_Democracy1_share middle_Democracy2_share middle_Immigration_share middle_Norms1_share middle_Norms2_share middle_Policy_share)

*** Weighted Means and CI
svy: mean middle_scale_share_avg , over(survey_mode)
matlist r(table)
matrix middle_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames middle_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list middle_scale_share_avg
coefplot (matrix(middle_scale_share_avg[,1]), ci((middle_scale_share_avg[,2] middle_scale_share_avg[,3]))), vertical ylabel(, grid)  title("Middle answers", size(med) margin(medsmall)) subtitle("") note("") saving(figures/middle_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.15 (0.02) 0.25, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Extreme Response Style
*--------------------------------------*
* Extreme Response Style  - Item-level * 
*--------------------------------------*
*** 5 Point Scale
// Eligible items with 5pt scale, where the lowest response category = ‘1’, and the highest = ‘5’.	26 items in 6 questions:

global ers_5 $Concern $Concern_grp $Environment $Pol_watch $Traditional_family $Work

unab vars : $ers_5  
di `: word count `vars''   // n = 26

egen ers_5 = anycount($ers_5), values(1,5)  
egen ers_5_mi = anycount($ers_5), values(-2, -1, -10, -3, -4, -9)  

gen n_ers_5 = 26 - ers_5_mi

gen ers_5_share = (ers_5/n_ers_5)
*hist ers_5_share

*** 10 Point Scale
// Eligible items with a 10pt scale, where the lowest response category = ‘1’, and the highest = ‘10’.	33 items in 6 questions:

global ers_10  $Immigration $Norms1 $Norms2 $Policy $Democracy1 $Democracy2

unab vars : $ers_10  
di `: word count `vars''   // n = 33

egen ers_10 = anycount($ers_10), values(1, 10)  
egen ers_10_mi = anycount($ers_10), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_ers_10 = 33 - ers_10_mi

gen ers_10_share = (ers_10/n_ers_10)
*hist ers_10_share

// All
global ers_all $Concern $Concern_grp $Environment $Pol_watch $Traditional_family $Work $Immigration $Norms1 $Norms2 $Policy $Democracy1 $Democracy2

unab vars : $ers_all  
di `: word count `vars''   // n = 59

gen ers_all =  ers_5 + ers_10

egen ers_all_mi = anycount($ers_all), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_ers_all = 59 - ers_all_mi

gen ers_all_share = (ers_all/n_ers_all)
*hist ers_all_share

*** Weighted Means and CI
svy: mean ers_all_share , over(survey_mode)
*matlist r(table)
matrix ers_all_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1] \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2]  )
matrix rownames ers_all_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list ers_all_share
coefplot (matrix(ers_all_share[,1]), ci((ers_all_share[,2] ers_all_share[,3]))), vertical ylabel(, grid)  title("Extreme Response Style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/ers_all_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.36 (0.02) 0.46, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*--------------------------------------*
* Extreme Response Style  - Scale-level * 
*--------------------------------------*
*** 5 Point Scale
// Eligible items with 5pt scale, where the lowest response category = ‘1’, and the highest = ‘5’.	26 items in 6 questions:

foreach x in Concern Concern_grp Environment Pol_watch Traditional_family Work   {

	egen ers_`x' = anycount($`x'), values(1,5)  
	egen ers_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_ers_`x' = $N - ers_`x'_mi
	gen ers_`x'_share = (ers_`x'/n_ers_`x')
	drop  ers_`x' ers_`x'_mi n_ers_`x'
}	

*** 10 Point Scale
// Eligible items with a 10pt scale, where the lowest response category = ‘1’, and the highest = ‘10’.	33 items in 6 questions:

foreach x in  Democracy1 Democracy2 Immigration Norms1 Norms2 Policy  {

	egen ers_`x' = anycount($`x'), values(1, 10)  
	egen ers_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_ers_`x' = $N - ers_`x'_mi
	gen ers_`x'_share = (ers_`x'/n_ers_`x')
	drop  ers_`x' ers_`x'_mi n_ers_`x'
}

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist ers_Concern_share ers_Concern_grp_share ers_Democracy1_share ers_Democracy2_share  ers_Environment_share ers_Immigration_share ers_Norms1_share ers_Norms2_share ers_Pol_watch_share ers_Policy_share ers_Traditional_family_share ers_Work_share        {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist ers_Concern_share ers_Concern_grp_share ers_Democracy1_share ers_Democracy2_share  ers_Environment_share ers_Immigration_share ers_Norms1_share ers_Norms2_share ers_Pol_watch_share ers_Policy_share ers_Traditional_family_share ers_Work_share {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist ers_Concern_share ers_Concern_grp_share ers_Democracy1_share ers_Democracy2_share  ers_Environment_share ers_Immigration_share ers_Norms1_share ers_Norms2_share ers_Pol_watch_share ers_Policy_share ers_Traditional_family_share ers_Work_share {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=12
gen item_mm_long = _n+.20 if _n<=12
gen item_mm = _n+.40 if _n<=12

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
*matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Concern" "Concern_grp" "Democracy1" "Democracy2" "Environment" "Immigration" "Norms1" "Norms2" "Pol_watch" "Policy" "Traditional_family" "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/ers_scale_weighted_v2, replace) title("Extreme response style", size(medsmall) margin(medsmall)) 
		 
drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long

*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen ers_scale_share_avg=rmean(ers_Concern_share ers_Concern_grp_share ers_Environment_share ers_Pol_watch_share ers_Traditional_family_share ers_Work_share ers_Democracy1_share ers_Democracy2_share ers_Immigration_share ers_Norms1_share ers_Norms2_share ers_Policy_share)

*** Weighted Means and CI
svy: mean ers_scale_share_avg , over(survey_mode)
matlist r(table)
matrix ers_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames ers_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list ers_scale_share_avg
coefplot (matrix(ers_scale_share_avg[,1]), ci((ers_scale_share_avg[,2] ers_scale_share_avg[,3]))), vertical ylabel(, grid)  title("Extreme response style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/ers_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.36 (0.02) 0.46, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Primacy
*-----------------------*
* Primacy - Item-level  * 
*-----------------------*
*** 3 Point Scale
// Eligible items with 3pt scale,  where the first response category = ‘1’.	10 items in 2 scales:

global pri_3  $Action $Marriage 

unab vars : $pri_3  
di `: word count `vars''   // n = 10

egen pri_3 = anycount($pri_3), values(1)  
egen pri_3_mi = anycount($pri_3), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_pri_3 = 10 - pri_3_mi

gen pri_3_share = (pri_3/n_pri_3)
*hist pri_3_share

*** 4 Point Scale
// Eligible items with 4pt scale,  where the first response category = ‘1’.	71 items in 11 scales:

global pri_4  $Belong  $Childhood $Elections $European $Importance $National $Pol_system $Society $Surveillance $Trust $Trust_pl

unab vars : $pri_4  
di `: word count `vars''   // n = 71

egen pri_4 = anycount($pri_4), values(1)  
egen pri_4_mi = anycount($pri_4), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_pri_4 = 71 - pri_4_mi

gen pri_4_share = (pri_4/n_pri_4)
*hist pri_4_share

*** 5 Point Scale
// Eligible items with 5pt scale, where the first response category = ‘1’.	26 items in 6 scales:

global pri_5 $Concern $Concern_grp $Environment $Pol_watch $Traditional_family $Work

unab vars : $pri_5  
di `: word count `vars''   // n = 26

egen pri_5 = anycount($pri_5), values(1)  
egen pri_5_mi = anycount($pri_5), values(-2, -1, -10, -3, -4, -9)  

gen n_pri_5 = 26 - pri_5_mi

gen pri_5_share = (pri_5/n_pri_5)
*hist pri_5_share

*** 10 Point Scale
// Eligible items with a 10pt scale, where the first response category = ‘1’.	33 items in 6 scales:

global pri_10  $Immigration $Norms1 $Norms2 $Policy $Democracy1 $Democracy2

unab vars : $pri_10  
di `: word count `vars''   // n = 33

egen pri_10 = anycount($pri_10), values(1)  
egen pri_10_mi = anycount($pri_10), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_pri_10 = 33 - pri_10_mi

gen pri_10_share = (pri_10/n_pri_10)
hist pri_10_share

// All
global pri_all $pri_3 $pri_4 $pri_5 $pri_10

unab vars : $pri_all  
di `: word count `vars''   // n = 140

gen pri_all =  pri_3 + pri_4 + pri_5 + pri_10

egen pri_all_mi = anycount($pri_all), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_pri_all = 140 - pri_all_mi

gen pri_all_share = (pri_all/n_pri_all)
hist pri_all_share

*** Weighted Means and CI
svy: mean pri_all_share , over(survey_mode)
*matlist r(table)
matrix pri_all_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1] \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2]  )
matrix rownames pri_all_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list pri_all_share
coefplot (matrix(pri_all_share[,1]), ci((pri_all_share[,2] pri_all_share[,3]))), vertical ylabel(, grid)  title("Primacy response style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/pri_all_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.20 (0.02) 0.30, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*------------------------*
* Primacy  - Scale-level * 
*------------------------*
*** 3 Point Scale
// Eligible items with 3pt scale,  where the first response category = ‘1’.	10 items in 2 scales:

foreach x in Action Marriage {

	egen pri_`x' = anycount($`x'), values(1)  
	egen pri_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_pri_`x' = $N - pri_`x'_mi
	gen pri_`x'_share = (pri_`x'/n_pri_`x')
	drop pri_`x' pri_`x'_mi n_pri_`x'
}

*** 4 Point Scale
// Eligible items with 4pt scale,  where the first response category = ‘1’.	71 items in 11 scales:

foreach x in Belong Childhood Elections European Importance National Pol_system Society Surveillance Trust Trust_pl {

	egen pri_`x' = anycount($`x'), values(1)  
	egen pri_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_pri_`x' = $N - pri_`x'_mi
	gen pri_`x'_share = (pri_`x'/n_pri_`x')
	drop pri_`x' pri_`x'_mi n_pri_`x'
}

*** 5 Point Scale
// Eligible items with 5pt scale, where the first response category = ‘1’.	26 items in 6 scales:

foreach x in Concern Concern_grp Environment Pol_watch Traditional_family Work   {

	egen pri_`x' = anycount($`x'), values(1)  
	egen pri_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_pri_`x' = $N - pri_`x'_mi
	gen pri_`x'_share = (pri_`x'/n_pri_`x')
	drop  pri_`x' pri_`x'_mi n_pri_`x'
}	

*** 10 Point Scale
// Eligible items with a 10pt scale, where the first response category = ‘1’.	33 items in 6 scales:

foreach x in Democracy1 Democracy2 Immigration Norms1 Norms2 Policy  {

	egen pri_`x' = anycount($`x'), values(1)  
	egen pri_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_pri_`x' = $N - pri_`x'_mi
	gen pri_`x'_share = (pri_`x'/n_pri_`x')
	drop pri_`x' pri_`x'_mi n_pri_`x'
}

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist pri_Action_share pri_Belong_share pri_Childhood_share pri_Concern_share pri_Concern_grp_share pri_Democracy1_share pri_Democracy2_share pri_Elections_share	pri_Environment_share	pri_European_share pri_Immigration_share pri_Importance_share pri_Marriage_share pri_National_share	pri_Norms1_share	pri_Norms2_share	pri_Pol_system_share pri_Pol_watch_share	pri_Policy_share	pri_Society_share pri_Surveillance_share pri_Traditional_family_share	pri_Trust_share pri_Trust_pl_share pri_Work_share {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist pri_Action_share pri_Belong_share pri_Childhood_share pri_Concern_share pri_Concern_grp_share pri_Democracy1_share pri_Democracy2_share pri_Elections_share	pri_Environment_share	pri_European_share pri_Immigration_share pri_Importance_share pri_Marriage_share pri_National_share	pri_Norms1_share	pri_Norms2_share	pri_Pol_system_share pri_Pol_watch_share	pri_Policy_share	pri_Society_share pri_Surveillance_share pri_Traditional_family_share	pri_Trust_share pri_Trust_pl_share pri_Work_share {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist pri_Action_share pri_Belong_share pri_Childhood_share pri_Concern_share pri_Concern_grp_share pri_Democracy1_share pri_Democracy2_share pri_Elections_share	pri_Environment_share	pri_European_share pri_Immigration_share pri_Importance_share pri_Marriage_share pri_National_share	pri_Norms1_share	pri_Norms2_share	pri_Pol_system_share pri_Pol_watch_share	pri_Policy_share	pri_Society_share pri_Surveillance_share pri_Traditional_family_share	pri_Trust_share pri_Trust_pl_share pri_Work_share {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f = "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"  
*matrix list f2f

mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work" 
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm = "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/pri_scale_weighted_v2, replace) title("Primacy response style", size(medsmall) margin(medsmall)) 
		 
drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long

*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen pri_scale_share_avg=rmean(pri_Action_share pri_Belong_share pri_Childhood_share pri_Concern_share pri_Concern_grp_share pri_Democracy1_share pri_Democracy2_share pri_Elections_share	pri_Environment_share	pri_European_share pri_Immigration_share pri_Importance_share pri_Marriage_share pri_National_share	pri_Norms1_share	pri_Norms2_share	pri_Pol_system_share pri_Pol_watch_share	pri_Policy_share	pri_Society_share pri_Surveillance_share pri_Traditional_family_share	pri_Trust_share pri_Trust_pl_share pri_Work_share)

*** Weighted Means and CI
svy: mean pri_scale_share_avg , over(survey_mode)
matlist r(table)
matrix pri_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames pri_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list pri_scale_share_avg
coefplot (matrix(pri_scale_share_avg[,1]), ci((pri_scale_share_avg[,2] pri_scale_share_avg[,3]))), vertical ylabel(, grid)  title("Primacy response style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/pri_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.20 (0.02) 0.30, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Recency
*-----------------------*
* Recency  - Item-level * 
*-----------------------*
*** 3 Point Scale
// Eligible items with 3pt scale,  where the last response category = ‘3’.	10 items in 2 scales:

global rec_3  $Action $Marriage 

unab vars : $rec_3  
di `: word count `vars''   // n = 10

egen rec_3 = anycount($rec_3), values(3)  
egen rec_3_mi = anycount($rec_3), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_rec_3 = 10 - rec_3_mi

gen rec_3_share = (rec_3/n_rec_3)
*hist rec_3_share

*** 4 Point Scale
// Eligible items with 4pt scale,  where the last response category = ‘4’.	71 items in 11 scales:

global rec_4  $Belong  $Childhood $Elections $European $Importance $National $Pol_system $Society $Surveillance $Trust $Trust_pl

unab vars : $rec_4  
di `: word count `vars''   // n = 71

egen rec_4 = anycount($rec_4), values(4)  
egen rec_4_mi = anycount($rec_4), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_rec_4 = 71 - rec_4_mi

gen rec_4_share = (rec_4/n_rec_4)
*hist rec_4_share

*** 5 Point Scale
// Eligible items with 5pt scale, where the last response category = ‘5’.	26 items in 6 questions:

global rec_5 $Concern $Concern_grp $Environment $Pol_watch $Traditional_family $Work

unab vars : $rec_5  
di `: word count `vars''   // n = 26

egen rec_5 = anycount($rec_5), values(5)  
egen rec_5_mi = anycount($rec_5), values(-2, -1, -10, -3, -4, -9)  

gen n_rec_5 = 26 - rec_5_mi

gen rec_5_share = (rec_5/n_rec_5)
*hist rec_5_share

*** 10 Point Scale
// Eligible items with a 10pt scale, where the last response category = ‘10’.	33 items in 6 questions:

global rec_10  $Immigration $Norms1 $Norms2 $Policy $Democracy1 $Democracy2

unab vars : $rec_10  
di `: word count `vars''   // n = 33

egen rec_10 = anycount($rec_10), values(10)  
egen rec_10_mi = anycount($rec_10), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_rec_10 = 33 - rec_10_mi

gen rec_10_share = (rec_10/n_rec_10)
*hist rec_10_share

// All
global rec_all $rec_3 $rec_4 $rec_5 $rec_10 

unab vars : $rec_all  
di `: word count `vars''   // n = 140

gen rec_all =  rec_3 + rec_4 + rec_5 + rec_10

egen rec_all_mi = anycount($rec_all), values(-2, -1, -10, -3, -4, -9, 0)  

gen n_rec_all = 140 - rec_all_mi

gen rec_all_share = (rec_all/n_rec_all)
*hist rec_all_share

*** Weighted Means and CI
svy: mean rec_all_share , over(survey_mode)
*matlist r(table)
matrix rec_all_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1] \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2]  )
matrix rownames rec_all_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list rec_all_share
coefplot (matrix(rec_all_share[,1]), ci((rec_all_share[,2] rec_all_share[,3]))), vertical ylabel(, grid)  title("Recency Response Style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/rec_all_weighted, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.12 (0.02) 0.22, grid glcolor(gs13) tlwidth(vthin)) legend(off)

*------------------------*
* Recency  - Scale-level * 
*------------------------*
*** 3 Point Scale
// Eligible items with 3pt scale,  where the last response category = ‘3’.	10 items in 2 scales:

foreach x in Action Marriage {

	egen rec_`x' = anycount($`x'), values(3)  
	egen rec_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_rec_`x' = $N - rec_`x'_mi
	gen rec_`x'_share = (rec_`x'/n_rec_`x')
	drop rec_`x' rec_`x'_mi n_rec_`x'
}

*** 4 Point Scale
// Eligible items with 4pt scale,  where the last response category = ‘4’.	71 items in 11 scales:

foreach x in Belong Childhood Elections European Importance National Pol_system Society Surveillance Trust Trust_pl {

	egen rec_`x' = anycount($`x'), values(4)  
	egen rec_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_rec_`x' = $N - rec_`x'_mi
	gen rec_`x'_share = (rec_`x'/n_rec_`x')
	drop rec_`x' rec_`x'_mi n_rec_`x'
}

*** 5 Point Scale
// Eligible items with 5pt scale, where the last response category = ‘5’.	26 items in 6 questions::

foreach x in Concern Concern_grp Environment Pol_watch Traditional_family Work   {

	egen rec_`x' = anycount($`x'), values(5)  
	egen rec_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_rec_`x' = $N - rec_`x'_mi
	gen rec_`x'_share = (rec_`x'/n_rec_`x')
	drop rec_`x' rec_`x'_mi n_rec_`x'
}	

*** 10 Point Scale
// Eligible items with a 10pt scale, where the last response category = ‘10’.	33 items in 6 questions:

foreach x in Democracy1 Democracy2 Immigration Norms1 Norms2 Policy  {

	egen rec_`x' = anycount($`x'), values(10)  
	egen rec_`x'_mi = anycount($`x'), values(-2, -1, -10, -3, -4, -9, 0) 
	
	unab vars : $`x'
	di `: word count `vars''
	global N: word count `vars''
	su $`x'

	gen n_rec_`x' = $N - rec_`x'_mi
	gen rec_`x'_share = (rec_`x'/n_rec_`x')
	drop rec_`x' rec_`x'_mi n_rec_`x'
}

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.

 * loop over all items for F2F
local i = 1
foreach var of varlist rec_Action_share rec_Belong_share rec_Childhood_share rec_Concern_share rec_Concern_grp_share rec_Democracy1_share rec_Democracy2_share rec_Elections_share	rec_Environment_share	rec_European_share rec_Immigration_share rec_Importance_share rec_Marriage_share rec_National_share	rec_Norms1_share	rec_Norms2_share	rec_Pol_system_share rec_Pol_watch_share	rec_Policy_share	rec_Society_share rec_Surveillance_share rec_Traditional_family_share	rec_Trust_share rec_Trust_pl_share rec_Work_share {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist rec_Action_share rec_Belong_share rec_Childhood_share rec_Concern_share rec_Concern_grp_share rec_Democracy1_share rec_Democracy2_share rec_Elections_share	rec_Environment_share	rec_European_share rec_Immigration_share rec_Importance_share rec_Marriage_share rec_National_share	rec_Norms1_share	rec_Norms2_share	rec_Pol_system_share rec_Pol_watch_share	rec_Policy_share	rec_Society_share rec_Surveillance_share rec_Traditional_family_share	rec_Trust_share rec_Trust_pl_share rec_Work_share {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist rec_Action_share rec_Belong_share rec_Childhood_share rec_Concern_share rec_Concern_grp_share rec_Democracy1_share rec_Democracy2_share rec_Elections_share	rec_Environment_share	rec_European_share rec_Immigration_share rec_Importance_share rec_Marriage_share rec_National_share	rec_Norms1_share	rec_Norms2_share	rec_Pol_system_share rec_Pol_watch_share	rec_Policy_share	rec_Society_share rec_Surveillance_share rec_Traditional_family_share	rec_Trust_share rec_Trust_pl_share rec_Work_share {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
         
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f = "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"  
*matrix list f2f

mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work" 
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm = "Action"  "Belong"  "Childhood"  "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work" 
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/rec_scale_weighted_v2, replace) title("Recency response style", size(medsmall) margin(medsmall)) 
		 
drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long

*** Plot results at Scale-Level as average over all scales	 
// Exclude missings from calculation
egen rec_scale_share_avg=rmean(rec_Action_share rec_Belong_share rec_Childhood_share rec_Concern_share rec_Concern_grp_share rec_Democracy1_share rec_Democracy2_share rec_Elections_share	rec_Environment_share	rec_European_share rec_Immigration_share rec_Importance_share rec_Marriage_share rec_National_share	rec_Norms1_share	rec_Norms2_share	rec_Pol_system_share rec_Pol_watch_share	rec_Policy_share	rec_Society_share rec_Surveillance_share rec_Traditional_family_share	rec_Trust_share rec_Trust_pl_share rec_Work_share)

*** Weighted Means and CI
svy: mean rec_scale_share_avg , over(survey_mode)
matlist r(table)
matrix rec_scale_share_avg = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames rec_scale_share_avg = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list rec_scale_share_avg
coefplot (matrix(rec_scale_share_avg[,1]), ci((rec_scale_share_avg[,2] rec_scale_share_avg[,3]))), vertical ylabel(, grid)  title("Recency response style", size(med) margin(medsmall)) subtitle("") note("") saving(figures/rec_scale_share_avg, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.12 (0.02) 0.22, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Straightlining
*------------------------------*
* Straightlining : Scale-level * 
*------------------------------*

egen Action_lining = diff(v98 v99 v100 v101) if (v98>-1 & v99>-1 &  v100>-1 &  v101>-1)
recode Action_lining (0=1) (1=0)

egen Belong_lining = diff(v164 v165 v166 v167 v168) if (v164>-1 & v165>-1 &  v166>-1 &  v167>-1 &  v168>-1)
recode Belong_lining (0=1) (1=0)

egen Childhood_lining = diff(v267 v268 v269 v270 v271 v272 v273 v274) if (v267>-1 & v268>-1 &  v269>-1 & v270>-1 & v271>-1 &  v272>-1 &  v273>-1 &  v274>-1)
recode Childhood_lining (0=1) (1=0)

egen Concern_lining = diff(v212 v213 v214 v215 v216) if (v212>-1 & v213>-1 & v214>-1 & v215>-1 & v216>-1)
recode Concern_lining (0=1) (1=0)

egen Concern_grp_lining = diff(v217 v218 v219 v220) if (v217>-1 & v218>-1 & v219>-1 & v220>-1)
recode Concern_grp_lining (0=1) (1=0)

egen Democracy1_lining = diff(v133 v135 v136 v138 v141) if (v133>-1 & v135>-1 &  v136>-1 & v138>-1 &  v141>-1)
recode Democracy1_lining (0=1) (1=0)

egen Democracy2_lining = diff(v134 v137 v139 v140) if (v134>-1 & v137>-1 &  v139>-1 & v140>-1)
recode Democracy2_lining (0=1) (1=0)

egen Elections_lining = diff(v176 v177 v178 v179 v180 v181 v182 v183) if (v176>-1 & v177>-1 &  v178>-1 &  v179>-1 &  v180>-1  &  v181>-1  &  v182>-1  &  v183>-1) 
recode Elections_lining (0=1) (1=0)

egen Environment_lining = diff(v199 v200 v201 v202 v203) if (v199>-1 & v200>-1 &  v201>-1 &  v202>-1  &  v203>-1 ) 
recode Environment_lining (0=1) (1=0)

egen European_lining = diff(v194 v195 v196 v197) if (v194>-1 & v195>-1 &  v196>-1 &  v197>-1 ) 
recode European_lining (0=1) (1=0)

egen Immigration_lining = diff(v185 v186 v187 v188) if (v185>-1 & v186>-1 &  v187>-1 &  v188>-1 ) 
recode Immigration_lining (0=1) (1=0)

egen Importance_lining = diff(v1 v2 v3 v4 v5 v6) if (v1>-1 & v2>-1 &  v3>-1 &  v4>-1 &  v5>-1 &  v6>-1) 
recode Importance_lining (0=1) (1=0)

egen Marriage_lining = diff(v65 v66 v67 v68 v69 v70) if (v65>-1 & v66>-1 &  v67>-1 &  v68>-1 &  v69>-1 &  v70>-1 ) 
recode Marriage_lining (0=1) (1=0)

egen National_lining = diff(v189 v190 v191 v192 v193) if (v189>-1 & v190>-1 & v191>-1 &  v192>-1 &  v193>-1)
recode National_lining (0=1) (1=0)

egen Norms1_lining = diff(v149 v150 v152 v159 v162) if (v149>-1 & v150>-1 &  v152>-1 &  v159>-1 &  v162>-1)
recode Norms1_lining (0=1) (1=0)

egen Norms2_lining = diff(v151 v153 v154 v155 v156 v157 v158 v160 v161 v163) if (v151>-1 & v153>-1 &  v154>-1 &  v155>-1 &  v156>-1 & v157>-1 & v158>-1 &  v160>-1 &  v161>-1 &  v163>-1)
recode Norms2_lining (0=1) (1=0)

egen Pol_system_lining = diff(v145 v146 v147 v148) if (v145>-1 & v146>-1 &  v147>-1 &  v148>-1) 
recode Pol_system_lining (0=1) (1=0)

egen Pol_watch_lining = diff(v208 v209 v210 v211) if (v208>-1 & v209>-1 &  v210>-1 &  v211>-1  )
recode Pol_watch_lining (0=1) (1=0)

egen Policy_lining = diff(v103 v104 v105 v106 v107) if (v103>-1 & v104>-1 &  v105>-1 &  v106>-1 & v107>-1) 
recode Policy_lining (0=1) (1=0)

egen Society_lining = diff(v221 v222 v223 v224) if (v221>-1 & v222>-1 &  v223>-1 &  v224>-1) 
recode Society_lining (0=1) (1=0)

egen Surveillance_lining = diff(v205 v206 v207) if (v205>-1 & v206>-1 &  v207>-1) 
recode Surveillance_lining (0=1) (1=0)

egen Traditional_family_lining = diff(v82 v83 v84) if (v82>-1 & v83>-1 &  v84>-1)
recode Traditional_family_lining (0=1) (1=0)

egen Trust_lining = diff(v115-v132) if (v115>-1 & v116>-1 &  v117>-1 &  v118>-1 & v119>-1 & v120>-1 & v121>-1 & v122>-1 & v123>-1 & v124>-1 & v125>-1 & v126>-1 & v127>-1 & v128>-1 & v129>-1 & v130>-1 & v131>-1 & v132>-1)  
recode Trust_lining (0=1) (1=0)

egen Trust_pl_lining = diff(v32-v37) if (v32>-1 & v33>-1 &  v34>-1 &  v35>-1 & v36>-1 & v37>-1)
recode Trust_pl_lining (0=1) (1=0)

egen Work_lining = diff(v46 v47 v48 v49 v50) if (v46>-1 & v47>-1 &  v48>-1 &  v49>-1 & v50>-1) 
recode Work_lining (0=1) (1=0)

*** Plot results at Scale-Level by each scale
* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.


 * loop over all items for F2F
local i = 1
foreach var of varlist Action_lining Belong_lining Childhood_lining Concern_lining Concern_grp_lining Democracy1_lining Democracy2_lining Elections_lining Environment_lining European_lining Immigration_lining Importance_lining Marriage_lining National_lining Norms1_lining Norms2_lining Pol_system_lining Pol_watch_lining Policy_lining Society_lining Surveillance_lining Traditional_family_lining Trust_lining Trust_pl_lining Work_lining {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist Action_lining Belong_lining Childhood_lining Concern_lining Concern_grp_lining Democracy1_lining Democracy2_lining Elections_lining Environment_lining European_lining Immigration_lining Importance_lining Marriage_lining National_lining Norms1_lining Norms2_lining Pol_system_lining Pol_watch_lining Policy_lining Society_lining Surveillance_lining Traditional_family_lining Trust_lining Trust_pl_lining Work_lining  {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist Action_lining Belong_lining Childhood_lining Concern_lining Concern_grp_lining Democracy1_lining Democracy2_lining Elections_lining Environment_lining European_lining Immigration_lining Importance_lining Marriage_lining National_lining Norms1_lining Norms2_lining Pol_system_lining Pol_watch_lining Policy_lining Society_lining Surveillance_lining Traditional_family_lining Trust_lining Trust_pl_lining Work_lining  {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
 replace lower_mm_long = 0 in 23 // no variation in Trust_lining
 replace upper_mm_long = 0 in 23 // no variation in Trust_lining
 
* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Action" "Belong" "Childhood" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Elections" "Environment" "European" "Immigration" "Importance" "Marriage" "National" "Norms1" "Norms2"  "Pol_system" "Pol_watch" "Policy" "Society" "Surveillance" "Traditional_family" "Trust" "Trust_pl" "Work" 
matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action" "Belong" "Childhood" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Elections" "Environment" "European" "Immigration" "Importance" "Marriage" "National" "Norms1" "Norms2"  "Pol_system" "Pol_watch" "Policy" "Society" "Surveillance" "Traditional_family" "Trust" "Trust_pl" "Work"  
matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Action" "Belong" "Childhood" "Concern" "Concern_grp" "Democracy1" "Democracy2" "Elections" "Environment" "European" "Immigration" "Importance" "Marriage" "National" "Norms1" "Norms2"  "Pol_system" "Pol_watch" "Policy" "Society" "Surveillance" "Traditional_family" "Trust" "Trust_pl" "Work" 
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/Straightlining_scale_weighted_v2, replace) title("Straightlining", size(medsmall) margin(medsmall)) 
		 		 		 
drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long

*** Plot results at Scale-Level as average over all scales	 

recode Action_lining (.=-99) 
recode Belong_lining  (.=-99) 
recode Childhood_lining (.=-99)
recode Concern_lining (.=-99)
recode Concern_grp_lining (.=-99)
recode Democracy1_lining (.=-99)
recode Democracy2_lining (.=-99)
recode Elections_lining (.=-99)
recode Environment_lining (.=-99)
recode European_lining (.=-99)
recode Immigration_lining (.=-99)
recode Importance_lining (.=-99)
recode Marriage_lining (.=-99)
recode National_lining (.=-99)
recode Norms1_lining (.=-99)
recode Norms2_lining (.=-99)
recode Pol_system_lining (.=-99)
recode Pol_watch_lining (.=-99)
recode Policy_lining (.=-99)
recode Society_lining (.=-99)
recode Surveillance_lining (.=-99)
recode Traditional_family_lining (.=-99)
recode Trust_lining (.=-99)
recode Trust_pl_lining (.=-99)
recode Work_lining (.=-99)

egen count_lining_all = anycount(Action_lining Belong_lining Childhood_lining Concern_lining Concern_grp_lining Democracy1_lining Democracy2_lining Elections_lining Environment_lining European_lining Immigration_lining Importance_lining Marriage_lining National_lining Norms1_lining Norms2_lining Pol_system_lining Pol_watch_lining Policy_lining Society_lining Surveillance_lining Traditional_family_lining Trust_lining Trust_pl_lining Work_lining),values(1)

egen lining_missing_all = anycount(Action_lining Belong_lining Childhood_lining Concern_lining Concern_grp_lining Democracy1_lining Democracy2_lining Elections_lining Environment_lining European_lining Immigration_lining Importance_lining Marriage_lining National_lining Norms1_lining Norms2_lining Pol_system_lining Pol_watch_lining Policy_lining Society_lining Surveillance_lining Traditional_family_lining Trust_lining Trust_pl_lining Work_lining), values(-99)

gen N_valid_items_lining_all = 25 - lining_missing_all

gen lining_all_share =  count_lining_all / N_valid_items_lining_all

*** Weighted Means and CI
svy: mean lining_all_share , over(survey_mode)
matlist r(table)
matrix lining_all_share = (r(table)[1,1], r(table)[5,1], r(table)[6,1]  \ r(table)[1,3], r(table)[5,3], r(table)[6,3] \ r(table)[1,2], r(table)[5,2], r(table)[6,2] )
matrix rownames lining_all_share = "Face-to-Face" "Mixed-Mode Long" "Mixed-Mode Matrix" 
matrix list lining_all_share
coefplot (matrix(lining_all_share[,1]), ci((lining_all_share[,2] lining_all_share[,3]))), vertical ylabel(, grid)  title("Straightlining", size(med) margin(medsmall)) subtitle("") note("") saving(figures/straightlining_scale_share_avg.gph, replace) xtitle("") ytitle("", size(medsmall)) yscale(titlegap(*+10)) mcolor(black) mfcolor(black) msymbol(smdiamond) ysize(4) xsize(4)  plotregion(margin(0 0 0 0))  xlabel(,labsize(small) angle(45))  ylabel(0.08 (0.02) 0.18, grid glcolor(gs13) tlwidth(vthin)) legend(off)

**# Data Quality Plots
*-----------------*
* Combined Figure *
*-----------------*
graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

*-------------------*
* At the item-level *
*-------------------*
*Revised Graph
gr combine na_weighted.gph dk_weighted.gph pri_all_weighted.gph rec_all_weighted.gph ers_all_weighted.gph middle_all_weighted.gph 
graph save  "RR_data_quality_item_weighted.gph", replace
graph export  "RR_data_quality_item_weighted.tif", as(tif) width(2550) replace 
graph export  "RR_data_quality_item_weighted.pdf", as(pdf) replace 

*-----------------------------*
* At the scale-level - Average*
*-----------------------------*
gr combine na_scale_share_avg.gph dk_scale_share_avg.gph pri_scale_share_avg.gph rec_scale_share_avg.gph ers_scale_share_avg.gph  middle_scale_share_avg.gph straightlining_scale_share_avg.gph 
/*RR: Edited labels and margins manually for better presentation
graph save  "RR_data_quality_scale_weighted_avg.gph", replace
graph export  "RR_data_quality_scale_weighted_avg.tif", as(tif) width(2550) replace 
graph export  "RR_data_quality_scale_weighted_avg.pdf", as(pdf) replace
*/

**# Comparison of Means, SD and Cohens'D - Item-Level
*****************************************************
*---------------------------------------------------*
* Analysis#2: Comparison of Means, SD and Cohens'D	*
*---------------------------------------------------*
*****************************************************

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\
use "data/evs_data_quality.dta", clear

* Comparison between Face-to-Face and Mixed-Mode Long
gen mixed_mode_full = .
replace mixed_mode_full = 1 if survey_mode ==1
replace mixed_mode_full = 2 if survey_mode ==3
tab mixed_mode_full survey_mode, m

label define mixed_mode_full 1 "Face-to-Face" 2 "Mi-Mo Full" 
label values mixed_mode_full mixed_mode_full

* Comparison between Mixed-Mode Long and Mixed-Mode Matrix
gen mixed_mode = .
replace mixed_mode = 1 if survey_mode ==2
replace mixed_mode = 2 if survey_mode ==3
tab mixed_mode survey_mode, m

*** Keep only necessary variables 
keep survey_mode $varlist weight mixed_mode_full mixed_mode

*-----------------
* Recode Missings 
*-----------------
tabm $varlist, m
mvdecode $varlist	, mv(-10=. \ -9=. \-6=. \-4=. \-2=. \-3=. \-1=.\0=.)
mvdecode v267 v268 v269 v270 v271 v272 v273	v274 , mv(6=.)  // Face-to-Face: 6. does not apply to me (spontaneous) 

*---------------
* Reverse Scale 
*---------------
revrs v1 v2 v3 v4 v5 v6 v32 v33 v34 v35 v36 v37 v46 v47 v48 v49 v50 v65 v66 v67 v68 v69 v70   v82 v83 v84 v98 v99 v100 v101  v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v147 v145 v146 v148 v164 v165 v166 v167 v168  v176 v177 v178 v179 v180 v181 v182 v183  v189 v190  v191 v192 v193 v194 v195 v196 v197  v199 v200 v201 v202 v203 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v267 v268 v269 v270 v271 v272 v273 v274

drop v1 v2 v3 v4 v5 v6 v32 v33 v34 v35 v36 v37 v46 v47 v48 v49 v50 v65 v66 v67 v68 v69 v70   v82 v83 v84 v98 v99 v100 v101 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v147 v145 v146 v148 v164 v165 v166 v167 v168 v176 v177 v178 v179 v180 v181 v182 v183  v189 v190 v191 v192 v193 v194 v195 v196 v197  v199 v200 v201 v202 v203 v205 v206 v207 v208 v209 v210 v211  v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v267 v268 v269 v270 v271 v272 v273 v274

foreach X of varlist  v103 v104 v105 v106 v107 v133 v134 v135 v136 v137 v138 v139 v140 v141  v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v185 v186 v187 v188 {
rename `X' rev`X'
}
*----------------------------
* Bring order to the Dataset 
*----------------------------
order  survey_mode weight mixed_mode_full mixed_mode revv1 revv2 revv3 revv4 revv5 revv6 revv32 revv33	revv34	revv35	revv36	revv37	revv46	revv47	revv48	revv49	revv50	revv65	revv66	revv67	revv68	revv69	revv70	revv82	revv83	revv84	revv98	revv99	revv100	revv101	revv103	revv104	revv105	revv106	revv107	revv115	revv116	revv117	revv118	revv119	revv120	revv121	revv122	revv123	revv124	revv125	revv126	revv127	revv128	revv129	revv130	revv131	revv132	revv133	revv134	revv135	revv136	revv137	revv138	revv139	revv140	revv141	revv145	revv146	revv147	revv148	revv149	revv150	revv151	revv152	revv153	revv154	revv155	revv156	revv157	revv158	revv159	revv160	revv161	revv162	revv163	revv164	revv165	revv166	revv167	revv168 revv176	revv177	revv178	revv179	revv180	revv181	revv182	revv183	revv185	revv186	revv187	revv188	revv189	revv190 revv191	revv192	revv193	revv194	revv195	revv196	revv197	revv199	revv200	revv201	revv202	revv203	revv205	revv206	revv207	revv208	revv209	revv210	revv211	revv212 revv213 revv214 revv215 revv216 revv217	revv218	revv219 revv220	revv221	revv222	revv223	revv224	revv267	revv268	revv269	revv270 revv271	revv272	revv273 revv274

*----------------
* Rescale Var 
*-----------------
foreach var of varlist revv1-revv274 {
         norm `var' , method(mmx)
              }	

global varlist_mmx_rev mmx_revv1-mmx_revv274			  
unab vars : $varlist_mmx_rev 
di `: word count `vars''   // n = 140

*-----------------------
* Save temorary dataset 
*-----------------------		
		
save "data\evs_temp.dta", replace
	
*-------------------------------------
* Analysis: Face-to-Face vs MM Full 
*-------------------------------------

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "Data\evs_temp.dta", clear

keep if survey_mode == 1 | survey_mode ==3

*** Rescaled variables
gen var_name =""
gen means_f2f = .
gen std_f2f = .
gen N_f2f = . 
gen means_mm = .
gen std_mm =.
gen N_mm = . 
gen means_ttest = .
gen means_p = .
gen variance_ratio =.
gen sdtest_p =.
gen cohen=.

//matlist r(table)		 
//return list	

 * loop over all items for F2F - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			ds `var' 
			replace var_name =  "`r(varlist)'" in `i' 
			local i = `i' + 1
		         }
	 
 * loop over all items for F2F - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' if mixed_mode_full==1
			replace means_f2f = (r(table)[1,1]) in `i'
			replace N_f2f = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_f2f = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }

* loop over all items for Mixed-Mode Long - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' if mixed_mode_full==2
			replace means_mm = (r(table)[1,1]) in `i'
			replace N_mm = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_mm = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }	
		
* t-test with survey weighted data
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' , over(mixed_mode_full) coeflegend
			lincom _b[c.`var'@1bn.mixed_mode_full] - _b[c.`var'@2.mixed_mode_full]
			replace means_ttest = `r(t)' in `i'	
			replace means_p = `r(p)' in `i'
			local i = `i' + 1
}			

* Cohen's D with survey weighted data
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			regress `var' i.mixed_mode_full [aw=weight] // aw is identical to pw for point estimates
			esizereg 2.mixed_mode_full
			replace cohen = `r(d)' in `i'
			local i = `i' + 1
			}

local i = 1			
foreach var of varlist mmx_revv1-mmx_revv274 {		
			local N_f2f=N_f2f in `i'
			local means_f2f=means_f2f in `i'
			local std_f2f=std_f2f in `i'
			local N_mm=N_mm in `i'
			local means_mm=means_mm in `i'
			local std_mm=std_mm in `i'
			sdtesti  `N_f2f' `means_f2f' `std_f2f' `N_mm' `means_mm' `std_mm' 
			replace variance_ratio = `r(F)' in `i'		
			replace sdtest_p = `r(p)' in `i'	
			local i = `i' + 1
	}	
	
*** Generate Dummies for Significant Tests
gen means_sig = .
replace means_sig = 1 if means_p <0.05 & means_p~=.
replace means_sig = 0 if means_p >=0.05 & means_p~=.

gen sdtest_sig = .
replace sdtest_sig = 1 if sdtest_p <0.05 & sdtest_p~=.
replace sdtest_sig = 0 if sdtest_p >=0.05 & sdtest_p~=.

*** Apply Bonferroni Correction
unab vars : $varlist_mmx_rev
di `: word count `vars''

gen means_p_Bonferroni = means_p*140
replace means_p_Bonferroni = 1 if means_p_Bonferroni>1 & means_p_Bonferroni~=.

gen means_sig_Bonferroni = .
replace means_sig_Bonferroni = 1 if means_p_Bonferroni <0.05 & means_p_Bonferroni~=.
replace means_sig_Bonferroni = 0 if means_p_Bonferroni >=0.05 & means_p_Bonferroni~=.

gen sdtest_p_Bonferroni = sdtest_p*140
replace sdtest_p_Bonferroni = 1 if sdtest_p_Bonferroni>1 & sdtest_p_Bonferroni~=.

gen sdtest_sig_Bonferroni = .
replace sdtest_sig_Bonferroni = 1 if sdtest_p_Bonferroni <0.05 & sdtest_p_Bonferroni~=.
replace sdtest_sig_Bonferroni = 0 if sdtest_p_Bonferroni >=0.05 & sdtest_p_Bonferroni~=.

*-------------------------------------
* Scatter Plot for all rescaled means  
*-------------------------------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

hist cohen , scheme(s2mono) freq legend(off) plotr(m(zero)) xlabel(-1(0.1)1) ytitle("Frequency", height(6)) xtitle("Cohen's d: Face-to-Face and Mi-Mo Long", height(6)) bin(20)
graph save  "Cohen_Full_weighted.gph", replace
graph export "Cohen_Full_weighted.tif", as(tif) width(2550) replace 

** Bonferroni Correction
twoway (scatter means_f2f means_mm if means_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter means_f2f means_mm if means_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 1) n(2) lcolor(black) lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("Means: Face-to-Face", height(6)) xtitle("Means: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "Means_Full_Bonferroni_weighted.gph", replace
graph export "Means_Full_Bonferroni_weighted.tif", as(tif) width(2550) replace 
 
twoway (scatter std_f2f std_mm if sdtest_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter std_f2f std_mm if sdtest_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 0.5) n(2) lcolor(black)lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("SD: Face-to-Face", height(6)) xtitle("SD: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "SD_Full_Bonferroni_weighted.gph", replace
graph export "SD_Full_Bonferroni_weighted.tif", as(tif) width(2550) replace 
 
*-----------------------------------
* Analysis: MM Matrix vs MM Long
*-------------------------------------

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "Data\evs_temp.dta", clear 
	
keep if mixed_mode == 1 | mixed_mode ==2 
drop mixed_mode_full
rename mixed_mode mixed_mode_full

*** Rescaled variables
gen var_name =""
gen means_f2f = .
gen std_f2f = .
gen N_f2f = . 
gen means_mm = .
gen std_mm =.
gen N_mm = . 
gen means_ttest = .
gen means_p = .
gen variance_ratio =.
gen sdtest_p =.
gen cohen=.

 * loop over all items for F2F - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			ds `var' 
			replace var_name =  "`r(varlist)'" in `i' 
			local i = `i' + 1
		         }

 * loop over all items for Mi-Mo Matrix - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' if mixed_mode_full==1
			replace means_f2f = (r(table)[1,1]) in `i'
			replace N_f2f = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_f2f = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode Long - Means and N
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' if mixed_mode_full==2
			replace means_mm = (r(table)[1,1]) in `i'
			replace N_mm = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_mm = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }	
		
* t-test with survey weighted data
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			svy: mean `var' , over(mixed_mode_full) coeflegend
			lincom _b[c.`var'@1bn.mixed_mode_full] - _b[c.`var'@2.mixed_mode_full]
			replace means_ttest = `r(t)' in `i'	
			replace means_p = `r(p)' in `i'
			local i = `i' + 1
}			

* Cohen's D with survey weighted data
local i = 1
foreach var of varlist mmx_revv1-mmx_revv274 {
			regress `var' i.mixed_mode_full [aw=weight] // aw is identical to pw for point estimates
			esizereg 2.mixed_mode_full
			replace cohen = `r(d)' in `i'
			local i = `i' + 1
			}

local i = 1			
foreach var of varlist mmx_revv1-mmx_revv274 {		
			local N_f2f=N_f2f in `i'
			local means_f2f=means_f2f in `i'
			local std_f2f=std_f2f in `i'
			local N_mm=N_mm in `i'
			local means_mm=means_mm in `i'
			local std_mm=std_mm in `i'
			sdtesti  `N_f2f' `means_f2f' `std_f2f' `N_mm' `means_mm' `std_mm' 
			replace variance_ratio = `r(F)' in `i'		
			replace sdtest_p = `r(p)' in `i'	
			local i = `i' + 1
	}	
	
*** Generate Dummies for Significant Tests
gen means_sig = .
replace means_sig = 1 if means_p <0.05 & means_p~=.
replace means_sig = 0 if means_p >=0.05 & means_p~=.

gen sdtest_sig = .
replace sdtest_sig = 1 if sdtest_p <0.05 & sdtest_p~=.
replace sdtest_sig = 0 if sdtest_p >=0.05 & sdtest_p~=.

*** Apply Bonferroni Correction
unab vars : $varlist_mmx_rev
di `: word count `vars''

gen means_p_Bonferroni = means_p*140
replace means_p_Bonferroni = 1 if means_p_Bonferroni>1 & means_p_Bonferroni~=.

gen means_sig_Bonferroni = .
replace means_sig_Bonferroni = 1 if means_p_Bonferroni <0.05 & means_p_Bonferroni~=.
replace means_sig_Bonferroni = 0 if means_p_Bonferroni >=0.05 & means_p_Bonferroni~=.

gen sdtest_p_Bonferroni = sdtest_p*140
replace sdtest_p_Bonferroni = 1 if sdtest_p_Bonferroni>1 & sdtest_p_Bonferroni~=.

gen sdtest_sig_Bonferroni = .
replace sdtest_sig_Bonferroni = 1 if sdtest_p_Bonferroni <0.05 & sdtest_p_Bonferroni~=.
replace sdtest_sig_Bonferroni = 0 if sdtest_p_Bonferroni >=0.05 & sdtest_p_Bonferroni~=.

*-------------------------------------
* Scatter Plot for all rescaled means  
*-------------------------------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

hist cohen , scheme(s2mono) freq legend(off) plotr(m(zero)) xlabel(-1(0.1)1) ytitle("Frequency", height(6)) xtitle("Cohen's d: Mi-Mo Matrix and Mi-Mo Long", height(6)) bin(20)
graph save  "Cohen_Matrix_weighted.gph", replace
graph export "Cohen_Matrix_weighted.tif", as(tif) width(2550) replace 

** Bonferroni Correction
twoway (scatter means_f2f means_mm if means_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter means_f2f means_mm if means_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 1) n(2) lcolor(black) lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("Means: Mi-Mo Matrix", height(6)) xtitle("Means: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "Means_Matrix_Bonferroni_weighted.gph", replace
graph export "Means_Matrix_Bonferroni_weighted.tif", as(tif) width(2550) replace 
 
twoway (scatter std_f2f std_mm if sdtest_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter std_f2f std_mm if sdtest_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 0.5) n(2) lcolor(black)lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("SD: Mi-Mo Matrix", height(6)) xtitle("SD: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "SD_Matrix_Bonferroni_weighted.gph", replace
graph export "SD_Matrix_Bonferroni_weighted.tif", as(tif) width(2550) replace 
  
*---------------
* Graph combine  
*---------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\Figures"

gr combine Means_Full_Bonferroni_weighted.gph Means_Matrix_Bonferroni_weighted.gph SD_Full_Bonferroni_weighted.gph SD_Matrix_Bonferroni_weighted.gph Cohen_Full_weighted.gph Cohen_Matrix_weighted.gph, rows(3)

/*RR: Edited labels and margins manually for better presentation
graph save  "Means_SD_Cohen_Bonferroni_weighted.gph", replace
graph export  "Means_SD_Cohen_Bonferroni_weighted.tif", as(tif) width(2550) replace 
graph export  "Means_SD_Cohen_Bonferroni_weighted.pdf", as(pdf) replace 
*/

**# Comparison of Means, SD and Cohens'D - Scale-Level
*********************************************************************
*-------------------------------------------------------------------*
* Analysis#2: Comparison of Means, SD and Cohens'D - Scale-Level	*
*-------------------------------------------------------------------*
*********************************************************************

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\
use "data/evs_data_quality.dta", clear

* Comparison between Face-to-Face and Mixed-Mode Long
gen mixed_mode_full = .
replace mixed_mode_full = 1 if survey_mode ==1
replace mixed_mode_full = 2 if survey_mode ==3
tab mixed_mode_full survey_mode, m

label define mixed_mode_full 1 "Face-to-Face" 2 "Mi-Mo Full" 
label values mixed_mode_full mixed_mode_full

* Comparison between Mixed-Mode Long and Mixed-Mode Matrix
gen mixed_mode = .
replace mixed_mode = 1 if survey_mode ==2
replace mixed_mode = 2 if survey_mode ==3
tab mixed_mode survey_mode, m

*** Keep only necessary variables 
keep survey_mode $varlist weight mixed_mode_full mixed_mode

*-----------------
* Recode Missings 
*-----------------
tabm $varlist, m
mvdecode $varlist	, mv(-10=. \ -9=. \-6=. \-4=. \-2=. \-3=. \-1=.\0=.)
mvdecode v267 v268 v269 v270 v271 v272 v273	v274 , mv(6=.)  // Face-to-Face: 6. does not apply to me (spontaneous) 

*---------------
* Reverse Scale 
*---------------
revrs v1 v2 v3 v4 v5 v6 v32 v33 v34 v35 v36 v37 v46 v47 v48 v49 v50 v65 v66 v67 v68 v69 v70   v82 v83 v84 v98 v99 v100 v101  v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v147 v145 v146 v148 v164 v165 v166 v167 v168  v176 v177 v178 v179 v180 v181 v182 v183  v189 v190  v191 v192 v193 v194 v195 v196 v197  v199 v200 v201 v202 v203 v205 v206 v207 v208 v209 v210 v211 v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v267 v268 v269 v270 v271 v272 v273 v274

drop v1 v2 v3 v4 v5 v6 v32 v33 v34 v35 v36 v37 v46 v47 v48 v49 v50 v65 v66 v67 v68 v69 v70   v82 v83 v84 v98 v99 v100 v101 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v147 v145 v146 v148 v164 v165 v166 v167 v168 v176 v177 v178 v179 v180 v181 v182 v183  v189 v190 v191 v192 v193 v194 v195 v196 v197  v199 v200 v201 v202 v203 v205 v206 v207 v208 v209 v210 v211  v212 v213 v214 v215 v216 v217 v218 v219 v220 v221 v222 v223 v224 v267 v268 v269 v270 v271 v272 v273 v274

foreach X of varlist  v103 v104 v105 v106 v107 v133 v134 v135 v136 v137 v138 v139 v140 v141  v149 v150 v151 v152 v153 v154 v155 v156 v157 v158 v159 v160 v161 v162 v163 v185 v186 v187 v188 {
rename `X' rev`X'
}

*----------------------------
* Bring order to the Dataset 
*----------------------------
order  survey_mode weight mixed_mode_full mixed_mode revv1 revv2 revv3 revv4 revv5 revv6 revv32 revv33	revv34	revv35	revv36	revv37	revv46	revv47	revv48	revv49	revv50	revv65	revv66	revv67	revv68	revv69	revv70	revv82	revv83	revv84	revv98	revv99	revv100	revv101	revv103	revv104	revv105	revv106	revv107	revv115	revv116	revv117	revv118	revv119	revv120	revv121	revv122	revv123	revv124	revv125	revv126	revv127	revv128	revv129	revv130	revv131	revv132	revv133	revv134	revv135	revv136	revv137	revv138	revv139	revv140	revv141	revv145	revv146	revv147	revv148	revv149	revv150	revv151	revv152	revv153	revv154	revv155	revv156	revv157	revv158	revv159	revv160	revv161	revv162	revv163	revv164	revv165	revv166	revv167	revv168 revv176	revv177	revv178	revv179	revv180	revv181	revv182	revv183	revv185	revv186	revv187	revv188	revv189	revv190 revv191	revv192	revv193	revv194	revv195	revv196	revv197	revv199	revv200	revv201	revv202	revv203	revv205	revv206	revv207	revv208	revv209	revv210	revv211	revv212 revv213 revv214 revv215 revv216 revv217	revv218	revv219 revv220	revv221	revv222	revv223	revv224	revv267	revv268	revv269	revv270 revv271	revv272	revv273 revv274

egen Action_avg		=		rmean(revv98 revv99 revv100 revv101)															
egen Belong_avg		=		rmean(revv164 revv165 revv166 revv167 revv168)			
egen Childhood_avg		=	rmean(revv267 revv268 revv269 revv270 revv271 revv272 revv273 revv274)	
egen Concern_avg	=		rmean(revv212 revv213 revv214 revv215 revv216)		
egen Concern_grp_avg	=	rmean(revv217 revv218 revv219 revv220)																
egen Democracy1_avg		=	rmean(revv133 revv135 revv136 revv138 revv141)															
egen Democracy2_avg		=	rmean(revv134 revv137 revv139 revv140)																	
egen Elections_avg		=	rmean(revv176 revv177 revv178 revv179 revv180 revv181 revv182 revv183)												
egen Environment_avg	=	rmean(revv199 revv200 revv201 revv202 revv203)													
egen European_avg		=	rmean(revv194 revv195 revv196 revv197)													
egen Immigration_avg	=	rmean(revv185 revv186 revv187 revv188)	
egen Importance_avg		=	rmean(revv1 revv2 revv3 revv4	revv5 revv6)																
egen Marriage_avg		=	rmean(revv65 revv66 revv67 revv68 revv69 revv70)																	
egen National_avg		=	rmean(revv189 revv190 revv191 revv192 revv193)																	
egen Norms1_avg			=	rmean(revv149 revv150 revv152 revv159 revv162)		
egen Norms2_avg			=	rmean(revv151 revv153 revv154 revv155 revv156 revv157 revv158 revv160 revv161 revv163)										
egen Pol_system_avg		=	rmean(revv145 revv146 revv147 revv148)																
egen Pol_watch_avg		=	rmean(revv208 revv209 revv210 revv211)				
egen Policy_avg			=	rmean(revv103 revv104 revv105 revv106 revv107)														
egen Society_avg		=	rmean(revv221 revv222 revv223 revv224)															
egen Surveillance_avg	=	rmean(revv205 revv206 revv207)															
egen Traditional_family_avg	= rmean(revv82 revv83 revv84)					
egen Trust_avg			=	rmean(revv115 revv116 revv117 revv118 revv119 revv120 revv121 revv122 revv123 revv124 revv125 revv126 revv127 revv128 revv129 revv130 revv131 revv132) 	
egen Trust_pl_avg		=	rmean(revv32 revv33 revv34 revv35 revv36 revv37)																
egen Work_avg			=	rmean(revv46 revv47 revv48 revv49 revv50)
													
*----------------
* Rescale Var 
*-----------------
foreach var of varlist Action_avg-Work_avg {
         norm `var' , method(mmx)
              }	

global varlist_mmx_rev mmx_Action_avg-mmx_Work_avg			  
			  
*-----------------------
* Save temorary dataset 
*-----------------------		
		
save "data\evs_temp_scale.dta", replace

*-------------------------------------
* Analysis: Face-to-Face vs MM Full 
*-------------------------------------

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "Data\evs_temp_scale.dta", clear

keep if survey_mode == 1 | survey_mode ==3

*** Rescaled variables
gen means_f2f = .
gen std_f2f = .
gen N_f2f = . 
gen means_mm = .
gen std_mm =.
gen N_mm = . 
gen means_ttest = .
gen means_p = .
gen variance_ratio =.
gen sdtest_p =.
gen cohen=.

//matlist r(table)		 
//return list	

 * loop over all items for F2F - Means and N
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' if mixed_mode_full==1
			replace means_f2f = (r(table)[1,1]) in `i'
			replace N_f2f = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_f2f = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }

* loop over all items for Mixed-Mode Long - Means and N
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' if mixed_mode_full==2
			replace means_mm = (r(table)[1,1]) in `i'
			replace N_mm = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_mm = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }	
		
* t-test with survey weighted data
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' , over(mixed_mode_full) coeflegend
			lincom _b[c.`var'@1bn.mixed_mode_full] - _b[c.`var'@2.mixed_mode_full]
			replace means_ttest = `r(t)' in `i'	
			replace means_p = `r(p)' in `i'
			local i = `i' + 1
}			

* Cohen's D with survey weighted data
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			regress `var' i.mixed_mode_full [aw=weight] // aw is identical to pw for point estimates
			esizereg 2.mixed_mode_full
			replace cohen = `r(d)' in `i'
			local i = `i' + 1
			}

local i = 1			
foreach var of varlist mmx_Action_avg-mmx_Work_avg {		
			local N_f2f=N_f2f in `i'
			local means_f2f=means_f2f in `i'
			local std_f2f=std_f2f in `i'
			local N_mm=N_mm in `i'
			local means_mm=means_mm in `i'
			local std_mm=std_mm in `i'
			sdtesti  `N_f2f' `means_f2f' `std_f2f' `N_mm' `means_mm' `std_mm' 
			replace variance_ratio = `r(F)' in `i'		
			replace sdtest_p = `r(p)' in `i'	
			local i = `i' + 1
	}	
	
*** Generate Dummies for Significant Tests
gen means_sig = .
replace means_sig = 1 if means_p <0.05 & means_p~=.
replace means_sig = 0 if means_p >=0.05 & means_p~=.

gen sdtest_sig = .
replace sdtest_sig = 1 if sdtest_p <0.05 & sdtest_p~=.
replace sdtest_sig = 0 if sdtest_p >=0.05 & sdtest_p~=.

*** Apply Bonferroni Correction
unab vars : $varlist_mmx_rev
di `: word count `vars''

gen means_p_Bonferroni = means_p*25
replace means_p_Bonferroni = 1 if means_p_Bonferroni>1 & means_p_Bonferroni~=.

gen means_sig_Bonferroni = .
replace means_sig_Bonferroni = 1 if means_p_Bonferroni <0.05 & means_p_Bonferroni~=.
replace means_sig_Bonferroni = 0 if means_p_Bonferroni >=0.05 & means_p_Bonferroni~=.

gen sdtest_p_Bonferroni = sdtest_p*25
replace sdtest_p_Bonferroni = 1 if sdtest_p_Bonferroni>1 & sdtest_p_Bonferroni~=.

gen sdtest_sig_Bonferroni = .
replace sdtest_sig_Bonferroni = 1 if sdtest_p_Bonferroni <0.05 & sdtest_p_Bonferroni~=.
replace sdtest_sig_Bonferroni = 0 if sdtest_p_Bonferroni >=0.05 & sdtest_p_Bonferroni~=.

*-------------------------------------
* Scatter Plot for all rescaled means  
*-------------------------------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

hist cohen , scheme(s2mono) freq legend(off) plotr(m(zero)) xlabel(-1(0.1)1) ytitle("Frequency", height(6)) xtitle("Cohen's d: Face-to-Face and Mi-Mo Long", height(6)) bin(20)
graph save  "Cohen_Full_scale_weighted.gph", replace
graph export "Cohen_Full_scale__weighted.tif", as(tif) width(2550) replace 

** Bonferroni Correction
twoway (scatter means_f2f means_mm if means_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter means_f2f means_mm if means_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 1) n(2) lcolor(black) lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("Means: Face-to-Face", height(6)) xtitle("Means: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "Means_Full_scale_Bonferroni_weighted.gph", replace
graph export "Means_Full_scale_Bonferroni_weighted.tif", as(tif) width(2550) replace 
 
twoway (scatter std_f2f std_mm if sdtest_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter std_f2f std_mm if sdtest_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 0.5) n(2) lcolor(black)lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("SD: Face-to-Face", height(6)) xtitle("SD: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "SD_Full_scale_Bonferroni_weighted.gph", replace
graph export "SD_Full_scale_Bonferroni_weighted.tif", as(tif) width(2550) replace 

*-------------------------------------
* Analysis: MM Matrix vs MM Full 
*-------------------------------------

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "Data\evs_temp_scale.dta", clear

keep if mixed_mode == 1 | mixed_mode ==2 
drop mixed_mode_full
rename mixed_mode mixed_mode_full

*** Rescaled variables
gen means_f2f = .
gen std_f2f = .
gen N_f2f = . 
gen means_mm = .
gen std_mm =.
gen N_mm = . 
gen means_ttest = .
gen means_p = .
gen variance_ratio =.
gen sdtest_p =.
gen cohen=.

//matlist r(table)		 
//return list	

 * loop over all items for F2F - Means and N
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' if mixed_mode_full==1
			replace means_f2f = (r(table)[1,1]) in `i'
			replace N_f2f = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_f2f = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }

* loop over all items for Mixed-Mode Long - Means and N
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' if mixed_mode_full==2
			replace means_mm = (r(table)[1,1]) in `i'
			replace N_mm = (r(table)[7,1]) + 1 in `i'
			estat sd
			replace std_mm = (r(sd)[1,1]) in `i'
			local i = `i' + 1
         }	
		
* t-test with survey weighted data
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			svy: mean `var' , over(mixed_mode_full) coeflegend
			lincom _b[c.`var'@1bn.mixed_mode_full] - _b[c.`var'@2.mixed_mode_full]
			replace means_ttest = `r(t)' in `i'	
			replace means_p = `r(p)' in `i'
			local i = `i' + 1
}			

* Cohen's D with survey weighted data
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
			regress `var' i.mixed_mode_full [aw=weight] // aw is identical to pw for point estimates
			esizereg 2.mixed_mode_full
			replace cohen = `r(d)' in `i'
			local i = `i' + 1
			}

local i = 1			
foreach var of varlist mmx_Action_avg-mmx_Work_avg {		
			local N_f2f=N_f2f in `i'
			local means_f2f=means_f2f in `i'
			local std_f2f=std_f2f in `i'
			local N_mm=N_mm in `i'
			local means_mm=means_mm in `i'
			local std_mm=std_mm in `i'
			sdtesti  `N_f2f' `means_f2f' `std_f2f' `N_mm' `means_mm' `std_mm' 
			replace variance_ratio = `r(F)' in `i'		
			replace sdtest_p = `r(p)' in `i'	
			local i = `i' + 1
	}	
	
*** Generate Dummies for Significant Tests
gen means_sig = .
replace means_sig = 1 if means_p <0.05 & means_p~=.
replace means_sig = 0 if means_p >=0.05 & means_p~=.

gen sdtest_sig = .
replace sdtest_sig = 1 if sdtest_p <0.05 & sdtest_p~=.
replace sdtest_sig = 0 if sdtest_p >=0.05 & sdtest_p~=.

*** Apply Bonferroni Correction
unab vars : $varlist_mmx_rev
di `: word count `vars''

gen means_p_Bonferroni = means_p*25
replace means_p_Bonferroni = 1 if means_p_Bonferroni>1 & means_p_Bonferroni~=.

gen means_sig_Bonferroni = .
replace means_sig_Bonferroni = 1 if means_p_Bonferroni <0.05 & means_p_Bonferroni~=.
replace means_sig_Bonferroni = 0 if means_p_Bonferroni >=0.05 & means_p_Bonferroni~=.

gen sdtest_p_Bonferroni = sdtest_p*25
replace sdtest_p_Bonferroni = 1 if sdtest_p_Bonferroni>1 & sdtest_p_Bonferroni~=.

gen sdtest_sig_Bonferroni = .
replace sdtest_sig_Bonferroni = 1 if sdtest_p_Bonferroni <0.05 & sdtest_p_Bonferroni~=.
replace sdtest_sig_Bonferroni = 0 if sdtest_p_Bonferroni >=0.05 & sdtest_p_Bonferroni~=.

*-------------------------------------
* Scatter Plot for all rescaled means  
*-------------------------------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\figures"

hist cohen , scheme(s2mono) freq legend(off) plotr(m(zero)) xlabel(-1(0.1)1) ytitle("Frequency", height(6)) xtitle("Cohen's d: Face-to-Face and Mi-Mo Long", height(6)) bin(20)
graph save  "Cohen_Matrix_scale_weighted.gph", replace
graph export "Cohen_Matrix_scale__weighted.tif", as(tif) width(2550) replace 

** Bonferroni Correction
twoway (scatter means_f2f means_mm if means_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter means_f2f means_mm if means_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 1) n(2) lcolor(black) lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("Means: Mi-Mo Matrix", height(6)) xtitle("Means: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "Means_Matrix_scale_Bonferroni_weighted.gph", replace
graph export "Means_Matrix_scale_Bonferroni_weighted.tif", as(tif) width(2550) replace 
 
twoway (scatter std_f2f std_mm if sdtest_sig_Bonferroni==0, msymbol(0) msize(medsmall) mfcolor(white) mcolor(black)) (scatter std_f2f std_mm if sdtest_sig_Bonferroni==1, msymbol(0) msize(medsmall) mcolor(black)) (function x, range(0 0.5) n(2) lcolor(black)lstyle(solid)) , legend(off) plotr(m(zero)) ytitle("SD: Mi-Mo Matrix", height(6)) xtitle("SD: Mi-Mo Long", height(6)) scheme(s2mono)
graph save  "SD_Matrix_scale_Bonferroni_weighted.gph", replace
graph export "SD_Matrix_scale_Bonferroni_weighted.tif", as(tif) width(2550) replace 

*-------------------------------------------
* Plot Means at Scale-Level by each scale 
*------------------------------------------

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "Data\evs_temp_scale.dta", clear

* generate variables to fill (F2F, Web, Mail)
gen means_f2f = .
gen lower_f2f =.
gen upper_f2f=.

gen means_mm = .
gen lower_mm =.
gen upper_mm=.

gen means_mm_long = .
gen lower_mm_long =.
gen upper_mm_long=.


 * loop over all items for F2F
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg {
         svy: mean `var' if survey_mode==1
         replace means_f2f =  (r(table)[1,1]) in `i'
         replace lower_f2f = (r(table)[5,1]) in `i'
         replace upper_f2f = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }

* loop over all items for Mixed-Mode Matrix
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg  {
        svy: mean `var' if survey_mode==2
         replace means_mm = (r(table)[1,1]) in `i'
         replace lower_mm = (r(table)[5,1]) in `i'
         replace upper_mm = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }
		 
* loop over all items for Mixed-Mode long
local i = 1
foreach var of varlist mmx_Action_avg-mmx_Work_avg  {
         svy: mean `var' if survey_mode==3
         replace means_mm_long = (r(table)[1,1]) in `i'
         replace lower_mm_long = (r(table)[5,1]) in `i'
         replace upper_mm_long = (r(table)[6,1]) in `i'
         local i = `i' + 1
         }


* generate x-axis (slightly dodge so that dots don't overlap)     
gen item_f2f = _n if _n<=25
gen item_mm_long = _n+.20 if _n<=25
gen item_mm = _n+.40 if _n<=25

mkmat means_f2f lower_f2f upper_f2f, matrix(f2f) nomissing
matrix coln f2f = means lower upper
matrix rown f2f =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list f2f
	
mkmat means_mm_long lower_mm_long upper_mm_long, matrix(mm_long) nomissing
matrix coln mm_long = means lower upper
matrix rown mm_long =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
*matrix list mm_long
	
mkmat means_mm lower_mm upper_mm, matrix(mm) nomissing
matrix coln mm = means lower upper
matrix rown mm =  "Action"  "Belong"  "Childhood" "Concern" "Concern_grp"  "Democracy1"  "Democracy2"  "Elections"  "Environment"  "European"  "Immigration" "Importance" "Marriage"  "National"  "Norms1"  "Norms2"  "Pol_system"  "Pol_watch"  "Policy"  "Society" "Surveillance"  "Traditional_family" "Trust"  "Trust_pl"  "Work"
matrix list mm
	
coefplot (matrix(f2f[,1]), ci((2 3)) msymbol(o)  mcolor(gs0)  mfcolor(gs0) label(Face-to-face)) (matrix(mm_long[,1]), ci((2 3)) msymbol(d) mcolor(gs12)  mfcolor(gs12) label(Mi-Mo Long)) (matrix(mm[,1]), ci((2 3))  msymbol(s) mcolor(gs7)  mfcolor(gs7) label(Mi-Mo Matrix)) , ytitle(, size(medsmall))  ysize(4) xsize(4)  xlabel(,labsize(small))  ylabel(, labsize(small) glcolor(gs13) tlwidth(vthin))  legend(rows(1) size(small)) saving(figures/scale_average_v2, replace) title("Scale Averages", size(medsmall) margin(medsmall)) 

drop means_f2f lower_f2f upper_f2f means_mm lower_mm upper_mm means_mm_long lower_mm_long upper_mm_long item_f2f item_mm item_mm_long

*---------------
* Graph combine  
*---------------
cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\Figures"

*-------------------*
* At the scale-level *
*-------------------*

*Revised
grc1leg  scale_average_v2.gph na_scale_weighted_v2.gph dk_scale_weighted_v2.gph pri_scale_weighted_v2.gph rec_scale_weighted_v2.gph ers_scale_weighted_v2.gph middle_scale_weighted_v2.gph Straightlining_scale_weighted_v2.gph, legendfrom(na_scale_weighted_v2.gph)
/*Formatting adapted manually (Label sizes)
graph save  "RR_data_quality_avg_scale_weighted_v2.gph", replace
graph export  "RR_data_quality_avg_scale_weighted_v2.tif", as(tif) width(2550) replace 
graph export  "RR_data_quality_avg_scale_weighted_v2.pdf", as(pdf) replace
*/

gr combine Means_Full_scale_Bonferroni_weighted.gph Means_Matrix_scale_Bonferroni_weighted.gph SD_Full_scale_Bonferroni_weighted.gph SD_Matrix_scale_Bonferroni_weighted.gph Cohen_Full_scale_weighted.gph Cohen_Matrix_scale_weighted.gph, rows(3)
/*Formatting adapted manually (Label sizes)
graph save  "scale_means_sd_cohen_bonferroni_weighted_average.gph", replace
graph export  "scale_means_sd_cohen_bonferroni_weighted_average.tif", as(tif) width(2550) replace 
graph export  "scale_means_sd_cohen_bonferroni_weighted_average.pdf", as(pdf) replace 
*/

*-------------------------------------------------------------------------
* Appendix: Table of unstandardised item means, sd and %-highest category
*-------------------------------------------------------------------------
** Note: Please inspect data editor for the aggregated information following these estimations.

cd "J:\Work\Team_SuSy\Publikationen\EVS Paper 10_Measurement Equivalence\

use "data/evs_data_quality.dta", clear

*ssc install mtab

keep $varlist survey_mode weight

**# Varlist Globals
*------------------------------------------------------*
* Set global varlist for NA and DK in analysed scales  *
*------------------------------------------------------*
global varlist	v98 v99 v100 v101																			/// Action 
				v164 v165 v166 v167 v168																	/// Belong
				v267 v268 v269 v270 v271 v272 v273 v274														/// Childhood
				v212 v213 v214 v215 v216																	/// Concern
				v217 v218 v219 v220 																		/// Concern_grp
				v133 v135 v136 v138 v141																	/// Democracy1
				v134 v137 v139 v140																			/// Democracy2
				v176 v177 v178 v179 v180 v181 v182 v183														/// Elections
				v199 v200 v201 v202 v203																	/// Environment 
				v194 v195 v196 v197																			/// European
				v185 v186 v187 v188																			/// Immigration
				v1 v2 v3 v4	v5 v6																			/// Importance
				v65 v66 v67 v68 v69 v70																		/// Marriage
				v189 v190 v191 v192 v193																	/// National 
				v149 v150 v152 v159 v162																	/// Norms1	
				v151 v153 v154 v155 v156 v157 v158 v160 v161 v163 											/// Norms2
				v145 v146 v147 v148																			/// Pol_system
				v208 v209 v210 v211																			/// Pol_watch
				v103 v104 v105 v106 v107																	/// Policy
				v221 v222 v223 v224																			/// Society
				v205 v206 v207																				/// Surveillance
				v82 v83 v84																					/// Traditional_family
				v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 	/// Trust 
				v32 v33 v34 v35 v36 v37																		/// Trust_pl
				v46 v47 v48 v49 v50																			//  Work

*-----------------
* Recode Missings 
*-----------------
tabm $varlist, m
mvdecode $varlist	, mv(-10=. \ -9=. \-6=. \-4=. \-2=. \-3=. \-1=.\0=.)
mvdecode v267 v268 v269 v270 v271 v272 v273	v274 , mv(6=.)  // Face-to-Face: 6. does not apply to me (spontaneous) 

*** Means and SD of original variables
gen var_name=""
local i = 1
foreach var of varlist v1-v274 {
			reg `var' 
			replace var_name = e(depvar) in `i'
			local i = `i' + 1
         }

gen scale_points=.

gen means_f2f = .
gen std_f2f = .
gen low_cat_f2f =.

gen means_mm_long = .
gen std_mm_long = .
gen low_cat_mm_long =.

gen means_mm = .
gen std_mm = .
gen low_cat_mm =.

 * loop over all items
local i = 1
foreach var of varlist v1-v274 {
			svy: mean `var' if survey_mode==1
			replace means_f2f = (r(table)[1,1]) in `i'
			estat sd
			replace std_f2f = (r(sd)[1,1]) in `i'
			mtab1  `var' if survey_mode==1
			replace low_cat_f2f = (r(percent)[1,1]) in `i'	
			local i = `i' + 1
         }

local i = 1
foreach var of varlist v1-v274 {
			svy: mean `var' if survey_mode==3
			replace means_mm_long = (r(table)[1,1]) in `i'
			estat sd
			replace std_mm_long = (r(sd)[1,1]) in `i'
			mtab1  `var' if survey_mode==3
			replace low_cat_mm_long = (r(percent)[1,1]) in `i'	
			local i = `i' + 1
         }

local i = 1
foreach var of varlist v1-v274 {
			svy: mean `var' if survey_mode==2
			replace means_mm = (r(table)[1,1]) in `i'
			estat sd
			replace std_mm = (r(sd)[1,1]) in `i'
			mtab1  `var' if survey_mode==2
			replace low_cat_mm = (r(percent)[1,1]) in `i'	
			local i = `i' + 1
         }
		 
local i = 1
foreach var of varlist v1-v274 {
			tab `var' 
			replace scale_points = r(r) in `i'
			local i = `i' + 1
         }
*** last line