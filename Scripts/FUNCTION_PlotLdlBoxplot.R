#############################
# plot_ldl_boxplot
#   -- baseline outcome by LDL-C group, with adjacent-group significance bars
# PURPOSE
#   > Draw one of Figures 1d-1f: a boxplot of a baseline outcome across LDL-C
#     categories, annotated with pairwise tests between adjacent categories.
# REQUIREMENTS
#   > Packages: ggplot2, ggsignif
# ARGUMENTS
#   > data (data.frame) -- baseline table
#   > outcome (character) -- outcome column
#   > group_col (character) -- LDL-C group column carrying display labels
#   > box_cfg (list) -- one entry of cfg$cross_sectional$boxplots
#   > colors (character) -- named by group level (cfg$ldl$colors)
#   > signif_test (character) -- test passed to ggsignif (default: "wilcox.test")
#   > font_family (character) -- cfg$plot$font_family
# RETURNS
#   > ggplot object
# NOTES
#   > box_cfg$limit_mode "scale" removes observations outside y_limits BEFORE the
#     box statistics and significance tests are computed; "coord" only zooms.
#   > Comparisons involving a group with < 2 observations are skipped with a
#     warning: one failing test would make ggsignif drop every bar.
#   > Bar heights: signif_y_start + signif_y_step * (0, 1, ...), one per
#     comparison, so the layout adapts to the number of LDL-C groups.
#############################

plot_ldl_boxplot <- function(
          data,
          outcome,
          group_col,
          box_cfg,
          colors,
          signif_test = "wilcox.test",
          font_family
) {

     # Validate inputs ####
     if (!is.data.frame(data)) stop("[plot_ldl_boxplot] data must be a data.frame, got: ", class(data)[1])
     missing_cols <- setdiff(c(outcome, group_col), names(data))
     if (length(missing_cols) > 0L) {
          stop("[plot_ldl_boxplot] columns not in data: ", paste(missing_cols, collapse = ", "))
     }
     if (!is.factor(data[[group_col]])) stop("[plot_ldl_boxplot] group column must be a factor: ", group_col)
     limit_mode <- match.arg(arg = box_cfg$limit_mode, choices = c("scale", "coord"))

     # Adjacent comparisons ####
     group_levels <- levels(data[[group_col]])
     comparisons  <- lapply(seq_len(length(group_levels) - 1L), function(i) group_levels[c(i, i + 1L)])

     n_by_group <- table(data[[group_col]][!is.na(data[[outcome]])])
     testable   <- vapply(comparisons, function(pair) all(n_by_group[pair] >= 2L), logical(1))
     if (!all(testable)) {
          warning(sprintf("[plot_ldl_boxplot] %s: skipping comparison(s) with < 2 observations: %s",
                          outcome, paste(vapply(comparisons[!testable], paste, character(1), collapse = " vs "),
                                         collapse = "; ")))
          comparisons <- comparisons[testable]
     }

     y_position <- NULL
     if (!is.null(box_cfg$signif_y_start) && length(comparisons) > 0L) {
          y_position <- box_cfg$signif_y_start + box_cfg$signif_y_step * (seq_along(comparisons) - 1L)
     }

     # Build plot ####
     y_axis <- switch(limit_mode,
                      scale = ggplot2::scale_y_continuous(limits = box_cfg$y_limits, expand = c(0, 0)),
                      coord = ggplot2::coord_cartesian(ylim = box_cfg$y_limits))

     ggplot2::ggplot(data = data,
                     mapping = ggplot2::aes(x = .data[[group_col]], y = .data[[outcome]],
                                            group = .data[[group_col]],
                                            color = .data[[group_col]], fill = .data[[group_col]])) +
          ggplot2::geom_boxplot(alpha = 0.2, outlier.shape = NA) +
          ggplot2::labs(title = box_cfg$title, x = "", y = box_cfg$y_label) +
          y_axis +
          ggplot2::scale_color_manual(values = colors) +
          ggplot2::scale_fill_manual(values = colors) +
          theme_ldl_boxplot(font_family = font_family) +
          (if (length(comparisons) > 0L) ggsignif::geom_signif(comparisons = comparisons,
                                test = signif_test,
                                map_signif_level = TRUE, step_increase = 0.08, size = 0.5,
                                color = "black", family = font_family, textsize = 3.5,
                                y_position = y_position))
}
