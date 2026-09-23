# Design Decisions — LDL-analysis-

Decision log. One record per decision, `D-NNN`, **never renumbered and never reused**.
Resolved, superseded or abandoned records change `Status` and stay in place
(`STYLE.md` § Status-Bearing Records). Every decision that produces a value in code
names the `cfg` field carrying it. Open questions live in `grilling.md` (temporary,
gitignored) until they become a record here.

**Contents**

| ID | Decision | Status |
|---|---|---|
| D-001 | LDL-C clinical categories (NCEP ATP III, mmol/L) | DECIDED (inherited, 2026-09-23) |
| D-002 | Repository layout and data handling (STYLE v2.1) | DECIDED 2026-09-23 |
| D-003 | 3-group LDL-C scheme as a sensitivity axis | DECIDED 2026-09-23 |

---

## D-001 — LDL-C clinical categories

- **Status:** DECIDED (inherited from `Code_LDL_cutoffs.R`, recorded 2026-09-23).
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

- **Status:** DECIDED 2026-09-23 (requested by Braian: "3 cut-offs instead of 5").
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
