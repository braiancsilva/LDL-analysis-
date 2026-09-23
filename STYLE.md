# R Project Standard

**Template version: 2.1** — 2026-09-16. Changelog at the foot of this file.

> **Template.** Copy this file into any new R project and fill in the
> project-specific sections at the bottom. The rules above the divider are
> language-level conventions that apply to all projects.
>
> **Scope: R only — by design.** Shell, Python and external CLI tools have no
> standard here, because no stable one exists across these projects. Invoke them
> from R under the Error Handling rules (`system2()` inside `tryCatch()`), keep each
> tool's invocation confined to its `FUNCTION_*.R` wrapper, and record any
> conventions for them below the divider.

> **Supersedes `STYLE_v1.md` (v1.0, 2026-03-31)**, which stays in place for the
> projects already copied from it. No v1.0 core rule was changed or removed, so a
> v1.0 project is upgraded by replacing everything above the divider with this
> file's core and carrying its project-specific sections across unchanged.

---

## How this template propagates

The template is copied out, never linked. That works only if the copy discipline is
explicit, so it is stated here rather than assumed.

- **The divider is the contract.** Everything above `## Project-Specific Rules` is
  copied **verbatim** and must stay byte-identical across every project. As of
  2026-09-16 this held perfectly: the v1.0 core was byte-identical in all five
  project copies. Preserve that — it is what lets the core be written as absolutes.
- **Record the version you copied.** Each project fills in *Copied from template
  version* in the project-specific header, so it is possible to tell which projects
  are current without diffing them.
- **Never edit a core rule inside a project copy.** If a project must break one,
  record it under *Known Deviations* with the reason. Editing in place silently
  forks the core and destroys the guarantee above.
- **Promotion rule (the back-flow route).** A convention that independently appears
  in the *Additional Project Conventions* of **three or more** projects is a
  candidate for the core: promote it here, bump the minor version, add a changelog
  line. Projects drop their local copy of it at their next sync. Without this rule
  the template only ever loses information to its copies.
- **Demotion rule.** A *Known Deviation* that recurs in three or more projects means
  the core rule is wrong. Fix it here rather than letting every project except it.
- **Version semantics.** Major = a core rule changed or removed (projects must
  review). Minor = a core rule added (projects may adopt at leisure). Patch =
  wording or typo.
- **The filename carries the major version only.** `STYLE_v2.md` holds 2.0, 2.1, 2.2
  and so on, edited in place; only a major bump creates a new file (`STYLE_v3.md`).
  Renaming the template breaks every reference to it, and the `@`-import form fails
  **silently** — an agent simply runs with no style guide and nothing on screen says
  so. One rename in this workspace broke 24 references, five of them live imports.

---

## Indentation & Spacing

- **5 spaces** per indent level (no tabs, not 4 spaces).
- Multi-line function signatures indent each parameter **10 spaces** (2 levels); closing `) {` sits at column 0:
  ```r
  my_function <- function(
            arg1,
            arg2 = default
  ) {
  ```
- Spaces around `<-` and all binary operators.
- No space before `(` in function calls.
- Spaces after commas; named arguments use `=` with surrounding spaces: `merge(x = a, y = b)`.

---

## Assignment

- `<-` for all variable assignments.
- `=` only for named arguments inside function calls.

---

## Naming

- Functions, variables, parameters, column names: `snake_case`.
- Function files: `FUNCTION_<Name>.R` (uppercase `FUNCTION_` prefix).
- Integer literals use the `L` suffix: `0L`, `1L`, `4L`.
- Typed `NA`s: `NA_character_`, `NA_real_` (never bare `NA` in typed contexts).

---

## File / Function Header Block

Every function is preceded by a `#############################` docblock. Two formats:

**Full format** (complex functions):
```r
#############################
# function_name
#   -- one-line description
# PURPOSE
#   > ...
# REQUIREMENTS
#   > Packages: ..., External: ...
# ARGUMENTS
#   > param (type) -- description (default: ...)
# RETURNS
#   > type: description
# NOTES
#   > ...
#############################
```

**Short format** (simple/small functions):
```r
#############################
# function_name
#   -- one-line description
# ARGUMENTS -- param (type)
#   > x: description
# RETURNS -- type: description
# NOTES -- ...
#############################
```

---

## Section Headers Inside Functions

Use `# Section name ####` for all in-function section breaks:
```r
# Load Libraries ####
# Validate inputs ####
# Build output ####
```

---

## Input Validation

All functions open with an input validation block before any logic:
```r
# Validate inputs ####
if (!is.character(x) || !dir.exists(x)) stop("msg: ", x)
```

Error messages always include the offending value.

---

## Error Handling

- `stop()` for fatal errors (include offending value in message).
- `warning()` for non-fatal issues (e.g., unexpected input, partial failures).
- `tryCatch()` wrapping all `system2()` calls, with separate `warning` and `error` handlers.
- Side-effect functions return `invisible(result)`.

---

## Logging / Progress Messages

- `message()` for all pipeline progress — never `cat()`.
- Consistent prefix per file type (define in project-specific section below).
- `sprintf()` for formatted messages; `paste()` / `paste0()` for simple string building.

---

## dplyr / tidyverse

- Always use explicit namespace: `dplyr::filter()`, `dplyr::mutate()`, etc., even when the package is already loaded via `library()`.
- Use `%>%` pipe throughout.
- Use `.data[[col]]` for programmatic column access inside `dplyr` verbs.
- Use `dplyr::all_of()` / `dplyr::everything()` for column selection from character vectors.

---

## ggplot2

- Always name both arguments: `ggplot2::ggplot(data = ..., mapping = ggplot2::aes(...))`.
- Use explicit `ggplot2::` namespace on every call.
- Base theme: `ggplot2::theme_classic()`.
- Each layer on its own line, joined with `+`.

---

## Data Frames

- `stringsAsFactors = FALSE` in all `data.frame()` calls (not valid in `cbind()`).
- `[..., drop = FALSE]` on all `[` subsetting to prevent silent dimension drops.
- Set `row.names()` to the primary key column after merges.

---

## Multi-value Returns

Functions return a named list:
```r
list(
     status  = out$status,
     stdout  = out$stdout,
     stderr  = out$stderr
)
```

---

## Enum-like Parameters

Use `match.arg()` for parameters with a fixed set of valid choices:
```r
language <- match.arg(arg = language, choices = c("por", "eng", "spa"))
```

Use `switch()` for per-value string dispatch:
```r
switch(language, eng = "Age (years)", por = "Idade (anos)", spa = "Edad (años)")
```

---

## Configuration

Every project holds its parameters in **one nested list named `cfg`**, built in a
single file (e.g. `Scripts/config_<project>.R`) and `source()`d by every orchestrator
or stage runner.

- **No call site hard-codes a path, threshold, cutoff, panel, or covariate set.**
  Each is a `cfg` field, referenced from there. A value that appears literally in
  two places has already drifted.
- **All paths in `cfg` are absolute**, so a script does not depend on the working
  directory it was launched from.
- **`cfg` field names are the greppable link between a decision and its code.** Any
  value that comes from a recorded design decision names the `cfg` field carrying
  it, so the decision log and the implementation can be checked against each other.
- **Orchestrators are thin:** read `cfg` -> call `FUNCTION_*` -> write outputs. All
  reusable logic lives in `FUNCTION_*.R`.
- **A sensitivity run never overwrites the primary.** Where an analysis has
  alternative axes (retention mode, ancestry, covariate set), `cfg` derives suffixed
  output directories for them and the primary run uses the unsuffixed paths. Any new
  axis follows the same pattern rather than writing in place.

---

## Data Handling

Repositories hold code and shareable results. They never hold the data itself.

- **Individual-level data is never committed.** Phenotype and covariate tables,
  ID crosswalks, per-subject exports, genotype filesets and VCFs are gitignored.
- **Only summary statistics and figures are shareable products**, and even those are
  written under the gitignored outputs directory unless deliberately promoted.
- **The outputs directory is gitignored in full**, with a `.gitkeep` so the structure
  survives a clone.
- **Credentials live in a gitignored `secrets/` directory.** A `*.example` template
  carrying the variable names and no values is committed. Never copy a credential
  value into code, into a config file, into a log, or into a commit message.
- **Where data is governed by a use agreement**, the repository states which one and
  what it permits, so a reader knows what may leave the machine.

---

## Reproducibility

Two layers have to be pinned, and they need different tools.

- **R layer — required.** Dependencies are pinned with **`renv`**: `renv::init()` at
  project start, `renv.lock` committed, `renv::snapshot()` after adding or upgrading
  a dependency. A project that cannot yet adopt `renv` records that under *Known
  Deviations* with the reason, and states what it uses instead.
- **System layer.** `renv` pins R packages only. Where a pipeline calls external
  binaries whose version can change results — aligners, variant callers, association
  engines, annotation tools — that layer must be pinned too:
  - **Preferred: a container.** A `Dockerfile` (or Apptainer definition) committed at
    the repository root, pinning the R version, `renv.lock`, and every external tool
    with an explicit version. This is the only arrangement that makes a pipeline
    reproducible end to end.
  - **Minimum: declared versions.** Record the exact version of every external tool
    in `CLAUDE.md`, and resolve binary paths through environment-variable overrides
    (`REGENIE_BIN`, `BCFTOOLS_BIN`, ...) so a pinned build can be substituted without
    editing code.
- **State the level reached** in the project-specific section, so the gap between
  intent and reality is visible rather than assumed.

---

## Project Scaffold

A project carries a fixed set of documents, opened in three stages. Each answers one
question for one audience, and none restates another. Nothing is created before its
trigger: an empty document is worse than an absent one, because it looks answered.

### The three sets

| Set | Trigger | Files |
|---|---|---|
| **1** | project creation | `CLAUDE.md` · `STYLE.md` (this file) · `TODO.md` · `DECISIONS.md` · `grilling.md` · `.gitignore` · `secrets/*.example` · `renv.lock` · `Scripts/config_<project>.R` · `Outputs/.gitkeep` |
| **2** | the design is settled | `PROJECT_BRIEF.md` · `README.md` — and `grilling.md` dies |
| **3** | 3+ pipeline stages **and** 10+ function modules | `README.Rmd` · `Pipeline_Review.Rmd` — see `## Pipeline Documentation` |

Eight documents at full maturity, never nine: `grilling.md` dies at set 2, before the
Rmd pair arrives at set 3.

### What each document owns

Every fact has exactly one home. The others link to it rather than restating it — a
fact that lives in two documents has already begun to drift.

| Document | Owns | Audience |
|---|---|---|
| `PROJECT_BRIEF.md` | the question, rationale, design, sample, readouts, analysis plan, status | a collaborator, or yourself after a gap |
| `DECISIONS.md` | why any design choice was made (`D-NNN`) | future self, reviewer |
| `TODO.md` | what is next and what blocks it (`T-NN`) | whoever is working |
| `grilling.md` | what is **not yet** decided, in dependency order | whoever is working |
| `CLAUDE.md` | how to operate here: paths, crosswalks, commands, traps | the agent |
| `README.md` | identity, one paragraph, pointers, data-use statement | anyone opening the repository |
| `README.Rmd` | how the pipeline works | a user of the code |
| `Pipeline_Review.Rmd` | whether the pipeline is methodologically right | a reviewer |

**`README.md` is a stub and stays one** — around 40 lines: what this is, status, a
pointer table, the data-use statement. Everything else belongs in `PROJECT_BRIEF.md`
or `README.Rmd`. A `README.md` that outgrows that is duplicating one of them.

**`CLAUDE.md` is operational, not descriptive.** It may restate a *small, named* set
of facts from `PROJECT_BRIEF.md` where they are load-bearing and stale versions are
in circulation — but it says so inline and keeps the list short. It never mirrors
`DECISIONS.md`'s status table: a copy of a status table is a staleness trap.

### Identifiers

- Decisions are `D-NNN`, tasks are `T-NN`, numbered in creation order, never reused
  and never renumbered (see the next section).
- **Cross-document references cite the identifier, never a copy of the content.**
  `TODO.md` cites `D-005`; `PROJECT_BRIEF.md` cites `T-19`.

### Seams

Three pairs look as though they overlap. They do not, and each has a rule.

- **`TODO.md` vs `Pipeline_Review.Rmd` §Priority Recommendations.** The review holds
  methodological critiques *of code that exists*; `TODO.md` holds work to be done,
  including everything non-code (fetch a reference, settle a decision, inventory a
  data source). A Critical review item that gets scheduled becomes a `TODO` entry
  that **cites** it — never a copy of it.
- **`DECISIONS.md` vs `Pipeline_Review.Rmd`.** Prospective design choices go to
  `DECISIONS.md`, which works before any code exists — something the review, being
  organised one section per pipeline stage, structurally cannot do. Critiques of
  implemented behaviour go to the review.
- **`README.md` vs `README.Rmd`.** Front door versus technical reference. They
  coexist only for as long as the first stays a stub.

### The grilling contract

`grilling.md` is a **working file with an end**, and the only document in the set
that looks forwards.

- It holds **open questions in dependency order**, plus a numbered **fact ledger**
  (`F1`, `F2`, ...) recording what investigation has settled, so a question is asked
  once and never re-litigated.
- It is **temporary and gitignored**. `DECISIONS.md` is the durable record.
- A question leaves `grilling.md` only by becoming a `D-NNN` record with its
  **Decision** and **Rationale** filled in.
- **Facts migrate before the file dies.** The fact ledger is the most valuable thing
  grilling produces and it is lost by default. Any fact still load-bearing when a
  question closes is copied into the `D-NNN` record as evidence first; only then may
  the ledger entry go.
- When the frontier is empty, consolidate whatever is outstanding and **delete the
  file**.
- A project that keeps `grilling.md` permanently has merged it with `DECISIONS.md`
  and should pick one. The two have opposite lifecycles, and running both under one
  name is how two projects in this workspace diverged.

---

## Status-Bearing Records

Some files are read for their **current state** rather than their history: decision
logs, priority tables, task lists. Their history is not recoverable by reading them,
so it has to be preserved inside them.

- **Never delete an entry from a status-bearing record.** When an item is resolved,
  superseded or abandoned, change its **status** and leave the entry in place.
- **Never renumber.** Identifiers (`D-001`, `T-14`, priority rows) are permanent
  references; reusing or shifting one silently breaks every citation of it.
- **A superseded entry names what superseded it** (`SUPERSEDED by D-008`), so the
  trail can be followed forwards as well as backwards.
- **This rule does not apply to code.** Delete code freely — git is its audit trail.
  It applies to flat files whose present contents *are* the artefact.

---

## Pipeline Documentation (README.Rmd & Pipeline_Review.Rmd)

Complex analytical pipelines (those with 3+ pipeline stages and 10+ function modules)
require two companion Rmd documents rendered to PDF via `xelatex`. Both live at the
repository root. Both must be kept synchronized with each other and with `CLAUDE.md`:
when one is updated, review and update the others.

### Shared YAML header

```yaml
---
title: "Pipeline Name — Document Title"
subtitle: "Subtitle"
date: "`r format(Sys.Date(), '%B %d, %Y')`"
output:
  pdf_document:
    toc: true
    toc_depth: 3
    number_sections: true
    latex_engine: xelatex
    keep_tex: false
geometry: "left=2.2cm, right=2.2cm, top=2.5cm, bottom=2.5cm"
fontsize: 10pt
header-includes:
  - \usepackage{booktabs}
  - \usepackage{longtable}
  - \usepackage{array}
  - \usepackage{float}
  - \usepackage{fancyhdr}
  - \usepackage{hyperref}
  - \hypersetup{colorlinks=true, linkcolor=blue, urlcolor=blue}
  - \pagestyle{fancy}
  - \fancyhf{}
  - \fancyhead[L]{\textit{Pipeline Name — Document Title}}
  - \fancyhead[R]{\thepage}
  - \renewcommand{\headrulewidth}{0.4pt}
---
```

`Pipeline_Review.Rmd` additionally defines named colors in `header-includes` for
priority-row highlighting (one `\definecolor` per priority level: Critical, High,
Medium, Low, Resolved).

### Shared setup chunk

Both documents open with:

```r
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
library(knitr)
library(kableExtra)

doc_table <- function(df, caption = NULL, col_widths = NULL) {
  tbl <- kable(df,
        format    = "latex",
        booktabs  = TRUE,
        longtable = TRUE,
        caption   = caption,
        escape    = TRUE) %>%
    kable_styling(
      latex_options = c("striped", "repeat_header", "hold_position"),
      font_size     = 8,
      stripe_color  = "rowgray"
    )
  if (!is.null(col_widths)) {
    for (i in seq_along(col_widths)) {
      tbl <- column_spec(tbl, i, width = col_widths[[i]])
    }
  }
  tbl
}
```
```

All tables use `doc_table()`. Never call raw `kable()` directly.
`Pipeline_Review.Rmd` additionally defines `priority_table()` (see below).

---

### README.Rmd — Required sections

`README.Rmd` is the technical reference for users and future developers.

**Mandatory top-level sections (numbered, in order):**

1. **Executive Summary** — one-paragraph description of what the pipeline does. Includes
   a **Current Review Status** subsection that mirrors the counts and status of
   `Pipeline_Review.Rmd #sec:priority` (resolved/pending items, date of last update).

2. **Pipeline Architecture** — execution flow diagram (code block), module inventory table
   (one row per `FUNCTION_*.R` / orchestrator file, columns: File, Role).

3. **Input Requirements** — expected directory structure (code block), metadata file format
   (table with Column, Type, Description columns), any required external files.

4. **Component-by-Component Description** — one `##` subsection per function file.
   Each subsection states: function signature, purpose, key operations as a bullet list,
   return value. Separate subsections with `---`.

5. **Key Parameters** — one `##` subsection per `params` sub-list (or config group).
   Format each parameter as a bullet: `` `param_name` (type, default) — description ``.

6. **Output Structure** — the full output directory tree as a code block.

Use `\newpage` before sections 1–6. Use `\ref{sec:label}` / `{#sec:label}` for
cross-references between sections.

---

### Pipeline_Review.Rmd — Required sections

`Pipeline_Review.Rmd` is the methodological evaluation document. It tracks issues,
recommendations, and their resolution status over time.

**Mandatory top-level sections (numbered, in order):**

1. **Overview** — scope of the review, classification scheme (Critical / High / Medium /
   Low / Resolved), and a dated **Implementation status update** paragraph listing items
   resolved since the last review.

2. **One `#` section per pipeline stage** (Architecture & Engineering, QC, Filter & Trim,
   ASV Inference, ...). Each stage section contains exactly two subsections:
   - `## Strengths` — bullet list of what is correctly implemented.
   - `## Weaknesses & Recommendations` — free prose paragraphs, one per issue.
     Resolved items are prefixed with `**Status (implemented): description.**`.
     Unresolved issues follow the format:
     `**Bold problem statement.** Explanatory sentence. Recommendation: concrete action.`

3. **Cross-Cutting Methodological Issues** — issues that span multiple stages
   (e.g., compositionality consistency, multiple-testing burden).

4. **Priority Recommendations** `{#sec:priority}` — a single color-coded R data frame
   rendered by `priority_table()`. This section is the source of truth for the
   "Current Review Status" in `README.Rmd`. Columns: `Priority`, `Issue`, `Consequence`.
   Priority values: `"Critical"`, `"High"`, `"Medium"`, `"Low"`, `"Resolved"`.
   Items are **never deleted** when resolved — their `Priority` is changed to
   `"Resolved"`, per `## Status-Bearing Records` above.

5. **Concluding Remarks** — summary of current pipeline state relative to the initial
   review, calling out the highest-impact changes and any remaining directions.

**`priority_table()` helper** (define in setup chunk of `Pipeline_Review.Rmd`):

```r
priority_table <- function(df) {
  tbl <- kable(df,
        format    = "latex",
        booktabs  = TRUE,
        longtable = TRUE,
        caption   = "Prioritised recommendations",
        escape    = TRUE) %>%
    kable_styling(
      latex_options = c("repeat_header", "hold_position"),
      font_size     = 8
    ) %>%
    column_spec(1, width = "2cm",  bold = TRUE) %>%
    column_spec(2, width = "7cm") %>%
    column_spec(3, width = "5cm")

  crit_rows <- which(df$Priority == "Critical")
  high_rows <- which(df$Priority == "High")
  med_rows  <- which(df$Priority == "Medium")
  low_rows  <- which(df$Priority == "Low")
  done_rows <- which(df$Priority == "Resolved")

  if (length(crit_rows)) tbl <- row_spec(tbl, crit_rows, background = "critred")
  if (length(high_rows)) tbl <- row_spec(tbl, high_rows, background = "highorg")
  if (length(med_rows))  tbl <- row_spec(tbl, med_rows,  background = "medyel")
  if (length(low_rows))  tbl <- row_spec(tbl, low_rows,  background = "lowgrn")
  if (length(done_rows)) tbl <- row_spec(tbl, done_rows, background = "reccgreen")
  tbl
}
```

Color names (`critred`, `highorg`, `medyel`, `lowgrn`, `reccgreen`) must be defined
in the YAML `header-includes` via `\definecolor`.

---

### Synchronization rule

`CLAUDE.md` must document that `README.Rmd`, `Pipeline_Review.Rmd`, and itself are
kept in sync. When any of the three is updated, review and update the others:
- Architecture descriptions, parameter names/defaults, and methodological notes must
  be consistent across all three.
- `README.Rmd` "Current Review Status" must mirror `Pipeline_Review.Rmd #sec:priority`
  (counts and date).

---

---

## Project-Specific Rules

> Project: `LDL-analysis-` — LDL-C clinical categories, amyloid status, and baseline
> and longitudinal AD biomarkers and cognition in ADNI (≥65 y).
>
> **Copied from template version:** `2.1` — see the version stamp at the top of
> this file. Update it whenever you re-sync the core.

### Logging Prefix Convention

| File type | Prefix style | Example |
|---|---|---|
| Runner files (`run_*.R`) | `stage:: !>` | `"longitudinal:: !> Model mpacc_ldl_group"` |
| Config file | `config_ldl_analysis.R:: !>` | `"config_ldl_analysis.R:: !> cannot locate the project root"` |
| `FUNCTION_*.R` files | `[function_name]` | `"[load_cohort] Reading ..."` |

### Reproducibility Level

- `renv only`. `renv.lock` pins the R packages. No external binaries are called,
  so there is no system layer to pin beyond the R version, which is recorded in
  `renv.lock`. No container.

### Known Deviations

- **Column names inherited from the ADNI export** (`RID`, `AGE`, `PTGENDER`,
  `PTEDUCAT`, `APOE4_status`, `CLINICAL_LDL_C`, `ABETA_positivity_ratio`,
  `Years_bl_to_use`, `mPACCtrailsB`, ...) keep their upstream casing. The
  `snake_case` rule applies only to columns this project creates (`ldl_group`,
  `ldl_group_label`, `amyloid_status`).
- **Figures use `ggplot2::theme_light()`, not `theme_classic()`.** The figures
  (Figures 1d–1f and the trajectory plots) were designed for the manuscript on
  `theme_light()` before this standard was adopted; switching would change figures
  already circulated to co-authors. The base theme lives only in
  `Scripts/FUNCTION_ThemeLdl.R`, so a switch is a one-file change if the authors
  decide to make it.
- **No `secrets/*.example`.** The project uses no credentials; the directory is
  gitignored in case one is ever needed.

### Additional Project Conventions

- **Every clinical cut-off lives in `cfg$ldl` and nowhere else**, and carries a
  comment naming its source (D-001).
- **Model covariates are an explicit named vector** (`cfg$longitudinal$covariates`),
  and every model is one entry of `cfg$longitudinal$models`, so the model
  specification is greppable.
- **Numeric coercion never drops values silently.** Text-stored assay columns are
  coerced in `load_cohort()`, which warns with the count and the distinct strings
  lost (e.g. censored `">1700"`).

---

## Changelog

### 2.1 — 2026-09-16

- **Added `## Project Scaffold`.** The document set and its three triggers, what each
  document owns, the identifier conventions (`D-NNN`, `T-NN`), the three seams
  (`TODO` vs review priorities, `DECISIONS` vs review, `README.md` vs `README.Rmd`),
  and the `grilling.md` contract — including the rule that facts migrate into
  decision records before the file is deleted.
- **Closes a dangling reference in 2.0.** `## Status-Bearing Records` used `D-001`,
  `T-14` and `SUPERSEDED by D-008` as worked examples while nothing in the file said
  what those identifiers were or which document held them. `## Project Scaffold` now
  introduces them and is placed immediately before that section, so the terms are
  defined before they are used.
- **Added the filename rule** to version semantics: the filename carries the major
  version only, so minor bumps edit in place.
- **Decided: the `README.Rmd` / `Pipeline_Review.Rmd` specification stays in this
  file — it is not split into a separate document.** Splitting would create a second
  artefact to version and propagate, doubling the surface area of the very problem
  `## How this template propagates` exists to solve, and the specification is in
  active use in roughly twenty projects. The original objection was bulk — it was 49%
  of v1.0 — and that has largely dissolved as the rest of the standard grew: the same
  193 lines are now 28% of the file. Do not reopen without a new reason.
- **Retitled** from *R Coding Style Guide* to **R Project Standard**. Code style is
  now roughly a third of the file; the rest specifies project structure, data
  handling, reproducibility and documents. The old title described one chapter.
- **No rule changed or removed.** 2.1 is additive over 2.0.

### 2.0 — 2026-09-16

- **Added `## How this template propagates`.** The template was previously copy-out
  only: no version stamp, no way to tell which projects were current, and no route
  for a convention discovered in a project to return to the source. Adds the
  byte-identical-core contract, the promotion (back-flow) and demotion rules, and
  version semantics.
- **Added `## Configuration`.** Promoted to the core after being re-derived
  independently in four projects — `GiordanaSalvi/2026_2`, `GiordanaSalvi/2026_3`,
  `ArturSchuh/.../gp2-digenic` and `GabrielHoffmeister/2026_1_gwas_ad_biomarkers`.
- **Added `## Data Handling`.** Promoted to the core after appearing in three
  projects. These repositories hold DUA-governed clinical and genetic data, so this
  is a correctness rule, not a tidiness one.
- **Added `## Reproducibility`.** `renv` required for the R layer; a container
  (Docker/Apptainer) preferred for the system layer, because `renv` does not pin the
  external binaries these pipelines depend on; declared tool versions plus env-var
  binary overrides as the minimum. New *Reproducibility Level* slot in the
  project-specific section records which level a project actually reached.
- **Added `## Status-Bearing Records`.** Lifts the never-delete/never-renumber
  principle out of the `Pipeline_Review.Rmd` table spec, where it was stated as a
  formatting detail, and scopes it explicitly to flat files read for current state
  (decision logs, priority tables, task lists) — *not* to code, where git is the
  audit trail.
- **Added** the template version stamp and the *Copied from template version* field.
- **Clarified** that the core is R-only by design, and where other languages belong.
- **No v1.0 rule was changed or removed.** One passage was reworded: the
  `Pipeline_Review.Rmd` never-delete bullet now cross-references
  `## Status-Bearing Records` rather than restating it. The rule itself is unchanged.
- **Not addressed in this version:** whether the `README.Rmd` / `Pipeline_Review.Rmd`
  specification should be restructured — **resolved at 2.1: it is not split.**
  Testing conventions deliberately omitted: no project has tests, and a rule nobody
  follows devalues the rest of the file.

### 1.0 — 2026-03-31  *(now `STYLE_v1.md`)*

- Initial template: lexical, structural, defensive and explicitness rules;
  `README.Rmd` / `Pipeline_Review.Rmd` specification and sync rule; project-specific
  fill-in sections (logging prefixes, known deviations, additional conventions).
