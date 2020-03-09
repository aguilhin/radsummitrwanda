* Produce graphs for RAD summit in Kigali
* March 2020
* AGuilhin

*V3 change for github new branch! (v2 was for commit)
*Change: test2

	global lsms_ug "C:\Users\AGuilhin\Documents\8. National Data\LSMS - Uganda\2015\2_data\UGA_2015_UNPS_v01_M_STATA8"
	global rad_presentation "C:\Users\AGuilhin\Box Sync\3_RADsummit\04 Presentation"
	loc sdcheck 2.5

	
* HH data from LSMS
	cd "$lsms_ug"
	use gsec8, clear
		
* GENERATE RELEVANT VARIABLES
	cd "$rad_presentation"
	
  * Employement income in cash	
	gen empl_income = h8q31a

  * Employement income in cash -> ln	
	gen empl_income_ln = ln(empl_income) 
	
  * Employment monthly income in cash
	/*
	h8q31c:
           1 Hour
           2 Day
           3 Week
           4 Month
           5 Other (specify)
	*/	
	// convert daily and week
	gen empl_income_month = h8q31a if h8q31c == 4
	replace empl_income_month = h8q31a * 24 if h8q31c == 2 // w/o sundays
	replace empl_income_month = h8q31a * 4 if h8q31c == 3
	
	// Number of week per month worked in average
	//*
	gen weekpermonth = h8q30b
	recode weekpermonth 5=4
	replace empl_income_month = empl_income_month * weekpermonth/4
	*/
	
  * Employment monthly income in cash -> ln
	gen empl_income_month_ln = ln(empl_income_month)		
		
  *	Format & label
	label var empl_income_month "Monthly income from employment (USh)"
	label var empl_income_month_ln "Log of monthly income from employment (log of USh)"
		
* EXPORT 
	local colorx green
	local colorlinex magenta
	local colorln blue
	local colorlineln red	

  * I. Pbm
	sum empl_income_month
	local m=r(mean)
	local sd=r(sd)
	local max=r(max)
	local low =`m'- `sdcheck'*`sd'
	local high=`m'+`sdcheck'*`sd'
	local low_str = string(round(`low',1),"%12.0gc")
	local high_str = string(round(`high',1),"%12.0gc")
	
	hist empl_income_month, fc(none) lc(`colorx') ///
		xline(`low', lc(`colorlinex')) xline(`high', lc(`colorlinex')) ///
		title("mean - `sdcheck' * sd = `low_str'" ///
		"mean + `sdcheck' * sd = `high_str'") ///
		xscale(range(`low' `max')) 
	graph export empl_income_month_outliers1.png, replace		
	
  * II. slt	
	hist empl_income_month, fc(none) lc(`colorx')
	graph export empl_income_month.png, replace
	
	qui hist empl_income_month_ln, fc(none) lc(`colorln') normal
	graph export empl_income_month_ln.png, replace
	
  * II.a	
  	sum empl_income_month_ln
	local m=r(mean)
	local sd=r(sd)
	local low = `m'- `sdcheck' * `sd'
	local high= `m'+`sdcheck' * `sd'

	hist empl_income_month_ln, fc(none) lc(`colorln') ///
		xline(`low', lc(`colorlineln')) xline(`high', lc(`colorlineln'))
	graph export empl_income_month_ln_outliers.png, replace	
	
  * II.a with legend
  	sum empl_income_month_ln
	local m=r(mean)
	local sd=r(sd)
	local low = `m'- `sdcheck' * `sd'
	local high= `m'+`sdcheck' * `sd'
	local low_str = string(round(`low',.01),"%12.0gc")
	local high_str = string(round(`high',.01),"%12.0gc")

	hist empl_income_month_ln, fc(none) lc(`colorln') ///
		xline(`low', lc(`colorlineln')) xline(`high', lc(`colorlineln')) ///
		 title("mean(ln(X)) - `sdcheck' * ln(X)) = `low_str'" ///
		 "mean(ln(X)) + `sdcheck' * ln(X) = `high_str'")
		
	graph export empl_income_month_ln_outliers_legend.png, replace		
	
  * II.b	
  	sum empl_income_month_ln
	local m_ln=r(mean)
	local sd_ln=r(sd)
	local low = exp(`m_ln'- `sdcheck' * `sd_ln')
	local high= exp(`m_ln'+`sdcheck' * `sd_ln')
	local low_str = string(round(`low',1),"%12.0gc")
	local high_str = string(round(`high',1),"%12.0gc")
	
	di "`high_str'"

	hist empl_income_month, fc(none) lc(`colorx') ///
		xline(`low', lc(`colorlineln')) xline(`high', lc(`colorlineln')) ///
		 title("exp(mean(ln(X)) - `sdcheck' * sd(ln(X))) = `low_str'" ///
		 "exp(mean(ln(X)) + `sdcheck' * sd(ln(X))) = `high_str'")
	graph export empl_income_month_outliers_ln.png, replace	
	
	// Monthly income seems better
	
	
* CHECKS
	
  * Traditional scenario
	sum empl_income_month
	gen flag = (empl_income_month < r(mean) - `sdcheck' *r(sd) | ///
		empl_income_month > r(mean) + `sdcheck' *r(sd)) & ///
		!mi(empl_income_month)

  * Log scenario
	sum empl_income_month_ln
	gen flag_ln = (empl_income_month_ln < r(mean) - `sdcheck' *r(sd) | ///
		empl_income_month_ln > r(mean) + `sdcheck' *r(sd)) & ///
		!mi(empl_income_month_ln)

  * Compare	 	
	preserve
		ta empl_income_month if flag == 1
		keep if flag ==1
		keep empl_income_month
		duplicates drop
		sort empl_income_month
		export excel "empl_income_outliers_x.xlsx", first(var) replace
	restore
		
	preserve
		ta empl_income_month if flag_ln == 1
		keep if flag_ln ==1
		keep empl_income_month
		duplicates drop
		sort empl_income_month
		export excel "empl_income_outliers_ln.xlsx", first(var) replace
	restore
	
	
	