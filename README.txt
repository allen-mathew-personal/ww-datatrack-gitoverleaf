TESTTTTTTT EXERCISE 1b - RESULTS THAT UPDATE THEMSELVES IN OVERLEAF
DIL Welcome Week - Data Session 5 - Publication: Reports & Replicability
About 20 minutes - Stata or R

Your PI reads fieldwork updates in Overleaf. In this exercise the update's
numbers never get typed: your code writes them to files, GitHub carries the
files to Overleaf, and the report only points at them.

You will:
  1. fork the exercise repository on GitHub: one repository with the code,
     the data AND the report (main.tex),
  2. open your fork in Overleaf, and clone it to your computer,
  3. set ONE path (your clone), run the code, push, and see your results in
     Overleaf,
  4. change one flag to switch the report to the last week of fieldwork, run
     again, and watch every number update.

Use EITHER Stata OR R: both write exactly the same files.

The repository: https://github.com/nanditag2548/ww-datatrack-gitoverleaf


WHAT'S IN THE REPOSITORY
------------------------
  README.txt                these instructions
  main.tex                  the PI update (it never contains a typed number)
  tables/numbers.tex        every number quoted in the text   (written by the code)
  tables/tab1-water-practices.tex   Table 1                   (written by the code)
  figures/fig1-chlorination-village.png   Figure 1           (written by the code)
  data/                     the clean data (already prepared, nothing to do)
      households_clean.csv      one row per household visited
      children_clean.csv        one row per child under 5
  stata/                    Stata version: run stata/main.do
      main.do                   the only file you edit (one path)
      code/2-export-outputs.do  writes the three files (no need to open it)
      ado/                      ieboilstart, so nothing to install
  R/                        R version: run R/main.R
      main.R                    the only file you edit (one path)
      2-export-outputs.R        writes the three files (no need to open it)

Overleaf ignores the code and data: it only compiles main.tex. GitHub carries
everything, so the code and the report always travel together.


YOU NEED
--------
  - A GitHub account and GitHub Desktop (desktop.github.com)
  - An Overleaf account with GitHub sync (log in with UChicago SSO), linked
    to GitHub: Overleaf > Account Settings > Integrations > GitHub > Link
  - Stata 15 or later, OR R with these packages (run once in the R console):
      install.packages(c("dplyr", "tidyr", "ggplot2"))


STEPS
-----
1. FORK THE REPOSITORY (1 min)
   Open the repository link above and click Fork (top right) > Create fork.
   You now have your own copy: github.com/<you>/ww-datatrack-gitoverleaf.

2. OPEN YOUR FORK IN OVERLEAF (2 min)
   In Overleaf: New Project > Import from GitHub, and pick your fork.
   Click Recompile: you should see a two-page fieldwork update.
   Your Overleaf project and your fork are now linked.

3. CLONE YOUR FORK TO YOUR COMPUTER (2 min)
   In GitHub Desktop: File > Clone repository, pick your fork, and note the
   local path it shows (e.g. /Users/you/Documents/GitHub/ww-datatrack-gitoverleaf).
   This folder is your "clone": the only path you need.

4. SET YOUR PATH, RUN, PUSH, PULL (6 min)

   Stata: open stata/main.do (in your clone). In section "2 Set file paths",
   copy existing block and change it for yourself:

     // YOU
     else if "`c(username)'" == "yourusername" {         // di c(username) shows it
         global repo "/path/to/your/clone"
     }

   R: open R/main.R (in your clone). In section "2 Your one path", the same:

     } else if (user == "yourusername") {                # Sys.info()[["user"]] shows it
       repo_dir <- "/path/to/your/clone"
     }

   Windows: use forward slashes in paths (C:/Users/...).

   Then:
     a. RUN main.do (Do) or main.R (Source). It rewrites tables/numbers.tex,
        tables/tab1-water-practices.tex and figures/fig1-chlorination-village.png
        in your clone. Open numbers.tex to see what the report will quote.
     b. PUSH: in GitHub Desktop, commit the changed files (message: "Update
        outputs") and click Push origin. Your main.do/main.R change can go in
        the same commit.
     c. PULL IN OVERLEAF: Menu > Sync > GitHub > Pull GitHub changes into
        Overleaf, then Recompile.

   The PDF looks the same as before, but its numbers now come from your run.

5. CHANGE THE FLAG AND RUN AGAIN (4 min)
   Your PI asks: "Does this hold if you only look at the last week of
   fieldwork?"
     Stata: in main.do, section 1, set   global last_week_only 1
     R:     in main.R, section 1, set    last_week_only <- TRUE
   Run, push, pull in Overleaf, recompile.

   Check the PDF: the dates, the number of households, every percentage in the
   text, Table 1, Figure 1 and the notes should all have changed, and you
   didn't type any of them. With all fieldwork the report covers 1,293
   households visited; with the last week only, 452.


THREE RULES
-----------
  1. Nobody types a number into main.tex. Numbers come from tables/numbers.tex.
  2. Files in tables/ and figures/ are only ever changed by the code.
  3. main.tex is only ever edited in Overleaf.


IF YOU GET STUCK
----------------
  - Stata: "file .../main.tex not found", "command ieboilstart is
    unrecognized" or "file ... households_clean.csv not found"
      global repo doesn't point to your clone. Check the path in GitHub
      Desktop (Repository > Show in Finder / Show in Explorer).
  - R: "Add a block for your username"
      Your username isn't in section 2 of main.R yet.
  - R: "repo_dir is wrong"
      The path doesn't point to your clone (the folder with main.tex).
  - R: "there is no package called ..."
      install.packages("dplyr") (or whichever package is named).
  - GitHub Desktop shows no changes
      You ran the code in a different copy of the folder: check the path.
  - Overleaf: the PDF didn't change
      You recompiled without pulling, or didn't push. GitHub Desktop should
      say "No local changes" after pushing.
  - Overleaf: merge conflict when pulling
      Someone edited tables/ or figures/ in Overleaf. Rule 2: keep the GitHub
      version.
  - GitHub Desktop: "rejected" when pushing
      Overleaf pushed a change (e.g. you edited main.tex there). Click Fetch
      origin, then Pull origin, then push again.
  - Overleaf: no "Import from GitHub", or no GitHub in the menu
      Your Overleaf account doesn't have GitHub sync or isn't linked to
      GitHub (see YOU NEED). Fallback: on GitHub, Code > Download ZIP, unzip,
      set your path to that folder, run, then in Overleaf New Project > Upload
      Project with main.tex, tables/ and figures/ (or upload the three
      changed files after each run).
