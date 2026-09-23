#############################
# run_longitudinal.R
#   -- runner: LDL-C x amyloid x time mixed models and trajectory figures
# PURPOSE
#   > Fit every model in cfg$longitudinal$models (cognition, CSF p-tau and CSF
#     Abeta; categorical and continuous LDL-C), write their summaries, and draw
#     the predicted-trajectory figures listed in cfg$longitudinal$prediction_plots.
# REQUIREMENTS
#   > Packages: readxl, lme4, lmerTest, sjPlot, ggplot2
#   > Inputs  : cfg$paths$data_file (individual-level, gitignored)
# USAGE
#   > Rscript Scripts/run_longitudinal.R
#     or source("Scripts/run_longitudinal.R") from RStudio
# NOTES
#   > Writes to cfg$paths$longitudinal (gitignored Outputs/).
#############################

# Resolve script directory ####
file_arg   <- grep(pattern = "^--file=", x = commandArgs(trailingOnly = FALSE), value = TRUE)
script_dir <- if (length(file_arg) == 1L) {
     dirname(normalizePath(sub(pattern = "^--file=", replacement = "", x = file_arg)))
} else if (!is.null(sys.frame(1)$ofile)) {
     dirname(normalizePath(sys.frame(1)$ofile))
} else {
     file.path(Sys.getenv("LDL_ANALYSIS_ROOT", unset = getwd()), "Scripts")
}

# Load configuration and functions ####
source(file.path(script_dir, "config_ldl_analysis.R"))
for (f in list.files(path = script_dir, pattern = "^FUNCTION_.*\\.R$", full.names = TRUE)) source(f)

out_dir <- cfg$paths$longitudinal
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
message("longitudinal:: !> Writing to ", out_dir)

# Load cohort ####
cohort <- load_cohort(data_file = cfg$paths$data_file, cohort_cfg = cfg$cohort, ldl_cfg = cfg$ldl)

# Fit models ####
fits <- list()
for (model_name in names(cfg$longitudinal$models)) {
     message("longitudinal:: !> Model ", model_name)
     fits[[model_name]] <- fit_longitudinal_model(data = cohort$long,
                                                  spec = cfg$longitudinal$models[[model_name]],
                                                  covariates = cfg$longitudinal$covariates,
                                                  time_col = cfg$cohort$time_col,
                                                  modifier_col = cfg$cohort$amyloid_col,
                                                  reml = cfg$longitudinal$reml,
                                                  optimizer = cfg$longitudinal$optimizer)
     write_model_outputs(fit = fits[[model_name]], model_name = model_name, out_dir = out_dir)
}

# Sample sizes ####
model_n <- data.frame(model    = names(fits),
                      formula  = vapply(fits, function(x) x$formula, character(1)),
                      n_obs    = vapply(fits, function(x) x$n_obs, integer(1)),
                      n_groups = vapply(fits, function(x) as.integer(x$n_groups[[1]]), integer(1)),
                      row.names = NULL, stringsAsFactors = FALSE)
utils::write.csv(x = model_n, file = file.path(out_dir, "model_sample_sizes.csv"), row.names = FALSE)

# Predicted trajectories ####
for (model_name in names(cfg$longitudinal$prediction_plots)) {
     message("longitudinal:: !> Trajectory plot ", model_name)
     pred_cfg <- cfg$longitudinal$prediction_plots[[model_name]]
     p <- plot_model_predictions(model = fits[[model_name]]$model, pred_cfg = pred_cfg,
                                 axes_cfg = cfg$longitudinal$prediction_axes,
                                 font_family = cfg$plot$font_family)
     save_plot(plot = p, out_stem = file.path(out_dir, pred_cfg$file), plot_cfg = cfg$plot)
}

message("longitudinal:: !> Done")
