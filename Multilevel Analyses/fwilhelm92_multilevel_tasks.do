********************************************************************************
************************** Multilevel-Analysis - Exam **************************
********************************************************************************

clear

set more off, perm
version 14

cd "[insert directory]"

capture log close
log using multilevel_exam.log , replace


if c(os) == "Windows" {
	global data "[insert global]"
	global output "[insert global]"
	global temp "[insert global]"
}

*************************************************************************** Data	

use $data/klausur.dta

*************************************************************************** Prep
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Wave

#delimit ;
	recode wave
		(1 = 0 "Wave 1 - 2016 - 1 Jahr vor BtW")
		(3 = 1 "Wave 2 - 2017 - 4 Monate vor BtW")
		(4 = 2 "Wave 3 - 2017 - 2 Monate vor BtW")
		(5 = 3 "Wave 4 - 2017 - 1 Monat vor BtW")
		(6 = 4 "Wave 5 - 2017 - 3. Woche vor BtW")
		(7 = 5 "Wave 6 - 2017 - 1. Woche vor BtW"),
	gen(n_wave);
#delimit cr

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  Age

xtset lfdn n_wave

* xttrans3 byr // as ado (see https://www.stata.com/statalist/archive/2003-07/
						* msg00279.html by Nick Cox)

gen age = .
replace age = 2016- byr if n_wave==0
replace age = 2017 - byr if n_wave ~=0
label variable age "Age"

bysort age : egen int_age = mean(internet)
replace int_age = round(int_age, 0.01)
twoway scatter int_age age || lfit internet age, nodraw

lpoly internet age, noscatter xlabel(10(10)90) xline(80) xline(91) xsize(10) ///
	ytitle("# days in last week informed about politics" "on the internet") ///
	title("") note("") nodraw
lpoly internet age if age<=90, noscatter xlabel(10(10)90) xline(80) nodraw


gen age_c = age-80
mkspline age0 0 age1 = age_c

#delimit ;
	twoway
		scatter int_age age_c if age<=90||
		lfit internet age0 ||
		lfit internet age1 if age<=90, nodraw;
#delimit cr

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * internet					

xttrans internet // a lot of variation

hist internet, discrete percent nodraw

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * tv					

xttrans tv // a lot of variation						
	
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  paper					

xttrans paper // a lot of variation							

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * talk					

xttrans talk // a lot of variation							
lpoly internet talk, noscatter nodraw

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  intention

xttrans intention // a lot of variation						
						

*********************************************************************** Analysis
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Task 1					

xtset, clear
xtset lfdn n_wave

xtreg internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91, ///
	re base
	
xtreg internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91, ///
	mle base // same as mixed
mixed internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91 ///
	|| lfdn:, stddev

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Task 3

mixed internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91 /// 
	|| lfdn: talk, stddev
predict u*, ref
scatter u1 u2, msymbol(p)
corr u1 u2

mixed internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91 ///
	|| lfdn: talk, stddev cov(exchangeable)
predict u1*, ref
scatter u11 u12, msymbol(p)
corr u11 u12

mixed internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91 ///
	|| lfdn: talk, stddev cov(unstructured)

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Task 5

mixed internet age0 age1 i.subjclass i.female talk i.east i.uni if age<=91 ///
	|| lfdn: , stddev resid(exponential, t(n_wave))

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Task 6
*************************************************************************** Prep
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Voting Intention

recode intention ///
	(0=0 "Don't know what to vote") ///
	(1 4 5 6 7 8 9 = 1 "Know what to vote"), gen(intent)

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  Age

by age, sort: egen age_int = mean(intent)
replace age_int = round(age_int, 0.01)
scatter age_int age, xline(88)
tab intent lfdn if age==88 // 1357 17924

lpoly intent age if lfdn~=1357 & lfdn~=17924, noscatter	

gen age_cc = age-40

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Talk

by talk, sort: egen talk_int = mean(intent)
replace talk_int = round(talk_int, 0.01)
scatter talk_int talk

lpoly intent talk, noscatter

gen talk_c = talk - 3

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * internet

by internet, sort: egen talk_internet = mean(intent)
replace talk_internet = round(talk_internet, 0.01)
scatter talk_internet internet

lpoly intent internet, noscatter

gen internet_c = internet - 3

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  paper

by paper, sort: egen talk_pap = mean(intent)
replace talk_pap = round(talk_pap, 0.01)
scatter talk_pap paper

lpoly intent paper, noscatter

gen paper_c = paper - 3

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * tv

by tv, sort: egen talk_tv = mean(intent)
replace talk_tv = round(talk_tv, 0.01)
scatter talk_tv tv

lpoly intent tv, noscatter

gen tv_c = tv - 3
	
*********************************************************************** Analysis

melogit intent c.age_cc c.talk_c c.internet_c c.paper_c c.tv_c i.subjclass ///
	i.female i.east i.uni i.n_wave if (lfdn~=1357 & lfdn~=17924) || lfdn: , ///
	or base intpoints(34)
	
*quadchk

********************************************************************************

melogit intent c.age_cc c.talk_c c.internet_c c.paper_c c.tv_c i.subjclass ///
	i.female i.east i.uni if (lfdn~=1357 & lfdn~=17924) || n_wave: , ///
	or base intpoints(15)

*quadchk
