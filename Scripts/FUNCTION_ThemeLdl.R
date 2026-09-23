#############################
# theme_ldl_boxplot
#   -- shared theme for the baseline LDL-C group boxplots (Figures 1d-1f)
# ARGUMENTS -- font_family (character)
#   > font_family: cfg$plot$font_family
# RETURNS -- ggplot2 theme
# NOTES -- built on theme_light(), a recorded deviation from the theme_classic()
#          rule (STYLE.md § Known Deviations).
#############################

theme_ldl_boxplot <- function(
          font_family
) {

     # Validate inputs ####
     if (!is.character(font_family) || length(font_family) != 1L) {
          stop("[theme_ldl_boxplot] font_family must be a single string, got: ", paste(font_family, collapse = ", "))
     }

     # Build theme ####
     ggplot2::theme_light() +
          ggplot2::theme(
               panel.grid.major  = ggplot2::element_blank(),
               axis.text.x       = ggplot2::element_text(size = 12, family = font_family, colour = "black"),
               axis.title.y      = ggplot2::element_text(size = 20, family = font_family, colour = "black"),
               axis.text.y       = ggplot2::element_text(size = 17, family = font_family, colour = "black"),
               legend.text       = ggplot2::element_text(size = 12, family = font_family, colour = "black"),
               legend.title      = ggplot2::element_blank(),
               legend.position   = "right",
               legend.background = ggplot2::element_rect(fill = "white", linetype = "solid",
                                                         linewidth = 0.5, color = "grey")
          )
}

#############################
# theme_ldl_scatter
#   -- theme for the LDL-C vs cognition scatter plot
# ARGUMENTS -- font_family (character)
#   > font_family: cfg$plot$font_family
# RETURNS -- ggplot2 theme
#############################

theme_ldl_scatter <- function(
          font_family
) {

     # Validate inputs ####
     if (!is.character(font_family) || length(font_family) != 1L) {
          stop("[theme_ldl_scatter] font_family must be a single string, got: ", paste(font_family, collapse = ", "))
     }

     # Build theme ####
     ggplot2::theme_light() +
          ggplot2::theme(
               panel.grid.major  = ggplot2::element_blank(),
               axis.text         = ggplot2::element_text(size = 14, family = font_family, colour = "black"),
               axis.title        = ggplot2::element_text(size = 16, family = font_family, colour = "black"),
               legend.text       = ggplot2::element_text(size = 14, family = font_family, colour = "black"),
               legend.title      = ggplot2::element_blank(),
               legend.position   = "right",
               legend.background = ggplot2::element_rect(fill = "white", linetype = "solid",
                                                         linewidth = 0.5, color = "grey")
          )
}

#############################
# theme_ldl_trajectory
#   -- theme for the model-predicted trajectory figures
# ARGUMENTS -- font_family (character)
#   > font_family: cfg$plot$font_family
# RETURNS -- ggplot2 theme
#############################

theme_ldl_trajectory <- function(
          font_family
) {

     # Validate inputs ####
     if (!is.character(font_family) || length(font_family) != 1L) {
          stop("[theme_ldl_trajectory] font_family must be a single string, got: ", paste(font_family, collapse = ", "))
     }

     # Build theme ####
     ggplot2::theme_light() +
          ggplot2::theme(
               text               = ggplot2::element_text(size = 11, family = font_family, colour = "black"),
               plot.title         = ggplot2::element_text(size = 14, family = font_family),
               axis.ticks         = ggplot2::element_line(colour = "black", linewidth = 0.8),
               axis.text.y        = ggplot2::element_text(size = 11, family = font_family, colour = "black"),
               axis.text.x        = ggplot2::element_text(size = 11, family = font_family, colour = "black"),
               axis.title.y       = ggplot2::element_text(size = 12, family = font_family, colour = "black",
                                                          margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0)),
               axis.title.x       = ggplot2::element_text(size = 12, family = font_family, colour = "black",
                                                          margin = ggplot2::margin(t = 10, r = 0, b = 0, l = 0)),
               axis.line          = ggplot2::element_line(colour = "black", linewidth = 0.2),
               panel.grid.major.y = ggplot2::element_line(colour = "gray", linewidth = 0.2),
               panel.grid.major.x = ggplot2::element_blank(),
               panel.grid.minor   = ggplot2::element_blank(),
               legend.position    = "bottom",
               legend.background  = ggplot2::element_rect(linewidth = 0.3, linetype = "solid", colour = "black"),
               strip.background   = ggplot2::element_rect(fill = "gray80", colour = "black", linewidth = 0.2),
               strip.text         = ggplot2::element_text(size = 12, family = font_family, colour = "black", face = "bold")
          )
}
