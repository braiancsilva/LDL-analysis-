#############################
# assign_ldl_group
#   -- bin continuous LDL-C (mmol/L) into the clinical categories of cfg$ldl
# ARGUMENTS -- x (numeric), ldl_cfg (list), labels (character)
#   > x: LDL-C values in mmol/L
#   > ldl_cfg: cfg$ldl -- carries breaks, right, reference
#   > labels: one label per interval (cfg$ldl$labels or cfg$ldl$display_labels)
# RETURNS -- factor: one level per interval, first level = the reference category
# NOTES -- the reference is matched by position, so display labels keep the same
#          reference as the plain labels.
#############################

assign_ldl_group <- function(
          x,
          ldl_cfg,
          labels
) {

     # Validate inputs ####
     if (!is.numeric(x)) stop("[assign_ldl_group] x must be numeric, got: ", class(x)[1])
     if (!is.list(ldl_cfg) || is.null(ldl_cfg$breaks)) {
          stop("[assign_ldl_group] ldl_cfg$breaks is missing")
     }
     if (length(labels) != length(ldl_cfg$breaks) - 1L) {
          stop("[assign_ldl_group] need ", length(ldl_cfg$breaks) - 1L,
               " labels for ", length(ldl_cfg$breaks), " breaks, got: ", length(labels))
     }
     ref_pos <- match(ldl_cfg$reference, ldl_cfg$labels)
     if (is.na(ref_pos)) stop("[assign_ldl_group] reference not in ldl_cfg$labels: ", ldl_cfg$reference)

     # Bin ####
     groups <- cut(x = x, breaks = ldl_cfg$breaks, labels = labels, right = ldl_cfg$right)
     stats::relevel(groups, ref = labels[ref_pos])
}
