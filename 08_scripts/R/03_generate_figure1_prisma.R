# =============================================================================
# FIGURE 1 - PRISMA 2020 (diseño oficial, export SVG)
# =============================================================================

library(PRISMA2020)
library(DiagrammeRsvg)
library(rsvg)

setwd("~/Desktop/Post-Doctorado/Articulos en proceso/AMP_totoaba/review/04_prisma")

# ---- 1. Leer template ----
csvFile <- system.file("extdata", "PRISMA.csv", package = "PRISMA2020")
data <- read.csv(csvFile, stringsAsFactors = FALSE)

# ---- 2. Modificar números ----
data$n[data$data == "database_results"] <- 399
data$boxtext[data$data == "database_results"] <- "Records identified from:\nScopus (n = 399)\n• Track A refined: 100\n• Track B original: 199\n• Track B refined: 100"

data$n[data$data == "duplicates"] <- 108
data$boxtext[data$data == "duplicates"] <- "Duplicate records removed\n(n = 108)"

data$n[data$data == "records_screened"] <- 291
data$boxtext[data$data == "records_screened"] <- "Records screened\n(title and abstract)\n(n = 291)"

data$n[data$data == "records_excluded"] <- 264
data$boxtext[data$data == "records_excluded"] <- "Records excluded\n(n = 264)\n\n• E7 (Non-marine): 83\n• E2 (No transcriptome): 54\n• E6 (Non-relevant tissue): 44\n• E4 (Review/editorial): 41\n• E3 (Not AMP/immunity): 33\n• E1 (Not teleost): 9"

data$n[data$data == "dbr_sought_reports"] <- 28
data$boxtext[data$data == "dbr_sought_reports"] <- "Reports sought for retrieval\n(n = 28)"

data$n[data$data == "dbr_notretrieved_reports"] <- 0

data$n[data$data == "dbr_assessed"] <- 28
data$boxtext[data$data == "dbr_assessed"] <- "Reports assessed for eligibility\n(n = 28)\n(2 INCLUDE + 26 MAYBE)"

data$n[data$data == "dbr_excluded"] <- 4
data$boxtext[data$data == "dbr_excluded"] <- "Reports excluded (n = 4):\n• Tessera et al. (2012)\n• Asensio-Calavia et al. (2026)\n• Miccoli et al. (2021)\n• Wang et al. (2024)"

data$n[data$data == "new_studies"] <- 24
data$boxtext[data$data == "new_studies"] <- "Studies included in review\n(n = 24)"

data$n[data$data == "total_studies"] <- 24
data$boxtext[data$data == "total_studies"] <- "Total studies included in review\n(n = 24)"

# ---- 3. Generar diagrama ----
prisma_data <- PRISMA_data(data)

prisma_figure <- PRISMA_flowdiagram(
  prisma_data,
  interactive = FALSE,
  previous = FALSE,
  other = FALSE,
  fontsize = 10,
  font = "Helvetica"
)

# ---- 4. Exportar SOLO SVG ----
svg_code <- export_svg(prisma_figure)
writeLines(svg_code, "Figure_1_PRISMA_2020.svg")

cat("✅ SVG generado: Figure_1_PRISMA_2020.svg\n")
cat("📁 Ubicación: 04_prisma/\n")
cat("👉 Abre el SVG en Inkscape o Illustrator para añadir los textos verticales\n")
