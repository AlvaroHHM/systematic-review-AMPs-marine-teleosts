# Script para preparar CSV compatible con Rayyan
# Autor: Álvaro Hernández Montiel

# Leer archivos
AMP_papers <- read.csv("AMP_papers.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
Transcriptome_papers <- read.csv("Transcriptome_papers.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# Añadir columna pista
AMP_papers$pista <- "A_AMP"
Transcriptome_papers$pista <- "B_Transcriptoma"

# Unir
todos <- rbind(AMP_papers, Transcriptome_papers)

# Eliminar duplicados por DOI
todos <- todos[!duplicated(todos$DOI), ]

# Crear dataframe limpio con nombres que Rayyan espera
rayyan <- data.frame(
  title     = todos$Title,
  authors   = todos$Authors,
  abstract  = todos$Abstract,
  journal   = todos$Source.title,
  year      = todos$Year,
  doi       = todos$DOI,
  volume    = todos$Volume,
  issue     = todos$Issue,
  pages     = paste(todos$Page.start, todos$Page.end, sep = "-"),
  url       = todos$Link,
  pista     = todos$pista,
  stringsAsFactors = FALSE
)

# Limpiar NA
rayyan[is.na(rayyan)] <- ""

# Reporte
cat("Registros Pista A (AMP):", nrow(AMP_papers), "\n")
cat("Registros Pista B (Transcriptoma):", nrow(Transcriptome_papers), "\n")
cat("Total combinado:", nrow(todos), "\n")
cat("Total para Rayyan:", nrow(rayyan), "\n")

# Exportar
write.csv(rayyan, "para_rayyan.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat("\nArchivo exportado: para_rayyan.csv\n")
