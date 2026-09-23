#############################
# plot_model_predictions
#   -- model-predicted outcome trajectories over time, faceted by amyloid status
# ARGUMENTS -- model (lmerMod), pred_cfg (list), axes_cfg (list), font_family (character)
#   > model: fitted mixed model
#   > pred_cfg: one entry of cfg$longitudinal$prediction_plots (terms, colors)
#   > axes_cfg: cfg$longitudinal$prediction_axes
#   > font_family: cfg$plot$font_family
# RETURNS -- ggplot object
# NOTES -- Packages: sjPlot, ggplot2. Replacing sjPlot's y scale emits a
#          "Scale for y is already present" message; it is expected.
#############################

plot_model_predictions <- function(
          model,
          pred_cfg,
          axes_cfg,
          font_family
) {

     # Validate inputs ####
     if (!inherits(model, "merMod")) stop("[plot_model_predictions] model must be a merMod, got: ", class(model)[1])
     if (is.null(pred_cfg$terms) || is.null(pred_cfg$colors)) {
          stop("[plot_model_predictions] pred_cfg needs terms and colors")
     }
     if (!requireNamespace("sjPlot", quietly = TRUE)) {
          stop("[plot_model_predictions] package 'sjPlot' is required but not installed")
     }

     # Build plot ####
     sjPlot::plot_model(model = model,
                        type = "pred",
                        terms = pred_cfg$terms,
                        title = "",
                        legend.title = axes_cfg$legend_title,
                        colors = pred_cfg$colors) +
          ggplot2::labs(x = axes_cfg$x_label, y = axes_cfg$y_label) +
          ggplot2::coord_cartesian(xlim = axes_cfg$x_limits, ylim = axes_cfg$y_limits) +
          ggplot2::scale_y_continuous(breaks = axes_cfg$y_breaks, expand = c(0, 0)) +
          ggplot2::scale_x_continuous(breaks = axes_cfg$x_breaks, expand = c(0, 0)) +
          theme_ldl_trajectory(font_family = font_family)
}
