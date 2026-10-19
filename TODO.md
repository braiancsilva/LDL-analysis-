# TODO — LDL-analysis-

`[ ]` open, `[x]` done, `[~]` in progress. Tasks are `T-NN`, never renumbered.
Decisions are `D-NNN` in `DECISIONS.md`; open questions are in `grilling.md`.

**Next action:** T-07 — Braian decides the lower-limit censored values; then T-01.

- [x] **T-00 — Adopt STYLE v2.1** (2026-09-23): cfg-driven refactor, data out of git,
      set-1 scaffold, `renv.lock`. Equivalence to the original verified (D-002).
- [ ] **T-01 — Braian reviews the refactor** and confirms the outputs match what
      he had from `Code_LDL_cutoffs.R`.
- [ ] **T-02 — Braian runs `renv::restore()`** on his machine, and runs both runners
      from a fresh clone with his local data file (`LDL_ANALYSIS_DATA` if it is not in
      `Data/`).
- [ ] **T-03 — Work through `grilling.md`** in order. Priority: the censored CSF
      values in the longitudinal Aβ / p-tau models, and the implausible LDL-C values.
- [x] **T-05 — Audit (Braian's checklist)** (2026-09-23): code audit, 3 vs 5 cut-offs,
      appropriateness of the statistical tests. Report: `AUDIT_202609.md`. 3-group scheme
      added as a sensitivity run (D-003). Code-review bugs fixed.
- [~] **T-06 — Decide the audit's High-priority items** with Braian (`AUDIT_202609.md`
      § 4). 2026-10-19: censored `">1700"` (D-004), implausible LDL-C (D-005), primary
      exposure (D-006) and primary outcome (D-007) decided and implemented. Open: the
      lower-limit censored values (T-07) and the figure significance bars.
- [ ] **T-07 — Braian decides the lower-limit censored values** (`ABETA` `"<200"`, n = 1;
      `PTAU` `"<8"`, n = 7): set to the limit like `">1700"` (D-004), or leave as NA.
      Question sent 2026-10-19.
- [ ] **T-04 — Open set 2** (`PROJECT_BRIEF.md`, `README.md` stub with the ADNI
      data-use statement) once the design is settled, then delete `grilling.md`.
