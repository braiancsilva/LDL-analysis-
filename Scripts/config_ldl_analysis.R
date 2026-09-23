#############################
# config_ldl_analysis.R
#   -- single source of every path, cutoff, covariate set and plot setting
# PURPOSE
#   > Builds the nested list `cfg`, source()d by every runner (run_*.R).
#     No runner or FUNCTION_*.R file hard-codes a value that lives here.
# REQUIREMENTS
#   > Packages: none
# NOTES
#   > Project root resolves in this order:
#       1. env var LDL_ANALYSIS_ROOT
#       2. the parent of the directory holding this file (when source()d)
#   > The data file defaults to <root>/Data/cognition_LDL_C.xlsx and can be
#     overridden with env var LDL_ANALYSIS_DATA. It is individual-level ADNI
#     data and is gitignored -- never commit it (STYLE.md § Data Handling).
#   > Fields carrying a recorded design decision cite its D-NNN (DECISIONS.md).
#############################

# Resolve project root ####
config_file <- NULL
for (frame_idx in rev(seq_len(sys.nframe()))) {
     ofile <- sys.frame(frame_idx)$ofile
     if (!is.null(ofile)) {
          config_file <- ofile
          break
     }
}

proj_root <- Sys.getenv("LDL_ANALYSIS_ROOT", unset = "")
if (!nzchar(proj_root)) {
     if (is.null(config_file)) {
          stop("config_ldl_analysis.R:: !> cannot locate the project root; ",
               "source() this file or set LDL_ANALYSIS_ROOT. Working directory: ", getwd())
     }
     proj_root <- dirname(dirname(normalizePath(config_file)))
}
proj_root <- normalizePath(proj_root, mustWork = TRUE)

data_file <- Sys.getenv("LDL_ANALYSIS_DATA",
                        unset = file.path(proj_root, "Data", "cognition_LDL_C.xlsx"))

# LDL-C categories (D-001) ####
# NCEP ATP III LDL-C classes, converted from mg/dL (100/130/160/190) to mmol/L.
# Intervals are left-closed: [2.6, 3.3) is "Near optimal".
ldl_labels         <- c("Optimal", "Near optimal", "Borderline high", "High", "Very high")
ldl_display_labels <- c("Optimal\n(<2.6)",
                        "Near optimal\n(2.6-3.3)",
                        "Borderline high\n(3.3-4.1)",
                        "High\n(4.1-4.9)",
                        "Very high\n(≥4.9)")
ldl_colors         <- c("#2E8B57", "#F2AD00", "#F98400", "#B40F20", "#7B0051")

# Build cfg ####
cfg <- list(

     paths = list(
          root            = proj_root,
          data_file       = normalizePath(data_file, mustWork = FALSE),
          out_dir         = file.path(proj_root, "Outputs"),
          cross_sectional = file.path(proj_root, "Outputs", "cross_sectional"),
          longitudinal    = file.path(proj_root, "Outputs", "longitudinal")
     ),

     # Cohort definition ####
     cohort = list(
          id_col        = "RID",
          age_col       = "AGE",
          time_col      = "Years_bl_to_use",
          ldl_col       = "CLINICAL_LDL_C",
          amyloid_col   = "ABETA_positivity_ratio",
          min_age       = 65,
          baseline_time = 0,
          # Amyloid coding: 1 = positive by the p-tau/Abeta ratio.
          amyloid_levels = c(negative = "(A)-", positive = "(A)+"),
          # Read as text in the xlsx (censored strings such as ">1700", "<8");
          # coerced to numeric, and any value lost to NA raises a warning.
          numeric_cols  = c("ABETA_bl_to_use", "PTAU_bl_to_use", "mPACCtrailsB_bl",
                            "ABETA", "PTAU")
     ),

     ldl = list(
          breaks         = c(-Inf, 2.6, 3.3, 4.1, 4.9, Inf),
          right          = FALSE,
          labels         = ldl_labels,
          display_labels = ldl_display_labels,
          reference      = "Optimal",
          colors         = stats::setNames(ldl_colors, ldl_display_labels)
     ),

     # Cross-sectional (baseline) stage ####
     demographics = list(
          vars = c("AGE", "CLINICAL_LDL_C", "PTGENDER", "PTEDUCAT", "APOE4_status",
                   "MMSE", "ABETA_to_use", "PTAU_to_use")
     ),

     cross_sectional = list(
          outcomes    = c("ABETA_bl_to_use", "PTAU_bl_to_use", "mPACCtrailsB_bl"),
          p_adjust    = "bonferroni",
          signif_test = "wilcox.test",
          # One entry per boxplot figure. limit_mode "scale" drops observations
          # outside y_limits before the box statistics are computed; "coord"
          # only zooms. Kept as in the original script -- see grilling.md.
          boxplots = list(
               ABETA_bl_to_use = list(file = "fig1d_abeta_by_ldl_group", title = "Figure 1d",
                                      y_label = "CSF ABETA 42", y_limits = c(0, 2300),
                                      limit_mode = "scale", signif_y_position = NULL),
               PTAU_bl_to_use  = list(file = "fig1e_ptau_by_ldl_group", title = "Figure 1e",
                                      y_label = "CSF PTAU", y_limits = c(0, 60),
                                      limit_mode = "coord", signif_y_position = c(42, 45, 48, 51)),
               mPACCtrailsB_bl = list(file = "fig1f_mpacc_by_ldl_group", title = "Figure 1f",
                                      y_label = "mPACCtrailsB", y_limits = c(-8, 8),
                                      limit_mode = "scale", signif_y_position = NULL)
          ),
          scatter = list(
               file         = "scatter_ldl_vs_mpacc_by_amyloid",
               outcome      = "mPACCtrailsB_bl",
               title        = "LDL-C vs Cognitive Score by Amyloid Status",
               x_label      = "LDL-C (mmol/L)",
               y_label      = "mPACCtrailsB",
               band_label_x = c(1.3, 2.95, 3.7, 4.5, 5.5),
               band_labels  = c("Optimal", "Near\noptimal", "Borderline\nhigh", "High", "Very\nhigh")
          )
     ),

     # Longitudinal stage ####
     longitudinal = list(
          reml       = TRUE,
          optimizer  = "Nelder_Mead",
          # Each covariate enters as covariate * time.
          covariates = c("AGE", "PTGENDER", "APOE4_status", "PTEDUCAT"),
          # exposure * amyloid * time + covariates * time + random.
          # ldl_group is the categorical exposure; CLINICAL_LDL_C the continuous one.
          models = list(
               mpacc_ldl_group = list(outcome = "mPACCtrailsB", exposure = "ldl_group",
                                      random = "(1 + Years_bl_to_use | RID)"),
               mpacc_ldl_cont  = list(outcome = "mPACCtrailsB", exposure = "CLINICAL_LDL_C",
                                      random = "(1 + Years_bl_to_use | RID)"),
               ptau_ldl_group  = list(outcome = "PTAU", exposure = "ldl_group",
                                      random = "(1 + Years_bl_to_use | RID)"),
               ptau_ldl_cont   = list(outcome = "PTAU", exposure = "CLINICAL_LDL_C",
                                      random = "(1 + Years_bl_to_use | RID)"),
               abeta_ldl_group = list(outcome = "ABETA", exposure = "ldl_group",
                                      random = "(1 | RID)"),
               abeta_ldl_cont  = list(outcome = "ABETA", exposure = "CLINICAL_LDL_C",
                                      random = "(1 | RID)")
          ),
          # Predicted-trajectory figures, keyed by model name.
          prediction_plots = list(
               mpacc_ldl_group = list(file   = "pred_mpacc_ldl_group",
                                      terms  = c("Years_bl_to_use", "ldl_group", "ABETA_positivity_ratio"),
                                      colors = ldl_colors),
               mpacc_ldl_cont  = list(file   = "pred_mpacc_ldl_cont",
                                      terms  = c("Years_bl_to_use", "CLINICAL_LDL_C [meansd]", "ABETA_positivity_ratio"),
                                      colors = c("#2E8B57", "#F2AD00", "#B40F20"))
          ),
          prediction_axes = list(
               legend_title = "LDL-C",
               x_label      = "Time from baseline (years)",
               y_label      = "mPACC score",
               x_limits     = c(0, 6),
               y_limits     = c(-6, 2),
               x_breaks     = seq(0, 6, 1),
               y_breaks     = seq(-8, 4, 2)
          )
     ),

     # Plot output ####
     plot = list(
          font_family    = "Helvetica",
          amyloid_colors = c("(A)-" = "#2E8B57", "(A)+" = "#B40F20"),
          width          = 8,
          height         = 6,
          dpi            = 300L,
          formats        = c("pdf", "png")
     )
)

rm(list = intersect(x = c("config_file", "frame_idx", "ofile", "proj_root", "data_file",
                          "ldl_labels", "ldl_display_labels", "ldl_colors"),
                    y = ls()))
