# CLAUDE.md

Operational guide for working in this repository. What the project is and why lives
elsewhere: decisions in `DECISIONS.md`, work in `TODO.md`, open questions in `grilling.md`
(local only). Code and project conventions: `STYLE.md` (R Project Standard v2.1).

## What this is

ADNI participants aged ≥65 with a clinical LDL-C measurement, binned into NCEP ATP III
categories (D-001). The baseline stage relates LDL-C group to CSF Aβ42, CSF p-tau and
mPACCtrailsB. The longitudinal stage fits LDL-C × amyloid × time mixed models for the
same three outcomes. Collaboration with Braian Corso (GitHub `braiancsilva`, repo owner).

## Data — read before touching anything

- `Data/cognition_LDL_C.xlsx` is **individual-level ADNI data** (RID, PTID, exam dates,
  CSF, APOE) governed by the **ADNI Data Use Agreement**. It is gitignored. It must never
  be committed, pushed, pasted into an issue, or copied outside approved machines. The
  same applies to everything in `Outputs/`, which is gitignored in full.
- Each collaborator keeps their own copy of the data. It is **not** in the GitHub repo.
- Override the location with `LDL_ANALYSIS_DATA=/path/to/file.xlsx`, and the project
  root with `LDL_ANALYSIS_ROOT`.

## Layout

```
Scripts/config_ldl_analysis.R   cfg: every path, cut-off, covariate, model, plot setting
Scripts/run_cross_sectional.R   stage 1: Table 1, Kruskal-Wallis + Dunn, Figs 1d-1f, scatter
Scripts/run_longitudinal.R      stage 2: six lmerTest models + trajectory figures
Scripts/FUNCTION_*.R            all reusable logic (one module per task)
Data/                           gitignored; the ADNI xlsx
Outputs/cross_sectional/        gitignored
Outputs/longitudinal/           gitignored
```

## Commands

```sh
Rscript -e 'renv::restore()'          # once, on a new machine
Rscript Scripts/run_cross_sectional.R
Rscript Scripts/run_longitudinal.R    # ~1 min
```

From RStudio, `source("Scripts/run_cross_sectional.R")` works too. The root resolves from
the sourced file's path.

## Traps

- **Censored CSF strings.** `ABETA` holds `">1700"` / `"<200"` and `PTAU` holds `"<8"`.
  `load_cohort()` coerces them to NA **and warns**. That is the original script's behaviour,
  kept deliberately; the fix is an open question in `grilling.md`. Do not silence the warning.
- **Two LDL-C group columns.** `ldl_group` (plain labels) is for models and tests;
  `ldl_group_label` (labels with `\n` and ranges) is for figures only.
- **`ABETA_positivity_ratio` stays 0/1 numeric in the models**, as in the original. The
  factor `amyloid_status` is for tables and figures.
- **Dunn p-values are one-sided.** The CSV columns are named `*_one_sided` on purpose.
- **Results must stay reproducible against the original.** `Code_LDL_cutoffs.R` (git
  commit `be01cbc`) was reproduced to machine precision (D-002). Any change that alters a
  number is a methodological decision: record it in `DECISIONS.md` first.
- **The repo sits inside Dropbox.** Sync between collaborators through git, not Dropbox.
  Dropbox syncing `.git/` can corrupt it if two machines write at once.

## Reproducibility

`renv only` (see `STYLE.md` § Reproducibility Level). After adding a package:
`renv::snapshot()` and commit `renv.lock`.

## Document map

| File | Owns | Committed |
|---|---|---|
| `STYLE.md` | conventions (core v2.1 + project section) | yes |
| `DECISIONS.md` | why (`D-NNN`) | yes |
| `TODO.md` | what next (`T-NN`) | yes |
| `grilling.md` | open questions + fact ledger | no (gitignored, temporary) |
| `CLAUDE.md` | how to operate here | yes |

Set 2 (`PROJECT_BRIEF.md`, `README.md`) opens when the design is settled — `TODO.md` T-04.
