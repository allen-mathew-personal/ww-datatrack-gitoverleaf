# ==============================================================================
#  2-export-outputs.R  ·  Write every result the PI update quotes
# ------------------------------------------------------------------------------
#  Author(s): DIL Data Team · Nandita Gupta (nanditag@uchicago.edu)
#  Updated:   October 2026
#
#  Input:     data/households_clean.csv  one row per household visited (id: key)
#             data/children_clean.csv    one row per child under 5 (id: key, child_index)
#             last_week_only, repo_dir
#             (set in main.R)
#  Output:    in repo_dir (your clone of the exercise repository, synced
#             with your Overleaf project):
#               tables/numbers.tex               one LaTeX command per number
#               tables/tab1-water-practices.tex  Table 1, body only
#               figures/fig1-chlorination-village.png
#
#  Summary:   The report (main.tex) never contains a typed result:
#             it \input's these files. Rerun, push, pull in Overleaf,
#             recompile, and every number moves. Same output as the Stata
#             version (stata/code/2-export-outputs.do). Participants do not
#             need to edit this file.
# ==============================================================================

library(dplyr)
library(ggplot2)

# ---- 1 Load the clean data and define the sample (once) ----------------------
hh       <- read.csv(file.path(repo_dir, "data", "households_clean.csv"))
children <- read.csv(file.path(repo_dir, "data", "children_clean.csv"))
hh$survey_date <- as.Date(hh$survey_date)

# Consenting households; only the last 7 days of fieldwork if last_week_only
if (last_week_only) {
  hh       <- filter(hh, last_week == 1)
  children <- filter(children, last_week == 1)
}
n_visited <- nrow(hh)
hh        <- filter(hh, consented == 1)
children  <- filter(children, consented == 1)

dir.create(file.path(repo_dir, "tables"),  showWarnings = FALSE)
dir.create(file.path(repo_dir, "figures"), showWarnings = FALSE)

# ---- 2 Formatting helpers (same rounding as the Stata version) ---------------
pct      <- function(x) sprintf("%.1f", 100 * mean(x, na.rm = TRUE))
mean1    <- function(x) sprintf("%.1f", mean(x, na.rm = TRUE))
n_fmt    <- function(n) formatC(n, big.mark = ",", format = "d")
day_text <- function(d) paste(as.integer(format(d, "%d")), format(d, "%B %Y"))
latex_command <- function(name, value) sprintf("\\newcommand{\\%s}{%s}", name, value)
stamp <- "% Written by R/2-export-outputs.R. Do not edit by hand: rerun the code."

# ---- 3 Numbers for the text ---------------------------------------------------
numbers <- c(
  sampleNote       = if (last_week_only) "the last 7 days of fieldwork only"
                     else "all days of fieldwork",
  fieldworkStart   = day_text(min(hh$survey_date)),
  fieldworkEnd     = day_text(max(hh$survey_date)),
  nVisited         = n_fmt(n_visited),
  nHH              = n_fmt(nrow(hh)),
  consentRate      = sprintf("%.1f", 100 * nrow(hh) / n_visited),
  shareChlorine    = pct(hh$chlorine_any),
  meanChlorineDays = mean1(hh$chlorine_days),
  sharePiped       = pct(hh$piped),
  nChildren        = n_fmt(sum(!is.na(children$diarrhea_any7))),
  diarrheaChlor    = pct(children$diarrhea_any7[children$chlorine_any %in% 1]),
  diarrheaNoChlor  = pct(children$diarrhea_any7[children$chlorine_any %in% 0])
)

writeLines(c(stamp, latex_command(names(numbers), numbers)),
           file.path(repo_dir, "tables", "numbers.tex"))

# ---- 4 Table 1: water practices by water source --------------------------------
rows <- c(
  chlorine_any  = "Chlorinated drinking water, past 7 days (\\%)",
  chlorine_days = "Days chlorinated, past 7 days (mean)",
  boil_any      = "Boiled drinking water, past 7 days (\\%)",
  stored_now    = "Has drinking water stored now (\\%)",
  stored_chlor  = "\\quad Stored water was chlorinated (\\%)",
  ran_out       = "Ran out of chlorine tablets, past 30 days (\\%)",
  safe_very     = "Rates drinking water as very safe (\\%)"
)
groups <- list(hh[hh$piped %in% 1, ], hh[hh$piped %in% 0, ], hh)

body <- sapply(names(rows), function(v) {
  cells <- sapply(groups, function(g) if (v == "chlorine_days") mean1(g[[v]]) else pct(g[[v]]))
  paste(rows[[v]], "&", paste(cells, collapse = " & "), "\\\\")
})
households <- paste("Households &",
                    paste(sapply(groups, function(g) n_fmt(nrow(g))), collapse = " & "),
                    "\\\\")

writeLines(c(stamp, "\\begin{tabular}{lccc}", "\\toprule",
             " & Piped & Other sources & All \\\\", "\\midrule",
             body, "\\midrule", households, "\\bottomrule", "\\end{tabular}"),
           file.path(repo_dir, "tables", "tab1-water-practices.tex"))

# ---- 5 Figure 1: chlorination by village ---------------------------------------
by_village <- hh %>%
  group_by(village_id) %>%
  summarise(chlorine_pct = 100 * mean(chlorine_any, na.rm = TRUE)) %>%
  mutate(village_id = reorder(factor(village_id), -chlorine_pct))

fig1 <- ggplot(by_village, aes(village_id, chlorine_pct)) +
  geom_col(fill = "#800000", width = 0.6) +
  geom_text(aes(label = sprintf("%.0f", chlorine_pct)), vjust = -0.5, size = 3) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  labs(x = NULL, y = "Households that chlorinated, past 7 days (%)") +
  theme_classic(base_size = 11)

ggsave(file.path(repo_dir, "figures", "fig1-chlorination-village.png"),
       fig1, width = 8, height = 4.5, dpi = 250)

message("Wrote numbers.tex, Table 1 and Figure 1 to ", normalizePath(repo_dir),
        " (last_week_only = ", last_week_only, ").\nNow commit and push in GitHub Desktop, then pull in Overleaf.")
