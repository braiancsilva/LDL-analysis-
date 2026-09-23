# TODO — LDL-analysis-

`[ ]` open, `[x]` done, `[~]` in progress. Tasks are `T-NN`, never renumbered.
Decisions are `D-NNN` in `DECISIONS.md`; open questions are in `grilling.md`.

**Next action:** T-01 — Braian reviews the refactor.

- [x] **T-00 — Adopt STYLE v2.1** (2026-09-23): cfg-driven refactor, data out of git,
      set-1 scaffold, `renv.lock`. Equivalence to the original verified (D-002).
- [ ] **T-01 — Braian reviews the refactor** and confirms the outputs match what
      he had from `Code_LDL_cutoffs.R`.
- [ ] **T-02 — Braian runs `renv::restore()`** on his machine, and runs both runners
      from a fresh clone with his local data file (`LDL_ANALYSIS_DATA` if it is not in
      `Data/`).
- [ ] **T-03 — Work through `grilling.md`** in order. Priority: the censored CSF
      values in the longitudinal Aβ / p-tau models, and the implausible LDL-C values.
- [ ] **T-04 — Open set 2** (`PROJECT_BRIEF.md`, `README.md` stub with the ADNI
      data-use statement) once the design is settled, then delete `grilling.md`.
