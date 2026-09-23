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

---

## D-001 — LDL-C clinical categories

- **Status:** DECIDED (inherited from `Code_LDL_cutoffs.R`, recorded 2026-09-23).
- **Decision:** LDL-C (mmol/L) is binned into five left-closed intervals:
  Optimal `<2.6`, Near optimal `[2.6, 3.3)`, Borderline high `[3.3, 4.1)`,
  High `[4.1, 4.9)`, Very high `≥4.9`. Reference level: Optimal.
- **Rationale:** these are the NCEP ATP III LDL-C classes (100 / 130 / 160 / 190 mg/dL)
  converted to mmol/L, the standard clinical categorisation.
- **cfg:** `cfg$ldl$breaks`, `cfg$ldl$right`, `cfg$ldl$labels`, `cfg$ldl$reference`.
- **Open consequence:** the top two categories are sparse at baseline (High n = 8,
  Very high n = 3). Whether to merge them is an open question in `grilling.md`; this
  record stays as is until that is settled.

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
