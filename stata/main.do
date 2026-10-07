/*******************************************************************************
         Publication: Reports & Replicability - DIL Welcome Week Session 5
             EXERCISE · Results that update themselves in Overleaf
                                  main.do
********************************************************************************

  Author(s): DIL Data Team
             Nandita Gupta (nanditag@uchicago.edu)

  Updated:   October 2026
  Version:   Stata 15

  Summary:   Stata version of the Session 5 Overleaf exercise (the R version
             is R/main.R). Everything lives in ONE GitHub
             repository (your fork): the code, the data and the PI update
             (main.tex). This file reads data/ and writes every result
             main.tex quotes -- a table (.tex), a figure (.png) and the
             numbers in the text (tables/numbers.tex) -- into the same
             repository. Push, pull in Overleaf, recompile: nobody retypes a
             number. Instructions: README.txt.

             Set your one path in section 2 and run. The user-written
             command it needs (ieboilstart) is in stata/ado/.

  Outline:   1. Select parts of the code to run
             2. Set file paths
             3. Initial settings
             4. Run code
                4.1 2-export-outputs.do  Write table, figure, numbers
*******************************************************************************/

**------------------------------------------------------------------------------
**# 1 Select parts of the code to run
**------------------------------------------------------------------------------

	local export    1

	* THE SWITCH. 0 = all fieldwork days; 1 = the last 7 days of fieldwork.
	* Run once with 0, then change it to 1 (step 5 of README.txt).
	global last_week_only 0

**------------------------------------------------------------------------------
**# 2 Set file paths
**------------------------------------------------------------------------------

* Your one path ------------------------------------------------------------------

	* repo: your local clone of YOUR FORK of the exercise repository (the
	*       folder with main.tex, data/, stata/ and R/). GitHub Desktop shows
	*       it: Repository > Show in Finder / Show in Explorer.
	* Type 'di c(username)' to see the name of your machine.

	// Nandita
	if "`c(username)'" == "admin" {
		global repo "/Users/admin/Desktop/DIL/ww-datatrack-gitoverleaf"
	}

	// YOU: copy the two lines above, with your username and your path
	else if "`c(username)'" == "" {
		global repo ""
	}

* Everything else follows from it ----------------------------------------------

	global ex          "${repo}"
	global ex_code     "${repo}/stata/code"
	global ex_data     "${repo}/data"
	global report      "${repo}"          // main.tex, tables/ and figures/ are here

	confirm file "${repo}/main.tex"

**------------------------------------------------------------------------------
**# 3 Initial settings
**------------------------------------------------------------------------------

	* Find the user-written command (ieboilstart) shipped in stata/ado/
	sysdir set  PLUS "${ex}/stata/ado"
	adopath ++  PLUS
	adopath ++  BASE

	* Set initial configurations as much as allowed by Stata version
	ieboilstart, v(15.0)
	`r(version)'

	* Folders the code writes to
	cap mkdir "${report}/tables"
	cap mkdir "${report}/figures"

**------------------------------------------------------------------------------
**# 4 Run code
**------------------------------------------------------------------------------

**## 4.1 Export outputs
/*------------------------------------------------------------------------------
    Writes every result the PI update quotes, for the sample chosen by
    $last_week_only.

  Inputs:   data/households_clean.csv
            data/children_clean.csv
  Outputs:  ${report}/tables/numbers.tex
            ${report}/tables/tab1-water-practices.tex
            ${report}/figures/fig1-chlorination-village.png
------------------------------------------------------------------------------*/

	if `export' do "${ex_code}/2-export-outputs.do"

********************************************************************************
