# Script definitivo para procesar backup Rayyan 291 (formato CSV)
# Autor: Álvaro Hernández Montiel
# Fecha: 2026-10-03

# ============================================================
# 1. LEER EL LOG DE DECISIONES
# ============================================================
log <- read.csv("../customizations_log.csv", stringsAsFactors = FALSE)
cat("Registros totales en el log:", nrow(log), "\n")

# Convertir fechas
log$created_at <- as.POSIXct(log$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")

# ============================================================
# 2. SEPARAR DECISIONES Y RAZONES
# ============================================================
decisiones <- log[log$key == "included", ]
razones <- log[grepl("__EXR__", log$key), ]

cat("Entradas de decisión:", nrow(decisiones), "\n")
cat("Entradas de razón:", nrow(razones), "\n")

# ============================================================
# 3. ÚLTIMA DECISIÓN POR ARTÍCULO
# ============================================================
decisiones <- decisiones[order(decisiones$article_id, decisiones$created_at), ]
decisiones_finales <- decisiones[!duplicated(decisiones$article_id, fromLast = TRUE), ]
decisiones_finales$decision <- ifelse(decisiones_finales$value == 1, "INCLUDE",
                               ifelse(decisiones_finales$value == 0, "MAYBE", "EXCLUDE"))

cat("Decisiones únicas (finales):", nrow(decisiones_finales), "\n")

# ============================================================
# 4. ÚLTIMA RAZÓN DE EXCLUSIÓN POR ARTÍCULO (solo E1-E7)
# ============================================================
razones_exclusion <- razones[grepl("__EXR__E[0-9]", razones$key), ]
razones_exclusion <- razones_exclusion[order(razones_exclusion$article_id, razones_exclusion$created_at), ]
razones_finales <- razones_exclusion[!duplicated(razones_exclusion$article_id, fromLast = TRUE), ]
razones_finales$razon <- gsub("__EXR__", "", razones_finales$key)
razones_finales$razon <- gsub('"', '', razones_finales$razon)

# ============================================================
# 5. LEER ARTICLES.CSV
# ============================================================
articulos <- read.csv("../articles.csv", stringsAsFactors = FALSE)
cat("\nArtículos en articles.csv:", nrow(articulos), "\n")

# Extraer ID limpio (quitar "rayyan-")
articulos$article_id <- gsub("rayyan-", "", articulos$key)

# ============================================================
# 6. UNIR TODO
# ============================================================
final <- merge(articulos[, c("article_id", "title", "year", "journal", "doi")],
               decisiones_finales[, c("article_id", "decision")],
               by = "article_id", all.x = TRUE)
final <- merge(final, razones_finales[, c("article_id", "razon")],
               by = "article_id", all.x = TRUE)

# Rellenar NA
final$decision[is.na(final$decision)] <- "UNDECIDED"
final$razon[is.na(final$razon)] <- ""
final$categoria_exclusion <- ifelse(grepl("^E[0-9]", final$razon),
                                    substr(final$razon, 1, 2), "")

# Renombrar para consistencia
final$TI <- final$title
final$Y1 <- final$year
final$T2 <- final$journal
final$DO <- final$doi

# ============================================================
# 7. ORDENAR
# ============================================================
final <- final[order(final$decision, final$razon, final$TI), ]

# ============================================================
# 8. EXPORTAR TABLA COMPLETA
# ============================================================
write.csv(final[, c("article_id", "decision", "razon", "categoria_exclusion",
                    "TI", "Y1", "T2", "DO")],
          "../PRISMA_tabla_completa_291.csv", row.names = FALSE)

# ============================================================
# 9. RESUMEN POR CATEGORÍA DE EXCLUSIÓN
# ============================================================
resumen <- as.data.frame(table(final$categoria_exclusion))
colnames(resumen) <- c("Categoria", "N_articulos")
resumen <- resumen[order(-resumen$N_articulos), ]
write.csv(resumen, "../PRISMA_resumen_exclusiones_291.csv", row.names = FALSE)

# ============================================================
# 10. ELEGIBLES (INCLUDE + MAYBE)
# ============================================================
elegibles <- final[final$decision %in% c("INCLUDE", "MAYBE"), ]
write.csv(elegibles[, c("article_id", "decision", "TI", "Y1", "T2", "DO")],
          "../PRISMA_elegibles_291.csv", row.names = FALSE)

# ============================================================
# 11. REPORTE FINAL
# ============================================================
cat("\n========== RESUMEN FINAL 291 ==========\n")
cat("Total artículos cribados:", nrow(final), "\n")
cat("\nDistribución de decisiones:\n")
print(table(final$decision))
cat("\nDistribución por categoría de exclusión:\n")
print(resumen)
cat("\nTotal elegibles (INCLUDE + MAYBE):", nrow(elegibles), "\n")
cat("\n========== ARCHIVOS EXPORTADOS ==========\n")
cat("  - PRISMA_tabla_completa_291.csv\n")
cat("  - PRISMA_resumen_exclusiones_291.csv\n")
cat("  - PRISMA_elegibles_291.csv\n")
