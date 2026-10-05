# Reasignar razón a los 4 artículos excluidos sin etiqueta
# Autor: Álvaro Hernández Montiel

final <- read.csv("../PRISMA_tabla_completa_291.csv", stringsAsFactors = FALSE)

# Identificar los 4 sin razón
sin_razon <- final$decision == "EXCLUDE" & final$razon == ""
cat("Artículos a corregir:", sum(sin_razon), "\n\n")

# Ver los títulos
print(final$TI[sin_razon], row.names = FALSE)

# Reasignar razón manualmente basado en el título
# Artículo 1: Catla catla → E7
# Artículo 2: Crassostrea gigas → E1
# Artículo 3: Sebastes schlegelii transcriptoma dinámico → E6 (no larvas/intestino como foco)
# Artículo 4: Rapana venosa → E1

razones_nuevas <- c(
  "E7 - Non-marine species",
  "E1 - Not a marine or diadromous teleost",
  "E6 - Non-relevant tissue",
  "E1 - Not a marine or diadromous teleost"
)

final$razon[sin_razon] <- razones_nuevas
final$categoria_exclusion[sin_razon] <- substr(razones_nuevas, 1, 2)

# Exportar
write.csv(final, "../PRISMA_tabla_completa_291_final.csv", row.names = FALSE)

# Regenerar resumen
resumen <- as.data.frame(table(final$categoria_exclusion))
colnames(resumen) <- c("Categoria", "N_articulos")
resumen <- resumen[resumen$Categoria != "", ]  # Excluir elegibles
resumen <- resumen[order(-resumen$N_articulos), ]
write.csv(resumen, "../PRISMA_resumen_exclusiones_291_final.csv", row.names = FALSE)

# Reporte
cat("\n========== RESUMEN FINAL CORREGIDO ==========\n")
cat("EXCLUDE con razón asignada:", sum(final$decision == "EXCLUDE"), "\n")
cat("\nDistribución de exclusiones:\n")
print(resumen)
cat("\n\nElegibles (INCLUDE + MAYBE):", sum(final$decision %in% c("INCLUDE", "MAYBE")), "\n")
