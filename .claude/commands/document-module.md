# Document Module

Perform a deep-dive on a Ka-Boost library module (or any rossum/Karel submodule) and produce two files:
1. `CLAUDE.md` — AI context file (architecture, patterns, API, gotchas)
2. `readme.md` — Developer-facing reference (updated or created from scratch)

## Target

Module path: $ARGUMENTS

If no path is given, ask the user which module to document before proceeding.

## Steps

### 1. Explore the module thoroughly

Read **every source file** in the module — do not sample. This includes:
- All `.m` macro files
- All `.kl`, `.klc`, `.klh`, `.klt` source files in `include/` and `src/`
- `package.json` (rossum manifest — name, version, depends, tp-interfaces)
- Existing `readme.md` or `CLAUDE.md` (note what's already there)
- look through `test/` folder if it exists to understand how the module works from the toy examples.

Document for each public routine/macro/type:
- Name and parameters
- What it does / what it expands to
- Return type if applicable

### 2. Search the broader repo for usage examples

Search `lib/` for real call sites of this module's routines and macros. Find at least 3–5 concrete usage examples from other modules. Note which modules depend on this one and how they use it.

### 3. Write `CLAUDE.md`

Create or overwrite `CLAUDE.md` at the module root. This file is loaded as AI context in future sessions. It must include:

- **Purpose** — one paragraph: what problem this module solves, where it fits in the layer stack
- **Repository Layout** — annotated directory tree of all significant files
- **Full API Reference** — every public routine, macro, and type, grouped logically. For macros: show parameters and what they expand to. For routines: show signature and what they do.
- **Core Patterns** — the 3–6 most important usage patterns as named, titled sections with working code examples drawn from real codebase usage (not invented)
- **Common Mistakes** — a table of: mistake | symptom | fix. Include at least 3 real gotchas.
- **Dependencies** — what this module depends on and what depends on it
- **Build / Integration notes** — anything specific to how this module fits in the rossum/ktransw/ninja build pipeline

Keep it dense and factual. No filler. This file is read by an AI, not rendered for humans.

### 4. Write `readme.md`

Create or overwrite `readme.md` at the module root. This is the developer-facing reference. It must include:

- **Title and one-sentence description**
- **Overview paragraph** — what problem it solves and when you'd reach for it
- **Files table** — filename | purpose for every significant file
- **API / Macro Reference** — all public surface area, grouped by file or logical category. Use code blocks with realistic examples for every non-obvious item.
- **Common Patterns** — same patterns as CLAUDE.md but written for a human reader: explain the *why*, not just the *what*. Copy-pasteable skeleton code.
- **Common Mistakes table** — same content as CLAUDE.md but formatted as a readable table
- **Build Flow** — brief description of where this module sits in the compilation pipeline
- Link back to the top-level Ka-Boost readme for full build instructions

Write in a direct, technical style. No marketing language. Assume the reader knows Karel and FANUC robotics basics but may not know this specific module.

### 5. Confirm

Report back with:
- Paths of files written
- A brief summary of the module's public API surface (count of routines/macros/types documented)
- Any gaps found (files that couldn't be read, patterns that are unclear, etc.)
