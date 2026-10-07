/*******************************************************************************
  2-export-outputs.do  ·  Write every result the PI update quotes
--------------------------------------------------------------------------------
  Author(s):  DIL Data Team
              Nandita Gupta (nanditag@uchicago.edu)
  Updated:    October 2026

  Inputs:     data/households_clean.csv
                - one row per household visited, incl. non-consenting (id: key)
              data/children_clean.csv
                - one row per child under 5 (id: key child_index)

  Outputs:    ${report}/tables/numbers.tex
                - one LaTeX command per number quoted in the text
              ${report}/tables/tab1-water-practices.tex
                - Table 1, body only (caption and notes live in main.tex)
              ${report}/figures/fig1-chlorination-village.png
                - Figure 1

  Summary:    The report (main.tex) never contains a typed result.
              It \input's the table, includes the figure, and quotes numbers
              through commands such as \shareChlorine, all written here. When
              the data or a decision changes, rerun this file, push, pull in
              Overleaf and recompile: every exhibit and every number in the
              text moves together.

  Notes:      The sample is defined once, in section 1: consenting
              households, and only the last 7 days of fieldwork if
              $last_week_only = 1 (set in main.do).

              LaTeX's line break (two backslashes) is written as `eol' below,
              built from char(92), so Stata never has to read a backslash
              pair inside a string.
*******************************************************************************/

**------------------------------------------------------------------------------
**# 1 Load data and define the sample
**------------------------------------------------------------------------------

	import delimited "${ex_data}/households_clean.csv", clear varnames(1)

	* Dates are stored as text (YYYY-MM-DD): convert to a Stata date
	gen survey_date_d = date(survey_date, "YMD")
	assert !missing(survey_date_d)
	drop survey_date
	rename survey_date_d survey_date
	format survey_date %td

	if ${last_week_only} keep if last_week == 1

	count
	local n_visited = r(N)

	keep if consented == 1

	count
	local n_hh = r(N)

	local eol = char(92) + char(92)

**------------------------------------------------------------------------------
**# 2 Numbers for the text
**------------------------------------------------------------------------------

**## 2.1 Sample and fieldwork
**------------------------------------------------------------------------------

	local n_visited_fmt = strtrim(string(`n_visited', "%9.0fc"))
	local n_hh_fmt      = strtrim(string(`n_hh', "%9.0fc"))
	local consent_rate  = strtrim(string(100 * `n_hh' / `n_visited', "%9.1f"))

	if ${last_week_only} local sample_note "the last 7 days of fieldwork only"
	else                 local sample_note "all days of fieldwork"

	local months "January February March April May June July August September October November December"

	quietly summarize survey_date
	local d0 = r(min)
	local d1 = r(max)
	local fw_start = string(day(`d0')) + " " + word("`months'", month(`d0')) + " " + string(year(`d0'))
	local fw_end   = string(day(`d1')) + " " + word("`months'", month(`d1')) + " " + string(year(`d1'))

**## 2.2 Household results
**------------------------------------------------------------------------------

	quietly summarize chlorine_any
	local share_chlorine = strtrim(string(100 * r(mean), "%9.1f"))

	quietly summarize chlorine_days
	local mean_chl_days  = strtrim(string(r(mean), "%9.1f"))

	quietly summarize piped
	local share_piped    = strtrim(string(100 * r(mean), "%9.1f"))

**## 2.3 Child results
**------------------------------------------------------------------------------

	preserve

		import delimited "${ex_data}/children_clean.csv", clear varnames(1)

		* Same sample as the households
		if ${last_week_only} keep if last_week == 1
		keep if consented == 1

		count if !missing(diarrhea_any7)
		local n_children = strtrim(string(r(N), "%9.0fc"))

		quietly summarize diarrhea_any7 if chlorine_any == 1
		local diarrhea_chl   = strtrim(string(100 * r(mean), "%9.1f"))

		quietly summarize diarrhea_any7 if chlorine_any == 0
		local diarrhea_nochl = strtrim(string(100 * r(mean), "%9.1f"))

	restore

**## 2.4 Write numbers.tex
**------------------------------------------------------------------------------

	file open numbers using "${report}/tables/numbers.tex", write replace

	file write numbers "% Written by code/2-export-outputs.do. Do not edit by hand: rerun the code." _n
	file write numbers "\newcommand{\sampleNote}{`sample_note'}" _n
	file write numbers "\newcommand{\fieldworkStart}{`fw_start'}" _n
	file write numbers "\newcommand{\fieldworkEnd}{`fw_end'}" _n
	file write numbers "\newcommand{\nVisited}{`n_visited_fmt'}" _n
	file write numbers "\newcommand{\nHH}{`n_hh_fmt'}" _n
	file write numbers "\newcommand{\consentRate}{`consent_rate'}" _n
	file write numbers "\newcommand{\shareChlorine}{`share_chlorine'}" _n
	file write numbers "\newcommand{\meanChlorineDays}{`mean_chl_days'}" _n
	file write numbers "\newcommand{\sharePiped}{`share_piped'}" _n
	file write numbers "\newcommand{\nChildren}{`n_children'}" _n
	file write numbers "\newcommand{\diarrheaChlor}{`diarrhea_chl'}" _n
	file write numbers "\newcommand{\diarrheaNoChlor}{`diarrhea_nochl'}" _n

	file close numbers

**------------------------------------------------------------------------------
**# 3 Table 1: water practices by water source
**------------------------------------------------------------------------------

**## 3.1 Rows and their labels
**------------------------------------------------------------------------------

	* chlorine_days is a mean; every other row is a percentage
	local rows chlorine_any chlorine_days boil_any stored_now stored_chlor ///
		ran_out safe_very

	local lab_chlorine_any  "Chlorinated drinking water, past 7 days (\%)"
	local lab_chlorine_days "Days chlorinated, past 7 days (mean)"
	local lab_boil_any      "Boiled drinking water, past 7 days (\%)"
	local lab_stored_now    "Has drinking water stored now (\%)"
	local lab_stored_chlor  "\quad Stored water was chlorinated (\%)"
	local lab_ran_out       "Ran out of chlorine tablets, past 30 days (\%)"
	local lab_safe_very     "Rates drinking water as very safe (\%)"

	* Columns: piped water, other sources, all households
	local groups `" "piped == 1" "piped == 0" "1" "'

**## 3.2 Write the table body
**------------------------------------------------------------------------------

	file open tab using "${report}/tables/tab1-water-practices.tex", write replace

	file write tab "% Written by code/2-export-outputs.do. Do not edit by hand: rerun the code." _n
	file write tab "\begin{tabular}{lccc}" _n
	file write tab "\toprule" _n
	file write tab " & Piped & Other sources & All `eol'" _n
	file write tab "\midrule" _n

	foreach var of local rows {
		local line "`lab_`var''"
		foreach grp of local groups {
			quietly summarize `var' if `grp'
			if "`var'" == "chlorine_days" local cell = strtrim(string(r(mean), "%9.1f"))
			else                          local cell = strtrim(string(100 * r(mean), "%9.1f"))
			local line "`line' & `cell'"
		}
		file write tab "`line' `eol'" _n
	}

	local line "Households"
	foreach grp of local groups {
		quietly count if `grp'
		local cell = strtrim(string(r(N), "%9.0fc"))
		local line "`line' & `cell'"
	}

	file write tab "\midrule" _n
	file write tab "`line' `eol'" _n
	file write tab "\bottomrule" _n
	file write tab "\end{tabular}" _n

	file close tab

**------------------------------------------------------------------------------
**# 4 Figure 1: chlorination by village
**------------------------------------------------------------------------------

	preserve

		gen chlorine_pct = 100 * chlorine_any

		graph bar (mean) chlorine_pct,                                      ///
			over(village_id, sort(1) descending label(labsize(small)))      ///
			ytitle("Households that chlorinated, past 7 days (%)")          ///
			ylabel(0(20)100, angle(0)) yscale(range(0 100))                 ///
			blabel(bar, format(%3.0f) size(small))                          ///
			bar(1, color(maroon))                                           ///
			graphregion(color(white)) plotregion(color(white))

		graph export "${report}/figures/fig1-chlorination-village.png", ///
			width(2000) replace

	restore

********************************************************************************
