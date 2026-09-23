#############################
# build_demographics_table
#   -- descriptive table stratified by one grouping column, written to disk
# ARGUMENTS -- data (data.frame), vars (character), strata_col (character), out_stem (character)
#   > data: one row per participant (the baseline table)
#   > vars: columns to describe
#   > strata_col: column to stratify by
#   > out_stem: output path without extension; writes <out_stem>.html and .csv
# RETURNS -- table1 object, invisibly
# NOTES -- Packages: table1.
#############################

build_demographics_table <- function(
          data,
          vars,
          strata_col,
          out_stem
) {

     # Validate inputs ####
     if (!is.data.frame(data)) stop("[build_demographics_table] data must be a data.frame, got: ", class(data)[1])
     missing_cols <- setdiff(c(vars, strata_col), names(data))
     if (length(missing_cols) > 0L) {
          stop("[build_demographics_table] columns not in data: ", paste(missing_cols, collapse = ", "))
     }
     if (!dir.exists(dirname(out_stem))) stop("[build_demographics_table] output directory missing: ", dirname(out_stem))
     if (!requireNamespace("table1", quietly = TRUE)) {
          stop("[build_demographics_table] package 'table1' is required but not installed")
     }

     # Build table ####
     tbl_formula <- stats::as.formula(paste("~", paste(vars, collapse = " + "), "|", strata_col))
     tbl <- table1::table1(x = tbl_formula, data = data)

     # Write outputs ####
     writeLines(text = as.character(tbl), con = paste0(out_stem, ".html"))
     utils::write.csv(x = as.data.frame(tbl), file = paste0(out_stem, ".csv"), row.names = FALSE)
     message(sprintf("[build_demographics_table] Wrote %s.{html,csv}", out_stem))

     invisible(tbl)
}
