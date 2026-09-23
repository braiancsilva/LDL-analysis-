#############################
# fit_longitudinal_model
#   -- fit one exposure x amyloid x time linear mixed model
# PURPOSE
#   > Build the model formula from a cfg model spec and fit it with lmerTest,
#     so summary() and anova() report Satterthwaite-df p-values.
# REQUIREMENTS
#   > Packages: lme4, lmerTest
# ARGUMENTS
#   > data (data.frame) -- long table, one row per visit
#   > spec (list) -- one entry of cfg$longitudinal$models (outcome, exposure, random)
#   > covariates (character) -- each enters as covariate * time
#   > time_col (character) -- follow-up time column
#   > modifier_col (character) -- amyloid column interacted with exposure and time
#   > reml (logical) -- REML fit (default: TRUE)
#   > optimizer (character) -- lme4 optimizer (default: "Nelder_Mead")
# RETURNS
#   > list: model (lmerModLmerTest), formula (character), n_obs, n_groups
# NOTES
#   > Formula: outcome ~ exposure * modifier * time + sum(covariate * time) + random.
#   > modifier_col is used as stored (0/1 numeric), matching the original script.
#############################

fit_longitudinal_model <- function(
          data,
          spec,
          covariates,
          time_col,
          modifier_col,
          reml = TRUE,
          optimizer = "Nelder_Mead"
) {

     # Validate inputs ####
     if (!is.data.frame(data)) stop("[fit_longitudinal_model] data must be a data.frame, got: ", class(data)[1])
     for (field in c("outcome", "exposure", "random")) {
          if (is.null(spec[[field]])) stop("[fit_longitudinal_model] spec$", field, " is missing")
     }
     missing_cols <- setdiff(c(spec$outcome, spec$exposure, covariates, time_col, modifier_col), names(data))
     if (length(missing_cols) > 0L) {
          stop("[fit_longitudinal_model] columns not in data: ", paste(missing_cols, collapse = ", "))
     }
     for (pkg in c("lme4", "lmerTest")) {
          if (!requireNamespace(pkg, quietly = TRUE)) {
               stop("[fit_longitudinal_model] package '", pkg, "' is required but not installed")
          }
     }

     # Build formula ####
     fixed_terms <- c(paste(spec$exposure, modifier_col, time_col, sep = " * "),
                      paste(covariates, time_col, sep = " * "))
     formula_str <- paste(spec$outcome, "~", paste(c(fixed_terms, spec$random), collapse = " + "))
     message(sprintf("[fit_longitudinal_model] %s", formula_str))

     # Fit ####
     model <- lmerTest::lmer(formula = stats::as.formula(formula_str),
                             data = data,
                             REML = reml,
                             control = lme4::lmerControl(optimizer = optimizer))

     n_groups <- lme4::ngrps(model)
     message(sprintf("[fit_longitudinal_model] n_obs = %d, n_groups = %s",
                     stats::nobs(model), paste(n_groups, collapse = ", ")))

     list(
          model    = model,
          formula  = formula_str,
          n_obs    = stats::nobs(model),
          n_groups = n_groups
     )
}
