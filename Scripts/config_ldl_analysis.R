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
#   > The LDL-C categorisation is a sensitivity axis, chosen with env var
#     LDL_SCHEME (default "ncep5", the primary). A non-primary scheme writes to
#     suffixed output directories (Outputs/*_<suffix>) and never overwrites the
#     primary run.
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

# LDL-C categorisation schemes ####
# Intervals are left-closed: [2.6, 3.3) is "Near optimal". The first label is the
# model reference level. band_label_x places the scatter-plot band labels.
ldl_schemes <- list(

     # D-001 -- primary. NCEP ATP III classes (100/130/160/190 mg/dL) in mmol/L,
     # rounded as in the original script (see grilling.md on 3.3 vs 3.36).
     ncep5 = list(
          suffix         = "",
          breaks         = c(-Inf, 2.6, 3.3, 4.1, 4.9, Inf),
          labels         = c("Optimal", "Near optimal", "Borderline high", "High", "Very high"),
          display_labels = c("Optimal\n(<2.6)",
                             "Near optimal\n(2.6-3.3)",
                             "Borderline high\n(3.3-4.1)",
                             "High\n(4.1-4.9)",
                             "Very high\n(\u22654.9)"),
          colors         = c("#2E8B57", "#F2AD00", "#F98400", "#B40F20", "#7B0051"),
          band_label_x   = c(1.3, 2.95, 3.7, 4.5, 5.5),
          band_labels    = c("Optimal", "Near\noptimal", "Borderline\nhigh", "High", "Very\nhigh")
     ),

     # D-003 -- sensitivity. The three NCEP classes at or above 130 mg/dL merged,
     # because High (n = 8) and Very high (n = 3) are too sparse to estimate.
     ncep3 = list(
          suffix         = "ldl3",
          breaks         = c(-Inf, 2.6, 3.3, Inf),
          labels         = c("Optimal", "Near optimal", "Borderline high or above"),
          display_labels = c("Optimal\n(<2.6)",
                             "Near optimal\n(2.6-3.3)",
                             "Borderline high\nor above (\u22653.3)"),
          colors         = c("#2E8B57", "#F2AD00", "#B40F20"),
          band_label_x   = c(1.3, 2.95, 4.5),
          band_labels    = c("Optimal", "Near\noptimal", "Borderline\nhigh or above")
     )
)

ldl_scheme_name <- Sys.getenv("LDL_SCHEME", unset = "ncep5")
if (!ldl_scheme_name %in% names(ldl_schemes)) {
     stop("config_ldl_analysis.R:: !> unknown LDL_SCHEME: ", ldl_scheme_name,
          " (choose from: ", paste(names(ldl_schemes), collapse = ", "), ")")
}
ldl_scheme <- ldl_schemes[[ldl_scheme_name]]
out_suffix <- if (nzchar(ldl_scheme$suffix)) paste0("_", ldl_scheme$suffix) else ""

# Build cfg ####
cfg <- list(

     paths = list(
          root            = proj_root,
          data_file       = normalizePath(data_file, mustWork = FALSE),
          out_dir         = file.path(proj_root, "Outputs"),
          cross_sectional = file.path(proj_root, "Outputs", paste0("cross_sectional", out_suffix)),
          longitudinal    = file.path(proj_root, "Outputs", paste0("longitudinal", out_suffix))
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
          scheme         = ldl_scheme_name,
          is_primary     = !nzchar(ldl_scheme$suffix),
          breaks         = ldl_scheme$breaks,
          right          = FALSE,
          labels         = ldl_scheme$labels,
          display_labels = ldl_scheme$display_labels,
          reference      = ldl_scheme$labels[1],
          colors         = stats::setNames(ldl_scheme$colors, ldl_scheme$display_labels)
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
          # signif_y_start/step place the adjacent-pair bars at start, start +
          # step, ... (one per comparison); NULL lets ggsignif place them.
          boxplots = list(
               ABETA_bl_to_use = list(file = "fig1d_abeta_by_ldl_group", title = "Figure 1d",
                                      y_label = "CSF ABETA 42", y_limits = c(0, 2300),
                                      limit_mode = "scale", signif_y_start = NULL, signif_y_step = NULL),
               PTAU_bl_to_use  = list(file = "fig1e_ptau_by_ldl_group", title = "Figure 1e",
                                      y_label = "CSF PTAU", y_limits = c(0, 60),
                                      limit_mode = "coord", signif_y_start = 42, signif_y_step = 3),
               mPACCtrailsB_bl = list(file = "fig1f_mpacc_by_ldl_group", title = "Figure 1f",
                                      y_label = "mPACCtrailsB", y_limits = c(-8, 8),
                                      limit_mode = "scale", signif_y_start = NULL, signif_y_step = NULL)
          ),
          scatter = list(
               file         = "scatter_ldl_vs_mpacc_by_amyloid",
               outcome      = "mPACCtrailsB_bl",
               title        = "LDL-C vs Cognitive Score by Amyloid Status",
               x_label      = "LDL-C (mmol/L)",
               y_label      = "mPACCtrailsB",
               band_label_x = ldl_scheme$band_label_x,
               band_labels  = ldl_scheme$band_labels
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
          # A non-primary LDL scheme runs only the ldl_group models: the
          # continuous ones do not depend on the scheme.
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
                                      colors = ldl_scheme$colors),
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
                          "ldl_schemes", "ldl_scheme_name", "ldl_scheme", "out_suffix"),
                    y = ls()))
