# Script para generar tabla completa de los 199 artículos
# Autor: Álvaro Hernández Montiel

# 1. Leer el log de decisiones
log <- read.csv("customizations_log.csv", stringsAsFactors = FALSE)
log$created_at <- as.POSIXct(log$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")

# 2. Separar decisiones y razones
decisiones <- log[log$key == "included", ]
razones <- log[grepl("__EXR__", log$key), ]

# 3. Quedarse con la decisión MÁS RECIENTE por artículo
decisiones <- decisiones[order(decisiones$article_id, decisiones$created_at), ]
decisiones_finales <- decisiones[!duplicated(decisiones$article_id, fromLast = TRUE), ]
decisiones_finales$decision <- ifelse(decisiones_finales$value == 1, "INCLUDE",
                               ifelse(decisiones_finales$value == 0, "MAYBE", "EXCLUDE"))

# 4. Quedarse con la razón MÁS RECIENTE por artículo
# Filtrar solo razones de exclusión (E1-E7), no de inclusión (I1-I6)
razones_exclusion <- razones[grepl("__EXR__E[0-9]", razones$key), ]
razones_exclusion <- razones_exclusion[order(razones_exclusion$article_id, razones_exclusion$created_at), ]
razones_finales <- razones_exclusion[!duplicated(razones_exclusion$article_id, fromLast = TRUE), ]
razones_finales$razon <- gsub("__EXR__", "", razones_finales$key)
razones_finales$razon <- gsub('"', '', razones_finales$razon)

# 5. Leer el RIS
ris_lines <- readLines("articles.ris")
articulos <- data.frame()
i <- 1
while (i <= length(ris_lines)) {
  if (grepl("^TY  -", ris_lines[i])) {
    registro <- list(AN = "", TI = "", Y1 = "", T2 = "", DO = "", AB = "")
    j <- i + 1
    while (j <= length(ris_lines) && !grepl("^ER  -", ris_lines[j])) {
      if (grepl("^AN  -", ris_lines[j])) registro$AN <- sub("^AN  - ", "", ris_lines[j])
      if (grepl("^TI  -", ris_lines[j])) registro$TI <- sub("^TI  - ", "", ris_lines[j])
      if (grepl("^Y1  -", ris_lines[j])) registro$Y1 <- sub("^Y1  - ", "", ris_lines[j])
      if (grepl("^T2  -", ris_lines[j])) registro$T2 <- sub("^T2  - ", "", ris_lines[j])
      if (grepl("^DO  -", ris_lines[j])) registro$DO <- sub("^DO  - ", "", ris_lines[j])
      if (grepl("^AB  -", ris_lines[j])) registro$AB <- sub("^AB  - ", "", ris_lines[j])
      j <- j + 1
    }
    articulos <- rbind(articulos, as.data.frame(registro, stringsAsFactors = FALSE))
    i <- j
  }
  i <- i + 1
}
articulos$article_id <- gsub("rayyan-", "", articulos$AN)

# 6. Unir todo
final <- merge(articulos, decisiones_finales[, c("article_id", "decision")],
               by = "article_id", all.x = TRUE)
final <- merge(final, razones_finales[, c("article_id", "razon")],
               by = "article_id", all.x = TRUE)
final$decision[is.na(final$decision)] <- "UNDECIDED"
final$razon[is.na(final$razon)] <- ""

# 7. Añadir columna de categoría de exclusión (solo el código E)
final$categoria_exclusion <- ifelse(grepl("^E[0-9]", final$razon),
                                    substr(final$razon, 1, 2), "")

# 8. Ordenar por decisión y luego por razón
final <- final[order(final$decision, final$razon, final$TI), ]

# 9. Exportar tabla completa
write.csv(final[, c("article_id", "decision", "razon", "categoria_exclusion",
                    "TI", "Y1", "T2", "DO")],
          "PRISMA_tabla_completa_199.csv", row.names = FALSE)

# 10. Tabla resumen por categoría de exclusión
resumen <- as.data.frame(table(final$categoria_exclusion))
colnames(resumen) <- c("Categoria", "N_articulos")
resumen <- resumen[order(-resumen$N_articulos), ]
write.csv(resumen, "PRISMA_resumen_exclusiones.csv", row.names = FALSE)

# 11. Tabla de INCLUDE + MAYBE para elegibilidad
elegibles <- final[final$decision %in% c("INCLUDE", "MAYBE"), ]
write.csv(elegibles[, c("article_id", "decision", "TI", "Y1", "T2", "DO")],
          "PRISMA_elegibles_17.csv", row.names = FALSE)

# 12. Reporte en consola
cat("\n========== RESUMEN PRISMA ==========\n")
cat("Total artículos cribados:", nrow(final), "\n")
cat("\nDistribución de decisiones:\n")
print(table(final$decision))
cat("\nDistribución por categoría de exclusión:\n")
print(resumen)
cat("\n========== ARCHIVOS EXPORTADOS ==========\n")
cat("  - PRISMA_tabla_completa_199.csv\n")
cat("  - PRISMA_resumen_exclusiones.csv\n")
cat("  - PRISMA_elegibles_17.csv\n")
