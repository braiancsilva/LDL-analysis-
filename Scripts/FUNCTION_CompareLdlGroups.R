#############################
# compare_ldl_groups
#   -- Kruskal-Wallis omnibus plus Dunn pairwise tests across LDL-C groups
# PURPOSE
#   > Test each baseline outcome for a difference across LDL-C categories and
#     return the results as tidy data frames rather than printed output.
# REQUIREMENTS
#   > Packages: dunn.test
# ARGUMENTS
#   > data (data.frame) -- baseline table
#   > outcomes (character) -- numeric outcome columns
#   > group_col (character) -- grouping factor column
#   > p_adjust (character) -- dunn.test adjustment method (default: "bonferroni")
# RETURNS
#   > list: kruskal (one row per outcome), dunn (one row per outcome x pair)
# NOTES
#   > dunn.test reports ONE-SIDED p-values, Pr(Z >= |z|); reject at alpha/2.
#     The columns are named p_one_sided / p_adjusted_one_sided so this is not
#     mistaken for a two-sided p. See grilling.md.
#############################

compare_ldl_groups <- function(
          data,
          outcomes,
          group_col,
          p_adjust = "bonferroni"
) {

     # Validate inputs ####
     if (!is.data.frame(data)) stop("[compare_ldl_groups] data must be a data.frame, got: ", class(data)[1])
     missing_cols <- setdiff(c(outcomes, group_col), names(data))
     if (length(missing_cols) > 0L) {
          stop("[compare_ldl_groups] columns not in data: ", paste(missing_cols, collapse = ", "))
     }
     if (!is.factor(data[[group_col]])) stop("[compare_ldl_groups] group column must be a factor: ", group_col)
     if (!requireNamespace("dunn.test", quietly = TRUE)) {
          stop("[compare_ldl_groups] package 'dunn.test' is required but not installed")
     }

     # Run tests ####
     kruskal_rows <- vector(mode = "list", length = length(outcomes))
     dunn_rows    <- vector(mode = "list", length = length(outcomes))

     for (i in seq_along(outcomes)) {
          outcome <- outcomes[i]
          message(sprintf("[compare_ldl_groups] %s ~ %s", outcome, group_col))

          kw <- stats::kruskal.test(x = data[[outcome]], g = data[[group_col]])
          kruskal_rows[[i]] <- data.frame(
               outcome   = outcome,
               n         = sum(!is.na(data[[outcome]]) & !is.na(data[[group_col]])),
               statistic = unname(kw$statistic),
               df        = unname(kw$parameter),
               p_value   = kw$p.value,
               stringsAsFactors = FALSE
          )

          # dunn.test prints its own table and footer; capture both to keep the log clean
          utils::capture.output(
               dt <- suppressMessages(
                    dunn.test::dunn.test(x = data[[outcome]], g = data[[group_col]],
                                         method = p_adjust, kw = FALSE, table = FALSE)
               ),
               type = "output"
          )
          dunn_rows[[i]] <- data.frame(
               outcome              = outcome,
               comparison           = dt$comparisons,
               z                    = dt$Z,
               p_one_sided          = dt$P,
               p_adjusted_one_sided = dt$P.adjusted,
               p_adjust_method      = p_adjust,
               stringsAsFactors     = FALSE
          )
     }

     list(
          kruskal = do.call(rbind, kruskal_rows),
          dunn    = do.call(rbind, dunn_rows)
     )
}
