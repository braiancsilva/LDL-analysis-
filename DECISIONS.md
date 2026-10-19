# Design Decisions — LDL-analysis-

Decision log. One record per decision, `D-NNN`, **never renumbered and never reused**.
Resolved, superseded or abandoned records change `Status` and stay in place
(`STYLE.md` § Status-Bearing Records). Every decision that produces a value in code
names the `cfg` field carrying it. Open questions live in `grilling.md` (temporary,
gitignored) until they become a record here.

**Data use.** The data are individual-level ADNI data under the **ADNI Data Use
Agreement**. They are not in this repository and must never be committed, pushed,
posted in an issue or copied outside approved machines. Each collaborator holds their
own approved copy. Only summary statistics and figures may be shared, and those are
written to the gitignored `Outputs/` until deliberately promoted.

**Contents**

| ID | Decision | Status |
|---|---|---|
| D-001 | LDL-C clinical categories (NCEP ATP III, mmol/L) | SUPERSEDED as primary by D-006 (2026-10-19); kept as sensitivity |
| D-002 | Repository layout and data handling (STYLE v2.1) | DECIDED 2026-09-23 |
| D-003 | 3-group LDL-C scheme as a sensitivity axis | SUPERSEDED by D-006 (2026-10-19) |
| D-004 | Censored CSF Aβ42 `">1700"` set to 1700 | DECIDED 2026-10-19 |
| D-005 | Exclude participants with LDL-C < 0.04 mmol/L | DECIDED 2026-10-19 |
| D-006 | Primary exposure: continuous LDL-C and 3 groups | DECIDED 2026-10-19 |
| D-007 | Primary outcome mPACCtrailsB; CSF p-tau and Aβ42 secondary | DECIDED 2026-10-19 |

---

## D-001 — LDL-C clinical categories

- **Status:** SUPERSEDED as primary by D-006 (2026-10-19). The 5-group scheme stays as a
  sensitivity run (`LDL_SCHEME=ncep5`, `Outputs/*_ldl5`). Originally DECIDED (inherited
  from `Code_LDL_cutoffs.R`, recorded 2026-09-23).
- **Decision:** LDL-C (mmol/L) is binned into five left-closed intervals:
  Optimal `<2.6`, Near optimal `[2.6, 3.3)`, Borderline high `[3.3, 4.1)`,
  High `[4.1, 4.9)`, Very high `≥4.9`. Reference level: Optimal.
- **Rationale:** these are the NCEP ATP III LDL-C classes (100 / 130 / 160 / 190 mg/dL)
  converted to mmol/L, the standard clinical categorisation.
- **cfg:** `ldl_schemes$ncep5` in `Scripts/config_ldl_analysis.R`, surfaced as
  `cfg$ldl$breaks`, `cfg$ldl$labels`, `cfg$ldl$reference` when `LDL_SCHEME` is unset.
- **Open consequence:** the top two categories are sparse at baseline (High n = 8,
  Very high n = 3). A merged 3-group scheme now runs as a sensitivity analysis
  (D-003). Whether it should *replace* this scheme as primary is still open in `grilling.md`.

## D-002 — Repository layout and data handling

- **Status:** DECIDED 2026-09-23.
- **Decision:** The single script `Code_LDL_cutoffs.R` is replaced by a cfg-driven
  pipeline: `Scripts/config_ldl_analysis.R`, `FUNCTION_*.R` modules, and two runners
  (`run_cross_sectional.R`, `run_longitudinal.R`). The ADNI data file lives in the
  gitignored `Data/` and every output lands in the gitignored `Outputs/`.
- **Rationale:** adopts `STYLE.md` v2.1. The data is individual-level ADNI data under
  the ADNI Data Use Agreement and must not be pushed to GitHub. The refactor was
  checked against the original script on 2026-09-23 and reproduces it to machine
  precision: 1819 visits / 347 participants; identical group counts and
  Kruskal–Wallis p-values; every fixed-effect estimate, SE and p-value, and every
  type III F of all six mixed models, within 3e-12. The original script remains in
  git history (commit `be01cbc`).
- **cfg:** `cfg$paths`.

## D-003 — 3-group LDL-C scheme as a sensitivity axis

- **Status:** SUPERSEDED by D-006 (2026-10-19): `ncep3` is now primary, not a sensitivity
  run. Originally DECIDED 2026-09-23 (requested by Braian: "3 cut-offs instead of 5").
- **Decision:** add scheme `ncep3`: Optimal `<2.6`, Near optimal `[2.6, 3.3)`,
  Borderline high or above `≥3.3` mmol/L. It runs with `LDL_SCHEME=ncep3` and writes to
  `Outputs/*_ldl3`. It never overwrites the primary 5-group outputs (D-001). Only the
  categorical models are rerun; the continuous-LDL models do not depend on the scheme.
- **Rationale:** audit of 2026-09-23 (`AUDIT_202609.md` § 2).
  - Merging the three classes at or above 130 mg/dL gives baseline n = 184 / 109 / 54 (A+ 50 / 26 / 18). The alternative `<2.6 / 2.6–4.1 / ≥4.1` leaves a top group of 11 (A+ 5).
  - The likelihood-ratio test of 3 against 5 groups finds no loss of fit: p = 0.99 (mPACC), 0.89 (p-tau), 0.97 (Aβ). AIC is 12–14 points lower for 3 groups, BIC 48–58 lower.
  - The cut-points stay NCEP ones, keeping comparability with the primary. Tertiles were rejected as sample-specific.
  - Continuous LDL-C beats every categorisation on AIC/BIC for all three outcomes, and a 3-df spline does not beat a linear term. This argues for continuous LDL-C as the eventual primary exposure; that question stays open in `grilling.md`.
- **cfg:** `ldl_schemes$ncep3`, selected by env var `LDL_SCHEME`; `cfg$ldl$is_primary`.

## D-004 — Censored CSF Aβ42 `">1700"` set to 1700

- **Status:** DECIDED 2026-10-19 (Braian).
- **Decision:** the longitudinal `ABETA` string `">1700"` is set to the assay upper limit,
  1700, instead of being coerced to NA. The lower-limit strings (`ABETA` `"<200"`, n = 1;
  `PTAU` `"<8"`, n = 7) are not covered by this decision: they still become NA, with a
  warning, until Braian decides them (open in `grilling.md`).
- **Rationale:** the longitudinal `ABETA` column held 161 `">1700"` values. Coercing them
  to NA dropped them from the Aβ42 models, and 160 of the 161 belong to A− participants
  (100 of 253 A− participants had at least one), so the missingness was informative and
  removed the most amyloid-negative observations. Setting them to 1700 also matches the
  baseline column `ABETA_bl_to_use`, which is already capped at 1700. This is single-value
  imputation at the limit, not a censored (tobit) model; the Aβ42 estimates near the
  ceiling are therefore conservative.
- **cfg:** `cfg$cohort$censored_values`.

## D-005 — Exclude participants with LDL-C < 0.04 mmol/L

- **Status:** DECIDED 2026-10-19 (Braian; his message read "<0,004", clarified to 0.04
  because no value lies below 0.004).
- **Decision:** participants whose `CLINICAL_LDL_C` is below 0.04 mmol/L are excluded.
  LDL-C is a single value per participant, carried to every visit, so the exclusion
  removes the whole participant: 5 participants, 29 visits (1 of the 5 is A+).
- **Rationale:** the five values (0.0239, 0.0244, 0.0275, 0.0278, 0.0313 mmol/L) are
  physiologically implausible and most likely entry or unit errors; the next value is
  0.139. The cohort becomes 342 participants.
- **cfg:** `cfg$cohort$min_ldl`.

## D-006 — Primary exposure: continuous LDL-C and 3 groups

- **Status:** DECIDED 2026-10-19 (Braian). Supersedes D-003 and the primary status of D-001.
- **Decision:** the primary exposures are continuous LDL-C (mmol/L) and the 3-group scheme
  `ncep3` (Optimal `<2.6`, Near optimal `[2.6, 3.3)`, Borderline high or above `≥3.3`).
  `ncep3` is the default scheme and writes to the unsuffixed `Outputs/` directories. The
  5-group scheme `ncep5` (D-001) becomes a sensitivity run: `LDL_SCHEME=ncep5`, written to
  `Outputs/*_ldl5`.
- **Rationale:** continuous LDL-C has the best AIC and BIC for all three outcomes, and a
  3-df spline does not beat the linear term. Collapsing 5 to 3 groups costs no fit
  (likelihood-ratio p = 0.89–0.99), while High (n = 8) and Very high (n = 3) are too sparse
  to estimate. The 3-group cut-points remain NCEP ones (D-003, `AUDIT_202609.md` § 2).
- **cfg:** `ldl_schemes$ncep3` (empty `suffix`), the `LDL_SCHEME` default, and the
  `exposure` field of `cfg$longitudinal$models`.

## D-007 — Primary outcome mPACCtrailsB; CSF p-tau and Aβ42 secondary

- **Status:** DECIDED 2026-10-19 (Braian).
- **Decision:** cognition (mPACCtrailsB) is the primary outcome, in both the baseline and
  the longitudinal stage. CSF p-tau and CSF Aβ42 are secondary outcomes.
- **Rationale:** pre-specifying one primary outcome limits the multiple-testing burden
  (`AUDIT_202609.md` § 4, Medium). The secondary outcomes are reported as supporting
  evidence, not as independent confirmatory tests.
- **cfg:** `cfg$cross_sectional$outcome_roles` and the `role` field of each entry of
  `cfg$longitudinal$models`; both are written into the output tables.
