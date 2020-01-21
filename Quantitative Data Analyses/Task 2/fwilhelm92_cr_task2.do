********************************************************************************
********************************************************************************
************************** Quantitative Data Analysis **************************
********************************************************************************
********************************************************************************

*   Installed SSC-Ados: fre, mkspline2, lvr2plot2 & bigtab(ssc install xy) *****
********************************************************************************

clear

version 14
set more off, perm

global d "[insert global]"

cd "[insert directory]"

********************************************************************************

capture log close
log using exam_task_cr2.log , replace

********************************************************************************
* Data - NORC 2004 GSS *********************************************************
********************************************************************************

use $d/exam_gss_2004.dta

********************************************************************************

* Preparation ******************************************************************

* DV - Divorced

* Variable 'divorce' is only asked to people, that arecurr. married or widowed
* -> Codebook www.thearda.com/Archive/Files/Codebooks/GSS2004_CB.asp
* 4 - Separated is also a bit tricky. Someone, who is 'separated' but not
*  'never married' still is 'married', even if they live separated.
*  -> So they have never been divorced.

#delimit ;
	recode marital
		(1 2 = 0 "Never Divorced")	
		(3 = 1 "Divorced")
		(4 5 = .),						// Never married = irrelevant for topic
	gen(n_div);
#delimit cr

replace n_div = 1 if divorce==1
replace n_div = . if divorce==. & n_div==0

* Three respondents, that are currently married, refused to answer the question,
*  if they were ever divorced (Effekt der sozialen Erwünschtheit?)
				
********************************************************************************
* IV - Education

by educ, sort: egen educ_div = mean(n_div)
replace educ_div = round(educ_div, 0.01)
scatter educ_div educ

gen c_educ = educ - 12

********************************************************************************
* IV - Age

by age, sort: egen age_div = mean(n_div)
replace age_div = round(age_div, 0.01)
scatter age_div age
* U-SHAPE

gen age_c = age-55
mkspline age_0 0 age_1 = age_c
scatter age_div age_0
scatter age_div age_1

********************************************************************************
* IV - Attend Religious Services

fre attend
#delimit ;
	recode attend
		(0 = 0 "Never")
		(1 2 = 1 "(lt) once a year")
		(3 4 = 2 "st a year/monthly")
		(5 6 = 3 "nrly every week")
		(7 8 = 4 "weekly and more"),
	gen(n_attend);
#delimit cr
tab attend n_attend, missing

by n_attend, sort: egen att_div = mean(n_div)
replace att_div = round(att_div, 0.01)
scatter att_div n_attend		

********************************************************************************
* IV - Sex

recode sex (2 = 0 "Female") (1 = 1 "Male"), gen(n_sex)


