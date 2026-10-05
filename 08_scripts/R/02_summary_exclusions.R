# =============================================================================
# VERIFICACIÓN FINAL DE NÚMEROS PRISMA
# Revisión sistemática AMPs en teleósteos marinos
# =============================================================================

cat("\n==================================================================\n")
cat("VERIFICACIÓN DE NÚMEROS PRISMA\n")
cat("==================================================================\n\n")

# ---- 1. Leer archivos ----
setwd("~/Desktop/Post-Doctorado/Articulos en proceso/AMP_totoaba/review/02_rayyan")

tabla <- read.csv("PRISMA_tabla_completa_291_final.csv", stringsAsFactors = FALSE)
resumen <- read.csv("PRISMA_resumen_exclusiones_291_final.csv", stringsAsFactors = FALSE)

# ---- 2. Total de registros en la tabla ----
cat("1. TOTAL DE REGISTROS EN LA TABLA\n")
cat("   Filas totales: ", nrow(tabla), "\n\n")

# ---- 3. Distribución de decisiones ----
cat("2. DISTRIBUCIÓN DE DECISIONES\n")
print(table(tabla$decision, useNA = "ifany"))
cat("\n")

# ---- 4. Distribución de categorías de exclusión ----
cat("3. CATEGORÍAS DE EXCLUSIÓN (desde la tabla)\n")
print(table(tabla$categoria_exclusion, useNA = "ifany"))
cat("\n")

# ---- 5. Suma de categorías de exclusión ----
cat("4. SUMA DE CATEGORÍAS DE EXCLUSIÓN\n")
excl <- tabla[tabla$decision == "EXCLUDE", ]
conteo_cat <- table(excl$categoria_exclusion, useNA = "ifany")
print(conteo_cat)
cat("   Suma total: ", sum(conteo_cat), "\n\n")

# ---- 6. Resumen oficial ----
cat("5. RESUMEN OFICIAL (PRISMA_resumen_exclusiones_291_final.csv)\n")
print(resumen)
cat("   Suma del resumen: ", sum(resumen$N_articulos), "\n\n")

# ---- 7. Buscar registros duplicados (mismo article_id) ----
cat("6. REGISTROS DUPLICADOS EN LA TABLA\n")
dups <- tabla[duplicated(tabla$article_id) | duplicated(tabla$article_id, fromLast = TRUE), ]
if (nrow(dups) > 0) {
  cat("   ENCONTRADOS ", nrow(dups), " registros duplicados:\n")
  print(dups[, c("article_id", "decision", "razon", "categoria_exclusion")])
} else {
  cat("   No hay article_id duplicados.\n")
}
cat("\n")

# ---- 8. Buscar EXCLUDE sin categoría ----
cat("7. EXCLUDE SIN CATEGORÍA ASIGNADA\n")
sin_cat <- excl[is.na(excl$categoria_exclusion) | excl$categoria_exclusion == "", ]
if (nrow(sin_cat) > 0) {
  cat("   ENCONTRADOS ", nrow(sin_cat), " registros sin categoría:\n")
  print(sin_cat[, c("article_id", "decision", "razon")])
} else {
  cat("   Todos los EXCLUDE tienen categoría asignada.\n")
}
cat("\n")

# ---- 9. Buscar EXCLUDE con múltiples razones ----
cat("8. EXCLUDE CON MÚLTIPLES RAZONES (separadas por ;)\n")
multi <- excl[grepl(";", excl$razon, fixed = TRUE), ]
if (nrow(multi) > 0) {
  cat("   ENCONTRADOS ", nrow(multi), " registros con múltiples razones:\n")
  print(multi[, c("article_id", "razon", "categoria_exclusion")])
} else {
  cat("   No hay EXCLUDE con múltiples razones.\n")
}
cat("\n")

# ---- 10. Diagnóstico final ----
cat("==================================================================\n")
cat("DIAGNÓSTICO FINAL\n")
cat("==================================================================\n")
cat("Registros totales cribados:  291\n")
cat("Registros EXCLUDE:           ", nrow(excl), "\n")
cat("Registros INCLUDE:           ", sum(tabla$decision == "INCLUDE"), "\n")
cat("Registros MAYBE:             ", sum(tabla$decision == "MAYBE"), "\n")
cat("\n")
cat("Suma EXCLUDE + INCLUDE + MAYBE: ", 
    nrow(excl) + sum(tabla$decision == "INCLUDE") + sum(tabla$decision == "MAYBE"), "\n")
cat("Debería ser: 291\n\n")

cat("Suma de categorías de exclusión en la tabla: ", sum(conteo_cat), "\n")
cat("Suma del resumen oficial:                    ", sum(resumen$N_articulos), "\n")
cat("\n")
if (sum(conteo_cat) == sum(resumen$N_articulos)) {
  cat("✅ Los números coinciden.\n")
} else {
  cat("⚠️ Hay una discrepancia de ", 
      sum(resumen$N_articulos) - sum(conteo_cat), " registros.\n")
}
cat("==================================================================\n")
