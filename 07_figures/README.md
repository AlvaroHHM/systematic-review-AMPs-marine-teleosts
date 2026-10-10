# 07. Figures

This folder contains the final figures used in the manuscript 
*"Antimicrobial Peptides in Marine Teleosts: A Systematic Review on Their Molecular Diversity, Ecological Drivers, and Role in Mucosal Immunity."*

All figures are provided in **vectorial format** (SVG or PDF), making them fully scalable and publication-ready.

## Files

| File | Format | Description |
|------|--------|-------------|
| `Figure_1_PRISMA_2020.svg` | SVG | PRISMA 2020 flow diagram (native vectorial, editable) |
| `Figure_2_Risk_of_Bias.pdf` | PDF | Methodological quality and risk of bias assessment (panels A, B, C) |
| `Figure_3_Ontogenetic_Succession.pdf` | PDF | Ontogenetic succession of mucosal immunity in marine teleost larvae |
| `Graphical_Abstract.pdf` | PDF | Visual summary of the review |
| `PRISMA_checklist_2020.md` | MD | Completed PRISMA 2020 checklist |

## Figure 1 — PRISMA 2020 Flow Diagram

Shows the complete study selection process: from **399 initial records** identified in Scopus (four search tracks), through **291 unique records** screened in Rayyan, to **24 studies** included in the final synthesis after full-text eligibility assessment.

- **Format:** SVG (native vectorial, editable in Inkscape/Illustrator)
- **Reference in manuscript:** Figure 1 (Results 3.1)
- **Reproducible script:** `08_scripts/R/03_generate_figure1_prisma.R`

## Figure 2 — Risk of Bias Assessment

Methodological quality assessment across the 24 included transcriptomic studies, evaluated using an adapted MINSEQE-based framework. Three panels:

- **(A) Domain-specific risk of bias:** Evaluation across five core domains — D1 (biological replication), D2 (public repository accession availability), D3 (sequencing depth and BUSCO completeness), D4 (orthogonal experimental validation), and D5 (controlled experimental design). All domains were rated as "Low" or "Minor concerns"; no domain received a "High" rating.
- **(B) Overall risk of bias distribution:** 17 studies (70.8%) rated as Low risk, 5 (20.8%) as Low with minor concerns, and 2 (8.3%) as Moderate risk.
- **(C) Habitat stratification:** Target species classified according to ecological habitat, arranged along the water column gradient from demersal (bottom) to multi-habitat database resources (top).

- **Format:** PDF (vectorial)
- **Reference in manuscript:** Figure 2 (Results 3.2)
- **Reproducible script:** `08_scripts/R/regenerate_figure2_risk_of_bias.R`
- **Input data:** `05_risk_of_bias/Table_S2_Risk_of_Bias.csv`
- **Color palette:** `ggsci::pal_aaas` (AAAS journal palette) + `cowplot::theme_cowplot`

## Figure 3 — Ontogenetic Succession of Mucosal Immunity

Timeline figure depicting three conserved developmental phases in marine teleost larvae:

1. **Lecithotrophic phase (0–3 dpe):** dominated by maternally derived transcripts (UBIM/S30FAU) and yolk reserves.
2. **Live feed transition phase (4–12 dpe):** triggered by rotifer and *Artemia* ingestion, with sequential microbial colonization (*Pseudoalteromonas* → *Stenotrophomonas* → *Cohaesibacter*) and upregulation of lectins (LEG3) and chemokines (CCL11, CCL20).
3. **Post-flexion/weaning phase (15+ dpe):** characterized by formulated feed introduction, *Psychrobacter* dominance in the gut microbiome, and maturation of pore-forming piscidins, β-defensins, and dual digestive-immune enzymes (PA2G1B).

Gut compartmentalization emerges during the post-flexion phase, with anterior/midgut segments specialized for nutrient absorption and the posterior gut concentrating immune effectors, lysosome-rich enterocytes, and BEST4+ cells.

- **Format:** PDF (vectorial)
- **Reference in manuscript:** Figure 3 (Discussion 4.2)

## Graphical Abstract

Visual summary integrating the **Digestive Immunity Hypothesis** with habitat-driven AMP diversification across marine teleost lineages. Synthesizes the three central messages of the review: (i) AMP structural diversification in benthic vs. pelagic species, (ii) ontogenetic succession of mucosal effectors, and (iii) the co-evolved digestive-immune barrier of the larval gut.

- **Format:** PDF (vectorial)
- **Purpose:** Journal submission and dissemination

## Format Notes

- **Vectorial figures** (SVG, PDF) preserve infinite resolution and are ideal for journal submission and print.
- **Figure 1** is provided as SVG to preserve editability (Inkscape, Adobe Illustrator, or any SVG-compatible editor).
- **Figures 2 and 3** are provided as PDF, the preferred format for Elsevier, Wiley, Frontiers, and most aquaculture/immunology journals.
- All figures use colorblind-friendly palettes where applicable.

## Related Resources

- **PRISMA checklist:** `PRISMA_checklist_2020.md` (this folder)
- **Audit report:** `09_audit/Auditoria_PRISMA.pdf`
- **Risk of bias data:** `05_risk_of_bias/Table_S2_Risk_of_Bias.csv`
- **Figure scripts:** `08_scripts/R/`
