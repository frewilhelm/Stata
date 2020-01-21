********************************************************************************
********************************************************************************
************************** Quantitative Data Analysis **************************
********************************************************************************
********************************************************************************

clear

version 14
set more off, perm

global d "[insert Global]"

cd "[insert directory]"

********************************************************************************

capture log close
log using exam_task_cr1.log , replace

********************************************************************************
* Data - Soc. Strat. in Eastern Europe after 1989 for Czechoslovakia ***********
********************************************************************************

use $d/csk.dta, clear

* Preparation ******************************************************************

* Income

gen n_hhincome = hshmtot
replace n_hhincome = . if n_hhincome==-2
hist n_hhincome
gen ln_hhincome = ln(n_hhincome)

********************************************************************************

* Sex

recode sex (1=1 "Male") (2=0 "Female"), gen(n_sex)
tab sex n_sex, missing

* Birth

replace birth = 38 if birth==1938
replace birth = 1900+birth

gen n_age = 1993-birth
bigtab birth n_age

/*******************************************************************************
* Linearity Assumption *********************************************************

by n_age, sort: egen age_lin = mean(ln_hhincome)
replace age_lin = round(age_lin, 0.01)
scatter age_lin n_age

twoway (scatter n_age n_hhincome) (lfit n_age ln_hhincome)
scatter n_age n_hhincome

* Not linear -> Spline*********************************************************/

gen n_age_c = n_age-48

mkspline age1 0 age2 = n_age_c

bigtab age1 n_age_c 
bigtab age2 n_age_c

/*******************************************************************************
* Linearity Assumption *********************************************************

by age1, sort: egen age1_lin = mean(ln_hhincome)
replace age1_lin = round(age1_lin, 0.01)
scatter age1_lin age1

by age2, sort: egen age2_lin = mean(ln_hhincome)
replace age2_lin = round(age2_lin, 0.01)
scatter age2_lin age2

* At least more linear**********************************************************
*******************************************************************************/

* Communist Party

recode cpever (2=0 "No") (1=1 "Yes") (-2=.), gen(n_party)
tab cpever n_party, missing

* Respondents Education and Spouse's Education

#delimit ;
	recode hiedrc
		(1=0 "Primary Incomplete")
		(2 3 4=1 "Primary Complete") // if sec. incomp. -> atleast prim. complete; vocational = primary
		(5 6 7=2 "Secondary Complete") // if high. incomp -> atleast sec. comp.
		(8 9=3 "Tertiary Complete")
		(-2=.),
	gen(n_educ);
#delimit cr	
tab hiedrc n_educ, missing

#delimit ;
	recode speduc
		(201 601=0 "Primary Incomplete")
		(202 203 204 602 603 604=1 "Primary Complete") // apprentice = vocational
		(205 206 207 605 606 607=2 "Secondary Complete") 
		(208 209 210 608 609 610=3 "Tertiary Complete")
		(-8 -7 -2 -1=.),
	gen(n_speduc);
#delimit cr
tab speduc n_speduc, missing

tab n_educ n_speduc, missing

********************************************************************************
************************************ Task D ************************************
********************************************************************************

gen m_educ = .
replace m_educ = n_educ if n_sex==1
replace m_educ = n_speduc if n_sex==0
label define m_educ 0 "Primary Incomplete" 1 "Primary Complete" ///
	2 "Secondary Complete" 3 "Tertiary Complete"
label value m_educ m_educ
tab m_educ n_educ if n_sex==1

gen f_educ = . 
replace f_educ = n_educ if n_sex==0
replace f_educ = n_speduc if n_sex==1
label define f_educ 0 "Primary Incomplete" 1 "Primary Complete" ///
	2 "Secondary Complete" 3 "Tertiary Complete"
label value f_educ f_educ
tab f_educ n_educ if n_sex==0

browse m_educ f_educ n_educ n_speduc n_sex


