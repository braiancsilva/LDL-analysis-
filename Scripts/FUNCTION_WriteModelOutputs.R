#############################
# write_model_outputs
#   -- write summary, fixed effects, type III ANOVA and an HTML table for one model
# ARGUMENTS -- fit (list), model_name (character), out_dir (character)
#   > fit: return value of fit_longitudinal_model()
#   > model_name: file stem, a key of cfg$longitudinal$models
#   > out_dir: existing output directory
# RETURNS -- list, invisibly: fixed_effects, anova (data.frames)
# NOTES -- Packages: lmerTest, sjPlot. ANOVA is type III, Satterthwaite df.
#############################

write_model_outputs <- function(
          fit,
          model_name,
          out_dir
) {

     # Validate inputs ####
     if (!is.list(fit) || !inherits(fit$model, "lmerModLmerTest")) {
          stop("[write_model_outputs] fit$model must be an lmerModLmerTest, got: ", class(fit$model)[1])
     }
     if (!dir.exists(out_dir)) stop("[write_model_outputs] output directory missing: ", out_dir)
     if (!requireNamespace("sjPlot", quietly = TRUE)) {
          stop("[write_model_outputs] package 'sjPlot' is required but not installed")
     }

     stem <- file.path(out_dir, model_name)

     # Fixed effects ####
     coefs <- stats::coef(summary(fit$model))
     fixed_effects <- data.frame(term = rownames(coefs), coefs, check.names = FALSE,
                                 row.names = NULL, stringsAsFactors = FALSE)
     utils::write.csv(x = fixed_effects, file = paste0(stem, "_fixed_effects.csv"), row.names = FALSE)

     # Type III ANOVA ####
     aov <- stats::anova(fit$model, type = 3)
     anova_tbl <- data.frame(term = rownames(aov), as.data.frame(aov), check.names = FALSE,
                             row.names = NULL, stringsAsFactors = FALSE)
     utils::write.csv(x = anova_tbl, file = paste0(stem, "_anova_type3.csv"), row.names = FALSE)

     # Summary text ####
     writeLines(text = c(paste("Formula:", fit$formula), "",
                         utils::capture.output(print(summary(fit$model), correlation = FALSE))),
                con = paste0(stem, "_summary.txt"))

     # HTML table ####
     # tab_model() writes its file only when printed; write the page directly
     html <- sjPlot::tab_model(fit$model)
     writeLines(text = html$page.complete, con = paste0(stem, "_table.html"))

     message(sprintf("[write_model_outputs] Wrote %s_*", stem))
     invisible(list(
          fixed_effects = fixed_effects,
          anova         = anova_tbl
     ))
}
