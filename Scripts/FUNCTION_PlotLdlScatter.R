#############################
# plot_ldl_scatter
#   -- continuous LDL-C vs a baseline outcome, coloured by amyloid status
# ARGUMENTS -- data (data.frame), ldl_col (character), scatter_cfg (list), ldl_cfg (list), plot_cfg (list)
#   > data: baseline table carrying amyloid_status
#   > ldl_col: continuous LDL-C column
#   > scatter_cfg: cfg$cross_sectional$scatter
#   > ldl_cfg: cfg$ldl -- the finite breaks are drawn as dashed cut-off lines
#   > plot_cfg: cfg$plot
# RETURNS -- ggplot object
# NOTES -- Packages: ggplot2. One linear fit per amyloid group.
#############################

plot_ldl_scatter <- function(
          data,
          ldl_col,
          scatter_cfg,
          ldl_cfg,
          plot_cfg
) {

     # Validate inputs ####
     if (!is.data.frame(data)) stop("[plot_ldl_scatter] data must be a data.frame, got: ", class(data)[1])
     missing_cols <- setdiff(c(ldl_col, scatter_cfg$outcome, "amyloid_status"), names(data))
     if (length(missing_cols) > 0L) {
          stop("[plot_ldl_scatter] columns not in data: ", paste(missing_cols, collapse = ", "))
     }
     if (length(scatter_cfg$band_label_x) != length(scatter_cfg$band_labels)) {
          stop("[plot_ldl_scatter] band_label_x and band_labels differ in length: ",
               length(scatter_cfg$band_label_x), " vs ", length(scatter_cfg$band_labels))
     }

     # Build plot ####
     cutoffs <- ldl_cfg$breaks[is.finite(ldl_cfg$breaks)]

     ggplot2::ggplot(data = data,
                     mapping = ggplot2::aes(x = .data[[ldl_col]], y = .data[[scatter_cfg$outcome]],
                                            color = .data[["amyloid_status"]])) +
          ggplot2::geom_point(alpha = 0.5, size = 2) +
          ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE, linewidth = 1) +
          ggplot2::labs(title = scatter_cfg$title, x = scatter_cfg$x_label, y = scatter_cfg$y_label) +
          ggplot2::geom_vline(xintercept = cutoffs, linetype = "dashed", color = "grey50", linewidth = 0.4) +
          ggplot2::annotate(geom = "text", x = scatter_cfg$band_label_x, y = Inf,
                            label = scatter_cfg$band_labels, vjust = 1.5, size = 2.5,
                            family = plot_cfg$font_family, color = "grey40") +
          ggplot2::scale_color_manual(values = plot_cfg$amyloid_colors) +
          theme_ldl_scatter(font_family = plot_cfg$font_family)
}
