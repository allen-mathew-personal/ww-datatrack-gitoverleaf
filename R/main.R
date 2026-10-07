# ==============================================================================
#         Publication: Reports & Replicability - DIL Welcome Week Session 5
#             EXERCISE · Results that update themselves in Overleaf
#                                   main.R
# ------------------------------------------------------------------------------
#  Author(s): DIL Data Team 
#  Updated:   October 2026
#
#  Summary:   R version of the Session 5 Overleaf exercise (the Stata version
#             is stata/main.do; both write the same files). Everything lives in
#             ONE GitHub repository (your fork): the code, the data and the
#             PI update (main.tex). This file reads data/ and writes every
#             result main.tex quotes -- a table (.tex), a figure (.png) and
#             the numbers in the text (tables/numbers.tex) -- into the same
#             repository. Instructions: README.txt.
#
#  You need:  install.packages(c("dplyr", "tidyr", "ggplot2"))
#
#  Outline:   1. Settings: the switch
#             2. Your one path
#             3. Run: 2-export-outputs.R
# ==============================================================================

# ---- 1 Settings ---------------------------------------------------------------

# THE SWITCH. FALSE = all fieldwork days; TRUE = the last 7 days of fieldwork.
# Run once with FALSE, then change it to TRUE (step 5 of README.txt).
last_week_only <- TRUE

# ---- 2 Your one path ------------------------------------------------------------
#   repo_dir : your local clone of YOUR FORK of the exercise repository (the
#              folder with main.tex, data/, stata/ and R/). GitHub Desktop
#              shows it: Repository > Show in Finder / Show in Explorer.
# Sys.info()[["user"]] shows your username. Copy Nandita's block for yourself.

user <- Sys.info()[["user"]]

if (user == "admin") {                                   # Nandita
  repo_dir <- "/Users/admin/Desktop/DIL/ww-datatrack-gitoverleaf"
} else if (user == "") {                                 # YOU
  repo_dir <- ""
} else {
  stop("Add a block for your username (", user, ") in section 2 of main.R")
}

stopifnot(
  "repo_dir is wrong: it must be your clone of the exercise repository (the folder with main.tex, data/ and R/)" =
    file.exists(file.path(repo_dir, "main.tex")) &&
    file.exists(file.path(repo_dir, "data", "households_clean.csv"))
)

# ---- 3 Run ----------------------------------------------------------------------
source(file.path(repo_dir, "R", "2-export-outputs.R"))     # writes the 3 files
