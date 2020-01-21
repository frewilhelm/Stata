********************************************************************************
* How to graph in Stata
********************************************************************************

version 15

clear

* Two-Dimensional-Graphs (Fancy)
********************************************************************************

* Set schemes
set scheme lean2
set dp period

* Set colors
global green "77 175 74"


* Create Dataset for example ***************************************************

* Set 100k Observations
set obs 100000 // 100k observation


* Declare waves, order obs and label waves
gen wave = .
local temp = 1
forvalues i = 1(1)10 { // 10 waves
	if `i' == 1 {
		replace wave = `i' in `i'/`temp'0000
		continue
	}
	
	replace wave = `i' in `temp'0000/`i'0000
	local ++temp
}

#delimit;
	label define waveLab
		1 "Wave 1"
		2 "Wave 2"
		3 "Wave 3"
		4 "Wave 4"
		5 "Wave 5"
		6 "Wave 6"
		7 "Wave 7"
		8 "Wave 8"
		9 "Wave 9"
		10 "Wave 10"
	;
#delimit cr
label value wave waveLab


* 1st attitude-var: values between 0-10, 'linear' to waves
gen lr_scale_pol = .
local temp = 2
forvalues i = 1(1)10 {
	local temp = `i' + 1
	if `temp' == 11 {
		local --temp
		replace lr_scale_pol = runiform(8,`temp') if wave == `i'
		continue
	}
	replace lr_scale_pol = runiform(`i',`temp') if wave == `i'
}


* 2nd attitude-var: values betweeen 0-10, more variation
gen lr_scale_fin = .
forvalues i = 1(1)10 {
	if `i' <= 2 {
		replace lr_scale_fin = runiform(7,9) if wave == `i'
	}
	if `i' > 2 & `i' <= 4 {
		replace lr_scale_fin = runiform(5,6) if wave == `i'
	}
	if `i' > 4 & `i' <= 6 {
		replace lr_scale_fin = runiform(3,4) if wave == `i'
	}
	if `i' > 6 & `i' <= 8 {
		replace lr_scale_fin = runiform(5,6) if wave == `i'
	}
	if `i' > 8{
		replace lr_scale_fin = runiform(1,3) if wave == `i'
	}
}


* "Analysis" ******************************************************************
* Changing attitudes over time???

reg lr_scale_pol i.wave, base cformat(%9,2f)

* Store Results as matrix to use it in graph
margins i.wave, post
matrix matrixPol = r(b)
gen storeResultPol = .
local temp = 1
forvalues i = 1(1)10 {
	replace storeResultPol = matrixPol[1, `temp'] if wave == `i'
	local ++temp
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

reg lr_scale_fin i.wave, base cformat(%9,2f)

* Store Results as matrix to use it in graph
margins i.wave, post
matrix matrixFin = r(b)
gen storeResultFin = .
local temp = 1
forvalues i = 1(1)10 {
	replace storeResultFin = matrixFin[1, `temp'] if wave == `i'
	local ++temp
}

* Graph ************************************************************************

*Drop duplicates and adjust scale
duplicates drop storeResultPol storeResultFin , force
replace storeResultPol = storeResultPol - 5
replace storeResultFin = storeResultFin - 5

* Sort wave to get the right order in the graph
sort wave
tsset wave // declare 'time'-Variable. Important for pcarrow

#delimit;
	twoway
	
		// Basis - Green arrows with stored values
		(pcarrow 
			L.storeResultPol L.storeResultFin 
			storeResultPol storeResultFin, 
				lcolor("$green") // marker
				mcolor("$green") // line
				)
				
		// Labels (waves)
		// - Don't show marker, only label
		// - Orientation depending on graph
		(scatter storeResultPol storeResultFin
			if inlist(wave, 1, 2, 4, 7, 8), 
				mlabel(wave) msize(zero) mlabposition(3) mlabgap(1.5))			
		(scatter storeResultPol storeResultFin
			if inlist(wave, 3, 10), 
				mlabel(wave) msize(zero) mlabposition(6) mlabgap(1.5))
		(scatter storeResultPol storeResultFin
			if inlist(wave, 5, 6, 9), 
				mlabel(wave) msize(zero) mlabposition(9) mlabgap(1.5))
				
		// Labels (square)
		(scatteri 5 -5.5 "Socialism",
			msymbol(none) mlabposition(3) mlabsize(large))
		(scatteri 5 5.5 "Liberal",
			msymbol(none) mlabposition(9) mlabsize(large))		
		(scatteri -5 -5.5 "Authoritarian",
			msymbol(none) mlabposition(3) mlabsize(large))		
		(scatteri -5 5.5 "Conservative",
			msymbol(none) mlabposition(9) mlabsize(large))																
		,
		
		// Show squares (Split graph)
		yline(0)
		xline(0)
		
		// Ticks and Labels
		xlabel(-5(1)5, grid)
		xticks(-5.5(1)5.5, tlength(.5))
		ylabel(-5(1)5, grid)
		yticks(-5.5(1)5.5, tlength(.5))
		
		// No legend..
		legend(off)
		
		// Titles
		title(A two dimensional model)
		xtitle(Left-Right-Scale: Financial Attitude)
		ytitle(Left-Right-Scale: Political Attitude)
		
		// Graphregion options
		aspectratio(1) // Make it square
		xsize(6)
		ysize(6)
		plotregion(lcolor(black))

	;
#delimit cr

// Adjust Tick-Labels
// (If necessary)
gr_edit .yaxis1.major.num_rule_ticks = 11
gr_edit .yaxis1.edit_tick 1 -5 `"5"', tickset(major)
gr_edit .yaxis1.major.num_rule_ticks = 10
gr_edit .yaxis1.edit_tick 1 -4 `"4"', tickset(major)
gr_edit .yaxis1.major.num_rule_ticks = 9
gr_edit .yaxis1.edit_tick 1 -3 `"3"', tickset(major)
gr_edit .yaxis1.major.num_rule_ticks = 8
gr_edit .yaxis1.edit_tick 1 -2 `"2"', tickset(major)
gr_edit .yaxis1.major.num_rule_ticks = 7
gr_edit .yaxis1.edit_tick 1 -1 `"1"', tickset(major)
gr_edit .xaxis1.major.num_rule_ticks = 11
gr_edit .xaxis1.edit_tick 1 -5 `"5"', tickset(major)
gr_edit .xaxis1.major.num_rule_ticks = 10
gr_edit .xaxis1.edit_tick 1 -4 `"4"', tickset(major)
gr_edit .xaxis1.major.num_rule_ticks = 9
gr_edit .xaxis1.edit_tick 1 -3 `"3"', tickset(major)
gr_edit .xaxis1.major.num_rule_ticks = 8
gr_edit .xaxis1.edit_tick 1 -2 `"2"', tickset(major)
gr_edit .xaxis1.major.num_rule_ticks = 7
gr_edit .xaxis1.edit_tick 1 -1 `"1"', tickset(major)
