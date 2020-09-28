******** Quantitative Macroeconomics *******************************************
******** Homework 1 ************************************************************
clear all

*just put this do-file in the same folder as data
cd "`c(pwd)'"

*mcps_00003 contains extract from IPUMS-CPS
use macrodata

********************************************************************************
******** Prepare data **********************************************************

*prepare dummy for LF status
label value labforce
replace labforce = . if labforce == 0 //NIU
replace labforce = 0 if labforce == 1 // not in labforce
replace labforce = 1 if labforce == 2 // in labforce

*prepare dummy foe EMP status
label value empstat
replace empstat = . if (empstat == 0 | empstat == 1) // NIU + Armed Forces
replace empstat = 1 if (empstat == 10 | empstat == 12) // employed
replace empstat = 0 if (empstat == 21 | empstat == 22) // unemployed
replace empstat = . if (empstat == 32 | empstat == 34 | empstat == 36) // NILF

*weeklyhours
replace uhrsworkt = . if uhrsworkt == 997
replace uhrsworkt = . if uhrsworkt == 999

*earnings
replace earnweek = . if earnweek==9999.99

*prepare dummy for HS/nonHS
label value educ
gen highschool = "nonHS"
replace highschool="HS" if educ>=073

*prepare dummy for C(ollege)/nonC
*bachelor code == 111 / master == 123
gen college = "nonC"
replace college="C" if educ>=111

*occupation and covid risk
do occ_cat
merge m:1 occ_cat using occ_covidprob
drop _merge

*idustry groups and work from home
do aggregate_ind
merge m:1 industrygroup using workfromhome
drop if _merge==2
drop _merge

*prepare time variable *********************************************************
label value month
tostring year, replace
tostring month, replace
gen time = year+"m"+month
destring year month, replace
gen t = monthly(time,"YM")
drop time
rename t time
format time %tm

********************************************************************************
* data are prepared. Now start obtaining charts. *******************************

********** EMPLOYMENT RATE & HOURS *********************************************
*first preserve data
preserve 

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*set as time series
tsset time

** Detrend and deseasonalize
reg emprate time i.month if time<=tm(2020m1), noconstant
predict emprate_nocovid if time>=tm(2020m1)

reg weeklyhours time i.month if time<=tm(2020m1), noconstant
predict weeklyhours_nocovid if time>=tm(2020m1)

*charts
twoway (line emprate time) (line emprate_nocovid time)
graph export emprate.png, replace

twoway (line weeklyhours time) (line weeklyhours_nocovid time)
graph export weeklyhours.png, replace

*restore data
restore

********** EMPLOYMENT RATE & HOURS  VS HIGH SCHOOL STATUS **********************
preserve

*prepare types
levelsof highschool, clean
local types `r(levels)'

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month highschool)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*reshape
reshape wide emprate weeklyhours empstat labforce uhrsworkt, i(time month) j(highschool) string

*set as time series
tsset time

** Detrend and deseasonalize & chart
foreach tp of local types {
	reg emprate`tp' time i.month if time<=tm(2020m1), noconstant
	predict emprate_nocovid`tp' if time>=tm(2020m1)
	reg weeklyhours`tp' time i.month if time<=tm(2020m1), noconstant
	predict weeklyhours_nocovid`tp' if time>=tm(2020m1)
}

twoway (line emprateHS time) (line emprate_nocovidHS time) (line empratenonHS time) (line emprate_nocovidnonHS time)
graph export empratehighschool.png, replace

twoway (line weeklyhoursHS time) (line weeklyhours_nocovidHS time) (line weeklyhoursnonHS time) (line weeklyhours_nocovidnonHS time)
graph export weeklyhourshighschool.png, replace

*restore data
restore

********** EMPLOYMENT RATE & HOURS VS COLLEGE STATUS ***************************
preserve

*prepare types
levelsof college, clean
local types `r(levels)'

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month college)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*reshape
reshape wide emprate weeklyhours uhrsworkt empstat labforce, i(time month) j(college) string

*set as time series
tsset time

** Detrend and deseasonalize & chart
foreach tp of local types {
	reg emprate`tp' time i.month if time<=tm(2020m1), noconstant
	predict emprate_nocovid`tp' if time>=tm(2020m1)
	reg weeklyhours`tp' time i.month if time<=tm(2020m1), noconstant
	predict weeklyhours_nocovid`tp' if time>=tm(2020m1)
}

twoway (line emprateC time) (line emprate_nocovidC time) (line empratenonC time) (line emprate_nocovidnonC time)
graph export emprateCOLLEGE.png, replace

twoway (line weeklyhoursC time) (line weeklyhours_nocovidC time) (line weeklyhoursnonC time) (line weeklyhours_nocovidnonC time)
graph export weeklyhoursCOLLEGE.png, replace

*restore data
restore

********** EMPLOYMENT RATE & HOURS VS OCCUPATION *******************************
* OCCUPATION groupped by covid risk
preserve

*prepare types
levelsof occ_riskcat, clean
local types `r(levels)'

*drop missings because collapse will not work in next lines
drop if occ_riskcat==""

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month occ_riskcat)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*reshape
reshape wide emprate weeklyhours uhrsworkt empstat labforce, i(time month) j(occ_riskcat) string

*set as time series
tsset time

** Detrend and deseasonalize & chart
foreach tp of local types {
	reg emprate`tp' time i.month if time<=tm(2020m1), noconstant
	predict emprate_nocovid`tp' if time>=tm(2020m1)
	reg weeklyhours`tp' time i.month if time<=tm(2020m1), noconstant
	predict weeklyhours_nocovid`tp' if time>=tm(2020m1)
}

twoway (line empratelow time) (line emprate_nocovidlow time) (line empratehigh time) (line emprate_nocovidhigh time) (line empratehealthcare time) (line emprate_nocovidhealthcare time) 
graph export emprateOCC.png, replace

twoway (line weeklyhourslow time) (line weeklyhours_nocovidlow time) (line weeklyhourshigh time) (line weeklyhours_nocovidhigh time) (line weeklyhourshealthcare time) (line weeklyhours_nocovidhealthcare time) 
graph export weeklyhoursOCC.png, replace

*restore
restore

********** EMPLOYMENT RATE & HOURS VS INDUSTRY (TELEWORK) **********************
* INDUSTR groupped by ability to work from home
preserve

*prepare types
levelsof workhomegroup, clean
local types `r(levels)'

*drop missings because collapse will not work in next lines
drop if workhomegroup==""

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month workhomegroup)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*reshape
reshape wide emprate weeklyhours uhrsworkt empstat labforce, i(time month) j(workhomegroup) string

*set as time series
tsset time

** Detrend and deseasonalize & chart
foreach tp of local types {
	reg emprate`tp' time i.month if time<=tm(2020m1), noconstant
	predict emprate_nocovid`tp' if time>=tm(2020m1)
	reg weeklyhours`tp' time i.month if time<=tm(2020m1), noconstant
	predict weeklyhours_nocovid`tp' if time>=tm(2020m1)
}

twoway (line empratelow time) (line emprate_nocovidlow time) (line empratehigh time) (line emprate_nocovidhigh time) (line empratemedium time) (line emprate_nocovidmedium time) (line empratelack time) (line emprate_nocovidlack time) 
graph export emprateIND.png, replace

twoway (line weeklyhourslow time) (line weeklyhours_nocovidlow time) (line weeklyhourshigh time) (line weeklyhours_nocovidhigh time) (line weeklyhoursmedium time) (line weeklyhours_nocovidmedium time) (line weeklyhourslack time) (line weeklyhours_nocovidlack time)
graph export weeklyhoursIND.png, replace

*restore data
restore

********* DECOMPOSITIONS *******************************************************

********* FOR HOURS ************************************************************
preserve

drop if uhrsworkt==. | uhrsworkt==0

*obtain employment and labforce for each month
collapse (sum) empstat labforce uhrsworkt, by (time month)

*obtain employment rate
gen emprate=empstat/labforce
gen weeklyhours=uhrsworkt/labforce

*set as time series
tsset time

*employment deviation
reg empstat time i.month if time<=tm(2020m1), noconstant
predict empstat_nocovid if time>=tm(2020m1)
gen dev_employment = (empstat - empstat_nocovid)/empstat_nocovid

*aggregate hours worked
reg uhrsworkt time i.month if time<=tm(2020m1), noconstant
predict uhrsworkt_nocovid if time>=tm(2020m1)
gen dev_aghours = (uhrsworkt - uhrsworkt_nocovid)/uhrsworkt_nocovid

*average weekly hours
reg weeklyhours time i.month if time<=tm(2020m1), noconstant
predict weeklyhours_nocovid if time>=tm(2020m1)
gen dev_avhours = (weeklyhours - weeklyhours_nocovid)/weeklyhours_nocovid

*chart
twoway (line dev_employment time) (line dev_avhours time) (line dev_aghours time)
graph export decomphours.png, replace
restore

********** FOR EARNINGS ********************************************************
preserve

drop if earnweek==.

*obtain employment and labforce for each month
collapse (sum) empstat labforce earnweek, by (time month)

*
gen weeklyearn=earnweek/labforce

*set as time series
tsset time

*employment deviation
reg empstat time i.month if time<=tm(2020m1), noconstant
predict empstat_nocovid if time>=tm(2020m1)
gen dev_employment = (empstat - empstat_nocovid)/empstat_nocovid

*aggregate hours worked
reg earnweek time i.month if time<=tm(2020m1), noconstant
predict earnweek_nocovid if time>=tm(2020m1)
gen dev_agearnings = (earnweek - earnweek_nocovid)/earnweek_nocovid

*average weekly hours
reg weeklyearn time i.month if time<=tm(2020m1), noconstant
predict weeklyearn_nocovid if time>=tm(2020m1)
gen dev_avearnings = (weeklyearn - weeklyearn_nocovid)/weeklyearn_nocovid

*chart
twoway (line dev_employment time) (line dev_avearnings time) (line dev_agearning time)
graph export decompearnings.png, replace
restore

********************************************************************************