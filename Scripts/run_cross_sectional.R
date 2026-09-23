#############################
# run_cross_sectional.R
#   -- runner: baseline descriptives, group tests and Figures 1d-1f
# PURPOSE
#   > Describe the baseline cohort by amyloid status and by LDL-C category,
#     test baseline CSF and cognition across LDL-C categories, and draw the
#     boxplot and scatter figures.
# REQUIREMENTS
#   > Packages: readxl, table1, dunn.test, ggplot2, ggsignif
#   > Inputs  : cfg$paths$data_file (individual-level, gitignored)
# USAGE
#   > Rscript Scripts/run_cross_sectional.R
#     or source("Scripts/run_cross_sectional.R") from RStudio
#   > LDL_SCHEME=ncep3 Rscript Scripts/run_cross_sectional.R  -- 3-group sensitivity run
#     (writes to Outputs/cross_sectional_ldl3; the primary outputs are untouched)
# NOTES
#   > Writes to cfg$paths$cross_sectional (gitignored Outputs/).
#############################

# Resolve script directory ####
# Order: the file being source()d (innermost), then Rscript --file=, then
# LDL_ANALYSIS_ROOT or the working directory (line-by-line use in RStudio).
script_dir <- NULL
for (frame_idx in rev(seq_len(sys.nframe()))) {
     if (!is.null(sys.frame(frame_idx)$ofile)) {
          script_dir <- dirname(normalizePath(sys.frame(frame_idx)$ofile))
          break
     }
}
file_arg <- grep(pattern = "^--file=", x = commandArgs(trailingOnly = FALSE), value = TRUE)
if (is.null(script_dir) && length(file_arg) == 1L) {
     script_dir <- dirname(normalizePath(sub(pattern = "^--file=", replacement = "", x = file_arg)))
}
if (is.null(script_dir)) {
     script_dir <- file.path(Sys.getenv("LDL_ANALYSIS_ROOT", unset = getwd()), "Scripts")
}
if (!file.exists(file.path(script_dir, "config_ldl_analysis.R"))) {
     stop("cross_sectional:: !> config_ldl_analysis.R not found in ", script_dir,
          "; set LDL_ANALYSIS_ROOT or setwd() to the project root")
}

# Load configuration and functions ####
source(file.path(script_dir, "config_ldl_analysis.R"))
for (f in list.files(path = script_dir, pattern = "^FUNCTION_.*\\.R$", full.names = TRUE)) source(f)

out_dir <- cfg$paths$cross_sectional
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
message("cross_sectional:: !> LDL scheme ", cfg$ldl$scheme, "; writing to ", out_dir)

# Load cohort ####
cohort   <- load_cohort(data_file = cfg$paths$data_file, cohort_cfg = cfg$cohort, ldl_cfg = cfg$ldl)
baseline <- cohort$baseline

# Demographics ####
message("cross_sectional:: !> Demographics tables")
build_demographics_table(data = baseline, vars = cfg$demographics$vars,
                         strata_col = "amyloid_status",
                         out_stem = file.path(out_dir, "table1_by_amyloid_status"))
build_demographics_table(data = baseline, vars = cfg$demographics$vars,
                         strata_col = "ldl_group",
                         out_stem = file.path(out_dir, "table1_by_ldl_group"))

# Group sizes ####
group_n <- as.data.frame(table(ldl_group = baseline$ldl_group,
                               amyloid_status = baseline$amyloid_status),
                         stringsAsFactors = FALSE)
utils::write.csv(x = group_n, file = file.path(out_dir, "n_by_ldl_group_amyloid.csv"), row.names = FALSE)
message("cross_sectional:: !> Baseline n by LDL-C group: ",
        paste(names(table(baseline$ldl_group)), table(baseline$ldl_group), sep = " = ", collapse = "; "))

# Group comparisons ####
message("cross_sectional:: !> Kruskal-Wallis + Dunn tests")
tests <- compare_ldl_groups(data = baseline, outcomes = cfg$cross_sectional$outcomes,
                            group_col = "ldl_group", p_adjust = cfg$cross_sectional$p_adjust)
utils::write.csv(x = tests$kruskal, file = file.path(out_dir, "kruskal_wallis.csv"), row.names = FALSE)
utils::write.csv(x = tests$dunn, file = file.path(out_dir, "dunn_pairwise.csv"), row.names = FALSE)

# Boxplots (Figures 1d-1f) ####
message("cross_sectional:: !> Boxplots")
for (outcome in names(cfg$cross_sectional$boxplots)) {
     box_cfg <- cfg$cross_sectional$boxplots[[outcome]]
     p <- plot_ldl_boxplot(data = baseline, outcome = outcome, group_col = "ldl_group_label",
                           box_cfg = box_cfg, colors = cfg$ldl$colors,
                           signif_test = cfg$cross_sectional$signif_test,
                           font_family = cfg$plot$font_family)
     save_plot(plot = p, out_stem = file.path(out_dir, box_cfg$file), plot_cfg = cfg$plot)
}

# Scatter ####
message("cross_sectional:: !> Scatter plot")
p <- plot_ldl_scatter(data = baseline, ldl_col = cfg$cohort$ldl_col,
                      scatter_cfg = cfg$cross_sectional$scatter,
                      ldl_cfg = cfg$ldl, plot_cfg = cfg$plot)
save_plot(plot = p, out_stem = file.path(out_dir, cfg$cross_sectional$scatter$file), plot_cfg = cfg$plot)

message("cross_sectional:: !> Done")
