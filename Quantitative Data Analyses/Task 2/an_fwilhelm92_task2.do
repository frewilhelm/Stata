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
log using exam_task_an2.log , replace

********************************************************************************
* Data - NORC 2004 GSS *********************************************************
********************************************************************************

do $d/cr_fwilhelm92_task2.do

********************************************************************************
************************************ Task A ************************************
********************************************************************************

logit n_div c_educ c.age_0 c.age_1 i.n_attend, or base nolog
margins, dydx(*)

********************************************************************************
************************************ Task B ************************************
********************************************************************************

logit n_div c.c_educ##i.n_sex c.age_0 c.age_1 i.n_attend, or base nolog





