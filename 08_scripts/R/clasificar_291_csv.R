# Script para procesar backup Rayyan CSV (291 artículos)
# Autor: Álvaro Hernández Montiel
# Fecha: 2026-10-03

# 1. Leer el log
log <- read.csv("../customizations_log.csv", stringsAsFactors = FALSE)
cat("Registros totales en el log:", nrow(log), "\n")

# 2. Convertir fechas
log$created_at <- as.POSIXct(log$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")

# 3. Separar decisiones y razones
decisiones <- log[log$key == "included", ]
razones <- log[grepl("__EXR__", log$key), ]

# 4. Última decisión por artículo
decisiones <- decisiones[order(decisiones$article_id, decisiones$created_at), ]
decisiones_finales <- decisiones[!duplicated(decisiones$article_id, fromLast = TRUE), ]
decisiones_finales$decision <- ifelse(decisiones_finales$value == 1, "INCLUDE",
                               ifelse(decisiones_finales$value == 0, "MAYBE", "EXCLUDE"))

cat("Decisiones únicas (finales):", nrow(decisiones_finales), "\n")

# 5. Última razón de exclusión
razones_exclusion <- razones[grepl("__EXR__E[0-9]", razones$key), ]
razones_exclusion <- razones_exclusion[order(razones_exclusion$article_id, razones_exclusion$created_at), ]
razones_finales <- razones_exclusion[!duplicated(razones_exclusion$article_id, fromLast = TRUE), ]
razones_finales$razon <- gsub("__EXR__", "", razones_finales$key)
razones_finales$razon <- gsub('"', '', razones_finales$razon)

# 6. Resumen decisiones
cat("\nResumen de decisiones FINALES:\n")
print(table(decisiones_finales$decision))

# 7. Leer articles.csv
articulos <- read.csv("../articles.csv", stringsAsFactors = FALSE)
cat("\nColumnas del CSV:\n")
print(colnames(articulos))
cat("\nArtículos en el CSV:", nrow(articulos), "\n")

# 8. Identificar columnas clave (ajustar según nombres reales)
# Buscar columna de ID (probablemente 'id', 'article_id', 'rayyan_id', etc.)
col_id <- names(articulos)[grepl("id", names(articulos), ignore.case = TRUE)][1]
col_title <- names(articulos)[grepl("title", names(articulos), ignore.case = TRUE)][1]
col_year <- names(articulos)[grepl("year", names(articulos), ignore.case = TRUE)][1]
col_journal <- names(articulos)[grepl("journal|source", names(articulos), ignore.case = TRUE)][1]
col_doi <- names(articulos)[grepl("doi", names(articulos), ignore.case = TRUE)][1]

cat("\nColumna ID:", col_id, "\n")
cat("Columna Title:", col_title, "\n")
cat("Columna Year:", col_year, "\n")
cat("Columna Journal:", col_journal, "\n")
cat("Columna DOI:", col_doi, "\n")

# 9. Renombrar columnas
articulos$article_id <- gsub("rayyan-", "", as.character(articulos[[col_id]]))
articulos$TI <- articulos[[col_title]]
articulos$Y1 <- articulos[[col_year]]
articulos$T2 <- articulos[[col_journal]]
articulos$DO <- articulos[[col_doi]]

# 10. Unir
final <- merge(articulos[, c("article_id", "TI", "Y1", "T2", "DO")],
               decisiones_finales[, c("article_id", "decision")],
               by = "article_id", all.x = TRUE)
final <- merge(final, razones_finales[, c("article_id", "razon")],
               by = "article_id", all.x = TRUE)
final$decision[is.na(final$decision)] <- "UNDECIDED"
final$razon[is.na(final$razon)] <- ""
final$categoria_exclusion <- ifelse(grepl("^E[0-9]", final$razon),
                                    substr(final$razon, 1, 2), "")

# 11. Ordenar
final <- final[order(final$decision, final$razon, final$TI), ]

# 12. Exportar
write.csv(final[, c("article_id", "decision", "razon", "categoria_exclusion",
                    "TI", "Y1", "T2", "DO")],
          "../PRISMA_tabla_completa_291.csv", row.names = FALSE)

# 13. Resumen
resumen <- as.data.frame(table(final$categoria_exclusion))
colnames(resumen) <- c("Categoria", "N_articulos")
resumen <- resumen[order(-resumen$N_articulos), ]
write.csv(resumen, "../PRISMA_resumen_exclusiones_291.csv", row.names = FALSE)

# 14. Elegibles
elegibles <- final[final$decision %in% c("INCLUDE", "MAYBE"), ]
write.csv(elegibles[, c("article_id", "decision", "TI", "Y1", "T2", "DO")],
          "../PRISMA_elegibles_291.csv", row.names = FALSE)

# 15. Reporte
cat("\n========== RESUMEN FINAL 291 ==========\n")
cat("Total artículos cribados:", nrow(final), "\n")
cat("\nDistribución de decisiones:\n")
print(table(final$decision))
cat("\nDistribución por categoría de exclusión:\n")
print(resumen)
cat("\n========== ARCHIVOS EXPORTADOS ==========\n")
cat("  - PRISMA_tabla_completa_291.csv\n")
cat("  - PRISMA_resumen_exclusiones_291.csv\n")
cat("  - PRISMA_elegibles_291.csv\n")
