#############################
# load_cohort
#   -- read the ADNI LDL-C/cognition table and derive the analysis cohort
# PURPOSE
#   > Apply the inclusion rules (age, non-missing LDL-C), coerce text-stored
#     numeric columns, and derive the amyloid-status and LDL-C group columns
#     shared by every stage.
# REQUIREMENTS
#   > Packages: readxl
#   > Inputs  : cfg$paths$data_file (individual-level, gitignored)
# ARGUMENTS
#   > data_file (character) -- path to the xlsx
#   > cohort_cfg (list) -- cfg$cohort
#   > ldl_cfg (list) -- cfg$ldl
# RETURNS
#   > list: long (data.frame, all retained visits),
#           baseline (data.frame, rows at cohort_cfg$baseline_time)
# NOTES
#   > Derived columns: amyloid_status (factor, "(A)-"/"(A)+"), ldl_group
#     (factor, plain labels, reference level first, used in models) and
#     ldl_group_label (factor, display labels in clinical order, used in figures).
#   > Coercion to numeric warns with the count and the distinct values lost, so
#     censored assay strings (">1700", "<8") are never dropped silently.
#############################

load_cohort <- function(
          data_file,
          cohort_cfg,
          ldl_cfg
) {

     # Validate inputs ####
     if (!is.character(data_file) || length(data_file) != 1L || !file.exists(data_file)) {
          stop("[load_cohort] data file not found: ", data_file)
     }
     for (field in c("id_col", "age_col", "time_col", "ldl_col", "amyloid_col",
                     "min_age", "baseline_time", "amyloid_levels", "numeric_cols")) {
          if (is.null(cohort_cfg[[field]])) stop("[load_cohort] cohort_cfg$", field, " is missing")
     }

     # Load Libraries ####
     if (!requireNamespace("readxl", quietly = TRUE)) {
          stop("[load_cohort] package 'readxl' is required but not installed")
     }

     # Read ####
     message(sprintf("[load_cohort] Reading %s", data_file))
     raw <- as.data.frame(readxl::read_excel(path = data_file))

     required_cols <- c(cohort_cfg$id_col, cohort_cfg$age_col, cohort_cfg$time_col,
                        cohort_cfg$ldl_col, cohort_cfg$amyloid_col, cohort_cfg$numeric_cols)
     missing_cols <- setdiff(required_cols, names(raw))
     if (length(missing_cols) > 0L) {
          stop("[load_cohort] columns missing from data file: ", paste(missing_cols, collapse = ", "))
     }

     # Apply inclusion ####
     age  <- raw[[cohort_cfg$age_col]]
     keep <- !is.na(age) & age >= cohort_cfg$min_age
     cohort <- raw[keep, , drop = FALSE]
     # Coerce before filtering, so an unparseable LDL-C value is excluded, not kept as NA
     cohort[[cohort_cfg$ldl_col]] <- as.numeric(cohort[[cohort_cfg$ldl_col]])
     cohort <- cohort[!is.na(cohort[[cohort_cfg$ldl_col]]), , drop = FALSE]
     message(sprintf("[load_cohort] %d of %d visits kept (age >= %s, non-missing %s)",
                     nrow(cohort), nrow(raw), cohort_cfg$min_age, cohort_cfg$ldl_col))

     # Coerce numeric columns ####
     for (col in cohort_cfg$numeric_cols) {
          original <- cohort[[col]]
          coerced  <- suppressWarnings(as.numeric(original))
          lost     <- !is.na(original) & is.na(coerced)
          if (any(lost)) {
               warning(sprintf("[load_cohort] %s: %d non-numeric value(s) set to NA (%s)",
                               col, sum(lost), paste(unique(original[lost]), collapse = ", ")))
          }
          cohort[[col]] <- coerced
     }

     # Derive analysis columns ####
     levels_amy <- cohort_cfg$amyloid_levels
     cohort$amyloid_status <- factor(
          ifelse(cohort[[cohort_cfg$amyloid_col]] == 1L, levels_amy[["positive"]], levels_amy[["negative"]]),
          levels = c(levels_amy[["negative"]], levels_amy[["positive"]])
     )
     cohort$ldl_group       <- assign_ldl_group(x = cohort[[cohort_cfg$ldl_col]], ldl_cfg = ldl_cfg,
                                                labels = ldl_cfg$labels)
     cohort$ldl_group_label <- assign_ldl_group(x = cohort[[cohort_cfg$ldl_col]], ldl_cfg = ldl_cfg,
                                                labels = ldl_cfg$display_labels,
                                                set_reference = FALSE)

     # Split baseline ####
     time     <- cohort[[cohort_cfg$time_col]]
     baseline <- cohort[!is.na(time) & time == cohort_cfg$baseline_time, , drop = FALSE]

     message(sprintf("[load_cohort] %d visits from %d participants; %d baseline rows",
                     nrow(cohort), length(unique(cohort[[cohort_cfg$id_col]])), nrow(baseline)))

     list(
          long     = cohort,
          baseline = baseline
     )
}
