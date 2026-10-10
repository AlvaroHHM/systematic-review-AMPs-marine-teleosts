# Antimicrobial Peptides in Marine Teleosts: A Systematic Review

**A PRISMA-compliant systematic evaluation of transcriptomic diversity, habitat adaptation, and larval mucosal barrier function in teleost fishes.**

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![PRISMA 2020](https://img.shields.io/badge/PRISMA-2020-blue)](http://www.prisma-statement.org/)

---

## Overview

This repository contains all data, scripts, and documentation supporting the systematic review:

> **Hernández Montiel, Á., Giffard-Mena, I., & Brizuela, C.** (2026). *Antimicrobial Peptides in Marine Teleosts: A Systematic Review on Their Molecular Diversity, Ecological Drivers, and Role in Mucosal Immunity.*

The review synthesizes **24 transcriptomic studies** identified from **399 initial records** in Scopus, following PRISMA 2020 guidelines.

---

## Key Results

| PRISMA Stage | Number |
|--------------|--------|
| Records identified | 399 |
| Duplicate records removed | 108 |
| Unique records screened | 291 |
| Records excluded at screening | 263 |
| Full-text studies assessed | 28 |
| Full-text studies excluded | 4 |
| **Studies included in synthesis** | **24** |

The review proposes the **Digestive Immunity Hypothesis**, integrating digestive and immune functions in the larval gut of marine teleosts.

### Main Findings

1. **Habitat-driven diversification.** Benthic and demersal species (*Platichthys stellatus*, *Scophthalmus maximus*, *Sebastes schlegelii*) exhibit expanded AMP gene clusters (up to 214 AMP genes in *S. schlegelii*) compared to pelagic species.

2. **Ontogenetic succession.** Three conserved phases — lecithotrophic (0–3 dpe), live feed transition (4–12 dpe), and post-flexion/weaning (15+ dpe) — with sequential expression of maternal transcripts, chemokines/lectins, and pore-forming piscidins.

3. **Co-evolved mucosal barrier.** Digestive enzymes (e.g., PA2G1B) and AMPs function as an integrated antimicrobial barrier in the alkaline intestinal lumen of marine teleosts.

---

## Repository Structure

    systematic-review-AMPs-marine-teleosts/
    │
    ├── 01_search_strategy/          # Scopus search equations + .ris exports (4 tracks)
    ├── 02_deduplication/            # DOI lists and de-duplication logs
    ├── 03_screening_rayyan/         # Rayyan screening decisions (291 records)
    ├── 04_eligibility/              # Full-text eligibility assessment
    ├── 05_risk_of_bias/             # Table S2 (final 24) + audit trail (26)
    ├── 06_data_extraction/          # Table S1 (data extraction grid)
    ├── 07_figures/                  # Publication-ready figures (SVG + PDF)
    ├── 08_scripts/                  # Reproducible scripts (R, Python, Bash)
    │   ├── R/                       # Figure generation + analysis
    │   ├── python/                  # De-duplication verification
    │   └── bash/                    # Search-track audit
    ├── 09_audit/                    # PRISMA 2020 audit report + checklist
    ├── CITATION.cff                 # Citation metadata
    ├── LICENSE                      # CC BY 4.0
    └── README.md

---

## Reproducibility

All analyses are fully reproducible. Scripts are organized by language:

| Language | Purpose | Location |
|----------|---------|----------|
| **R** | Figure generation, data processing | `08_scripts/R/` |
| **Python** | De-duplication verification (union-find, fuzzy matching) | `08_scripts/python/` |
| **Bash** | Search-track audit, file inventory | `08_scripts/bash/` |

### Key Scripts

| Script | Purpose |
|--------|---------|
| `03_generate_figure1_prisma.R` | Generate PRISMA 2020 flow diagram (Figure 1) |
| `regenerate_figure2_risk_of_bias.R` | Generate risk of bias figure (Figure 2) with `ggsci::pal_aaas` |
| `generate_figure3_ontogenetic.R` | Generate ontogenetic succession figure (Figure 3) |
| `verificar_union_find.py` | Reproduce de-duplication count (291 unique records) |
| `deduplicate.sh` | DOI-based de-duplication across search tracks |

### Software Requirements

- **R** ≥ 4.2.0 with packages: `ggplot2`, `cowplot`, `ggsci`, `ggtext`, `dplyr`, `patchwork`, `ragg`
- **Python** ≥ 3.9 with standard library (`difflib`, `re`, `unicodedata`); no external dependencies required
- **Bash** ≥ 4.0 (standard on Linux/macOS)

---

## Figures

All figures are provided in **vectorial format** (SVG or PDF), publication-ready.

| Figure | File | Description |
|--------|------|-------------|
| **Figure 1** | `Figure_1_PRISMA_2020.svg` | PRISMA 2020 flow diagram |
| **Figure 2** | `Figure_2_Risk_of_Bias.pdf` | Risk of bias assessment (panels A, B, C) |
| **Figure 3** | `Figure_3_Ontogenetic_Succession.pdf` | Ontogenetic succession of mucosal immunity |
| **Graphical Abstract** | `Graphical_Abstract.pdf` | Visual summary of the review |

---

## Data and Supplementary Materials

| Item | File | Description |
|------|------|-------------|
| **Table S1** | `06_data_extraction/Table_S1_data_extraction.csv` | Full data extraction grid (24 studies) |
| **Table S2** | `05_risk_of_bias/Table_S2_Risk_of_Bias.csv` | Risk of bias per study (17 Low / 5 Minor / 2 Moderate) |
| **Table S2 (audit)** | `05_risk_of_bias/Table_S2_Risk_of_Bias_audit.csv` | Audit trail with inclusion flags (26 records) |
| **PRISMA checklist** | `09_audit/PRISMA_checklist_2020.md` | Completed PRISMA 2020 checklist |
| **Audit report** | `09_audit/Auditoria_PRISMA.pdf` | Complete numerical audit of the PRISMA flow |

---

## PRISMA 2020 Compliance

This review was conducted in strict accordance with the **PRISMA 2020** statement. Six numerical discrepancies were identified during the audit and resolved:

| # | Discrepancy | Resolution |
|---|-------------|------------|
| 1 | Exclusion count (263 vs. 264) | 263 confirmed |
| 2 | E6 over-count (44 vs. 43) | 43 confirmed |
| 3 | Full-text exclusions (2 vs. 4) | 4 confirmed |
| 4 | Included studies (26 vs. 24) | 24 confirmed |
| 5 | De-duplication (287 vs. 291 vs. 294) | 291 confirmed (union-find, fuzzy ≥ 78%) |
| 6 | Risk of bias (17/5/2 vs. 19/3/2) | 17/5/2 confirmed |

The full audit report is available at `09_audit/Auditoria_PRISMA.pdf`.

---

## Citation

If you use this repository, data, or scripts in your work, please cite:

```bibtex
@article{hernandezmontiel2026amps,
  title   = {Antimicrobial Peptides in Marine Teleosts: A Systematic Review on Their Molecular Diversity, Ecological Drivers, and Role in Mucosal Immunity},
  author  = {Hernández Montiel, Álvaro and Giffard-Mena, Ivone and Brizuela, Carlos},
  journal = {Reviews in Aquaculture},
  year    = {2026},
  note    = {Manuscript submitted}
}
