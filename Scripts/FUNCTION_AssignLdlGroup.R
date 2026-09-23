#############################
# assign_ldl_group
#   -- bin continuous LDL-C (mmol/L) into the clinical categories of cfg$ldl
# ARGUMENTS -- x (numeric), ldl_cfg (list), labels (character), set_reference (logical)
#   > x: LDL-C values in mmol/L
#   > ldl_cfg: cfg$ldl -- carries breaks, right, reference
#   > labels: one label per interval (cfg$ldl$labels or cfg$ldl$display_labels)
#   > set_reference: move cfg$ldl$reference to the first level (default: TRUE)
# RETURNS -- factor: one level per interval
# NOTES -- use set_reference = FALSE for figure labels, so the levels stay in
#          clinical (ascending LDL-C) order whatever the model reference is.
#############################

assign_ldl_group <- function(
          x,
          ldl_cfg,
          labels,
          set_reference = TRUE
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
     if (set_reference) groups <- stats::relevel(groups, ref = labels[ref_pos])
     groups
}
