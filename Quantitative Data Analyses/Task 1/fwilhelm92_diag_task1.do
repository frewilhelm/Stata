********************************************************************************
************************************ Task B ************************************
********************************************************************************

reg ln_hhincome i.n_party c.age1 c.age2

rvfplot, yline(0)

estat vif 					// Collinearity > 10 - not good. In this case, seems
*							   legit

estat hettest				// Heteroskedasticity-Test, seems legit.		

predict hat, hat
fre hat, tabulate(10) 		
drop hat					// Seems to be ok, since there are no noticeable 
*							   gaps

predict rstudent, rstudent
*fre rstudent, tabulate(10) // Too many values
sort rstudent
browse rstudent 
drop rstudent				// Some noticeable gaps are observable

reg ln_hhincome n_party c.age1 c.age2

predict dfbeta, dfbeta(n_party)
*fre dfbeta, tabulate(10) 	// Too many values
sort dfbeta
browse dfbeta
drop dfbeta					// Seems legit

predict dfbeta, dfbeta(c.age1)
*fre dfbeta, tabulate(10) 	// Too many values
sort dfbeta
browse dfbeta
drop dfbeta					// Some bigger noticeable gaps are observable

predict dfbeta, dfbeta(c.age2)
*fre dfbeta, tabulate(10) 	// Too many values
sort dfbeta
browse dfbeta
drop dfbeta					// Some bigger noticeable gaps are observable

predict cooksd, cooksd
*fre cooksd, tabulate(10) 	// Too many values
sort cooksd
browse cooksd
drop cooksd					// Some gaps can be observed

gen id = _n
lvr2plot2, lab(id) 			// Lot of Leverage

#delimit ;
reg ln_hhincome i.n_party c.age1 c.age2 if 
	id~=10232 & 
	id~=10233 &
	id~=10231 &
	id~=10230 &
	id~=9899;
#delimit cr
est sto m2

********************************************************************************
************************************ Task C ************************************
********************************************************************************

reg ln_hhincome i.n_party c.age1 c.age2 i.n_educ i.n_speduc

rvfplot, yline(0)

estat vif 					// Collinearity > 10 - not good. In this case, it
*							   seems that we have some collinearity.

estat hettest				// Heteroskedasticity-Test, seems legit.	

lvr2plot2, lab(id)


