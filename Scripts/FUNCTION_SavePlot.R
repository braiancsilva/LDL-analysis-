#############################
# save_plot
#   -- write one ggplot to every format in cfg$plot$formats
# ARGUMENTS -- plot (ggplot), out_stem (character), plot_cfg (list)
#   > plot: the figure
#   > out_stem: output path without extension
#   > plot_cfg: cfg$plot (width, height, dpi, formats)
# RETURNS -- character: files written, invisibly
#############################

save_plot <- function(
          plot,
          out_stem,
          plot_cfg
) {

     # Validate inputs ####
     if (!inherits(plot, "ggplot")) stop("[save_plot] plot must be a ggplot, got: ", class(plot)[1])
     if (!dir.exists(dirname(out_stem))) stop("[save_plot] output directory missing: ", dirname(out_stem))

     # Write files ####
     files <- paste0(out_stem, ".", plot_cfg$formats)
     for (f in files) {
          ggplot2::ggsave(filename = f, plot = plot, width = plot_cfg$width,
                          height = plot_cfg$height, dpi = plot_cfg$dpi)
     }
     message(sprintf("[save_plot] Wrote %s", paste(basename(files), collapse = ", ")))

     invisible(files)
}
