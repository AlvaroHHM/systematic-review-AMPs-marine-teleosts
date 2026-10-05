# Script para procesar exportación final de Rayyan (CORREGIDO)
# Autor: Álvaro Hernández Montiel

# 1. Leer el log de decisiones
log <- read.csv("customizations_log.csv", stringsAsFactors = FALSE)
cat("Registros totales en el log:", nrow(log), "\n")

# 2. Convertir created_at a formato de fecha-hora
log$created_at <- as.POSIXct(log$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")

# 3. Separar decisiones (included) y razones (__EXR__)
decisiones <- log[log$key == "included", ]
razones <- log[grepl("__EXR__", log$key), ]

# 4. Para cada artículo, quedarse con la decisión MÁS RECIENTE
decisiones <- decisiones[order(decisiones$article_id, decisiones$created_at), ]
decisiones_finales <- decisiones[!duplicated(decisiones$article_id, fromLast = TRUE), ]

cat("Decisiones únicas (finales):", nrow(decisiones_finales), "\n")

# 5. Mapear valores a etiquetas
decisiones_finales$decision <- ifelse(decisiones_finales$value == 1, "INCLUDE",
                               ifelse(decisiones_finales$value == 0, "MAYBE", "EXCLUDE"))

# 6. Extraer razones de exclusión MÁS RECIENTES por artículo
razones <- razones[order(razones$article_id, razones$created_at), ]
razones_finales <- razones[!duplicated(razones$article_id, fromLast = TRUE), ]
razones_finales$razon <- gsub("__EXR__", "", razones_finales$key)
razones_finales$razon <- gsub('"', '', razones_finales$razon)

# 7. Contar decisiones finales
cat("\nResumen de decisiones FINALES:\n")
print(table(decisiones_finales$decision))

# 8. Leer el RIS y extraer metadatos
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
cat("\nArtículos en el RIS:", nrow(articulos), "\n")

# 9. Extraer el ID numérico del campo AN
articulos$article_id <- gsub("rayyan-", "", articulos$AN)

# 10. Unir decisiones con metadatos
final <- merge(articulos, decisiones_finales[, c("article_id", "decision")],
               by = "article_id", all.x = TRUE)
final <- merge(final, razones_finales[, c("article_id", "razon")],
               by = "article_id", all.x = TRUE)

# 11. Reemplazar NA
final$decision[is.na(final$decision)] <- "UNDECIDED"
final$razon[is.na(final$razon)] <- ""

# 12. Ordenar por decisión
final <- final[order(final$decision, final$TI), ]

# 13. Exportar resultados
write.csv(final[, c("article_id", "decision", "razon", "TI", "Y1", "T2", "DO")],
          "rayyan_resultados_finales.csv", row.names = FALSE)

# 14. Exportar solo INCLUDE y MAYBE
incluidos <- final[final$decision == "INCLUDE", ]
maybe <- final[final$decision == "MAYBE", ]

write.csv(incluidos[, c("article_id", "TI", "Y1", "T2", "DO")],
          "rayyan_INCLUDE.csv", row.names = FALSE)
write.csv(maybe[, c("article_id", "TI", "Y1", "T2", "DO")],
          "rayyan_MAYBE.csv", row.names = FALSE)

cat("\n✅ Archivos exportados:\n")
cat("  - rayyan_resultados_finales.csv (todos)\n")
cat("  - rayyan_INCLUDE.csv (", nrow(incluidos), " artículos)\n", sep = "")
cat("  - rayyan_MAYBE.csv (", nrow(maybe), " artículos)\n", sep = "")
