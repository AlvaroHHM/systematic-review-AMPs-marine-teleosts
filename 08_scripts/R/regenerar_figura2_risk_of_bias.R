#!/usr/bin/env Rscript
# =============================================================================
# regenerar_figura2_risk_of_bias.R
# -----------------------------------------------------------------------------
# Cambios v3:
#   - Swap verde ↔ azul en paneles A) y C)
#   - Panel C ordenado por columna de agua (Demersal abajo, Multi-habitat arriba)
#   - pal_aaas (ggsci) + theme_cowplot + tags A), B), C)
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(patchwork)
  library(forcats)
  library(scales)
  library(ggsci)
  library(cowplot)
  library(ragg)
})

theme_set(
  theme_cowplot(font_size = 11, font_family = "sans", line_size = 0.4) +
    theme(
      plot.title = element_blank(),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9),
      legend.title = element_blank(),
      legend.text = element_text(size = 9),
      legend.position = "top",
      legend.key.size = unit(0.4, "cm"),
      plot.margin = margin(5, 8, 5, 5)
    )
)

# =============================================================================
# 1. CARGAR DATOS
# =============================================================================

df <- read_csv("Table_S2_Risk_of_Bias.csv", show_col_types = FALSE)
cat("Estudios cargados:", nrow(df), "\n")

# =============================================================================
# 2. MAPEO DE HÁBITATS
# =============================================================================

habitat_map <- c(
  "Zhang et al. (2021)"              = "Benthic-Demersal",
  "Choi et al. (2025)"               = "Benthic",
  "Jeon et al. (2026)"               = "Benthic",
  "Bo et al. (2019)"                 = "Benthic-Demersal",
  "Ferez-Puche et al. (2024)"        = "Demersal",
  "Umasuthan et al. (2016)"          = "Benthic-Demersal",
  "Fu et al. (2022)"                 = "Benthic",
  "Zheng et al. (2018)"              = "Demersal",
  "Machado et al. (2020)"            = "Pelagic",
  "Liang et al. (2022)"              = "Pelagic-Diadromous",
  "Guerrero-Tortolero et al. (2021)" = "Pelagic",
  "Yúfera et al. (2012)"             = "Demersal",
  "Calduch-Giner et al. (2016)"      = "Demersal",
  "Anderson et al. (2018)"           = "Demersal",
  "Darias et al. (2008)"             = "Demersal",
  "Yan et al. (2023)"                = "Benthic-Demersal",
  "Xue et al. (2026)"                = "Benthic-Demersal",
  "Pomianowski et al. (2021)"        = "Benthic",
  "Najafpour et al. (2024)"          = "Demersal",
  "Ferraresso et al. (2008)"         = "Demersal",
  "Guo et al. (2023)"                = "Multi-habitat",
  "Li et al. (2026)"                 = "Demersal",
  "Liu et al. (2026a)"               = "Demersal",
  "Liu et al. (2026b)"               = "Multi-habitat"
)

# ═══════════════════════════════════════════════════════════════════════════
# ORDEN DE COLUMNA DE AGUA (bottom → top en el eje Y):
#   Demersal (fondo profundo) 
#   → Benthic-Demersal
#   → Benthic (fondo somero)
#   → Pelagic/Diadromous (columna de agua)
#   → Multi-habitat (DB) (referencia arriba)
# Con fct_rev() en aes(), esto se invierte → Multi arriba, Demersal abajo
# ═══════════════════════════════════════════════════════════════════════════


habitat_water_column <- c(
  "Benthic",
  "Benthic-Demersal",
  "Demersal",
  "Pelagic/Diadromous",
  "Multi-habitat (DB)"
)

df <- df %>%
  mutate(
    habitat = habitat_map[study],
    habitat_grouped = case_when(
      habitat %in% c("Pelagic", "Pelagic-Diadromous") ~ "Pelagic/Diadromous",
      habitat == "Multi-habitat"                      ~ "Multi-habitat (DB)",
      TRUE                                            ~ habitat
    ),
    habitat_grouped = factor(habitat_grouped, levels = habitat_water_column),
    overall = factor(overall,
                     levels = c("Low", "Low (Minor concerns)", "Moderate")),
    overall_pretty = factor(
      recode(overall,
             "Low"                  = "Low risk",
             "Low (Minor concerns)" = "Low (minor concerns)",
             "Moderate"             = "Moderate risk"),
      levels = c("Low risk", "Low (minor concerns)", "Moderate risk")
    )
  )

n_studies <- nrow(df)

# =============================================================================
# 3. PALETAS — AAAS con SWAP verde ↔ azul
# =============================================================================

aaas_cols <- pal_aaas("default", alpha = 1)(10)
# aaas_cols[1] = #3B4992 (azul)
# aaas_cols[2] = #EE0000 (rojo)
# aaas_cols[3] = #008B45 (verde)
# aaas_cols[4] = #631879 (morado)
# aaas_cols[5] = #008280 (teal)

# ── SWAP: donde antes era verde ahora es azul y viceversa ──

# Panel A: Risk of bias (3 categorías)
pal_risk <- c(
  "Low risk"             = aaas_cols[1],  # AZUL (antes verde)
  "Low (minor concerns)" = aaas_cols[3],  # VERDE (antes azul)
  "Moderate risk"        = aaas_cols[2]   # rojo
)

# Panel C: Habitat (5 categorías)
pal_habitat <- c(
  "Benthic"            = aaas_cols[3],  # VERDE (antes azul)
  "Benthic-Demersal"   = aaas_cols[1],  # AZUL (antes verde)
  "Demersal"           = aaas_cols[4],  # morado
  "Pelagic/Diadromous" = aaas_cols[2],  # rojo
  "Multi-habitat (DB)" = aaas_cols[5]   # teal
)

# =============================================================================
# 4. PANEL A — Domain-specific stacked bar
# =============================================================================

df_long <- df %>%
  select(study, starts_with("d")) %>%
  pivot_longer(cols = starts_with("d"),
               names_to = "domain", values_to = "score") %>%
  mutate(
    domain_label = recode(domain,
      "d1_rep"    = "D1\nReplication",
      "d2_sra"    = "D2\nRepository",
      "d3_depth"  = "D3\nDepth/BUSCO",
      "d4_val"    = "D4\nValidation",
      "d5_design" = "D5\nDesign"
    ),
    domain_label = factor(domain_label,
                          levels = c("D1\nReplication", "D2\nRepository",
                                     "D3\nDepth/BUSCO", "D4\nValidation",
                                     "D5\nDesign")),
    score_clean = case_when(
      score == "Low" ~ "Low",
      grepl("Minor|Moderate", score) ~ "Minor concerns",
      TRUE ~ "High"
    ),
    score_clean = factor(score_clean,
                         levels = c("Low", "Minor concerns", "High"))
  )

df_domains <- df_long %>%
  count(domain_label, score_clean, .drop = FALSE) %>%
  group_by(domain_label) %>%
  mutate(label_y = cumsum(n) - n / 2) %>%
  ungroup()

# Paleta del panel A con SWAP (Low=azul, Minor=verde)
pal_domain <- c(
  "Low"            = aaas_cols[1],  # AZUL (antes verde)
  "Minor concerns" = aaas_cols[3],  # VERDE (antes azul)
  "High"           = aaas_cols[2]   # rojo
)

panel_A <- ggplot(df_domains,
                  aes(x = domain_label, y = n, fill = score_clean)) +
  geom_col(width = 0.7, color = "white", linewidth = 0.4) +
  geom_text(aes(label = ifelse(n > 0, n, ""), y = label_y),
            color = "white", fontface = "bold", size = 3.2) +
  scale_fill_manual(values = pal_domain, name = NULL) +
  scale_y_continuous(limits = c(0, n_studies + 1),
                     breaks = seq(0, n_studies, 5),
                     expand = c(0, 0)) +
  labs(x = NULL, y = "Number of studies") +
  theme(
    legend.position = "top",
    axis.text.x = element_text(size = 8.5, lineheight = 0.95),
    panel.grid.major.x = element_blank()
  )

# =============================================================================
# 5. PANEL B — Overall donut (sin cambios de color)
# =============================================================================

df_overall <- df %>%
  count(overall_pretty) %>%
  mutate(
    pct = n / sum(n),
    label = sprintf("%d/%d\n(%.1f%%)", n, n_studies, 100 * pct),
    ymax = cumsum(pct),
    ymin = c(0, head(cumsum(pct), -1)),
    ymid = (ymax + ymin) / 2
  )

panel_B <- ggplot(df_overall, aes(x = 2, y = pct, fill = overall_pretty)) +
  geom_col(width = 1, color = "white", linewidth = 1) +
  coord_polar(theta = "y", start = 0, direction = -1) +
  xlim(0.5, 2.5) +
  scale_fill_manual(values = pal_risk, name = NULL) +
  annotate("text", x = 0.5, y = 0,
           label = sprintf("n = %d", n_studies),
           size = 4, fontface = "bold", hjust = 0.5) +
  geom_text(
    data = df_overall,
    aes(x = 2.35, y = 1 - ymid, label = label),
    size = 2.9, fontface = "bold", color = "grey20",
    inherit.aes = FALSE
  ) +
  theme_void(base_size = 11) +
  theme(legend.position = "none", plot.margin = margin(5, 5, 5, 5))

# =============================================================================
# 6. PANEL C — Habitat stratification ORDENADO POR COLUMNA DE AGUA
# =============================================================================

df_habitat <- df %>%
  count(habitat_grouped) %>%
  mutate(pct = n / sum(n))

panel_C <- ggplot(df_habitat,
                  aes(x = n, y = habitat_grouped,
                      fill = habitat_grouped)) +
  geom_col(width = 0.7, color = "white", linewidth = 0.4) +
  geom_text(aes(label = sprintf("%d (%.1f%%)", n, 100 * pct)),
            hjust = -0.15, size = 3.2, fontface = "bold") +
  scale_fill_manual(values = pal_habitat, guide = "none") +
  scale_x_continuous(limits = c(0, max(df_habitat$n) + 3),
                     expand = c(0, 0)) +
  labs(x = "Number of studies", y = NULL) +
  theme(panel.grid.major.y = element_blank())

# =============================================================================
# 7. COMBINAR CON PATCHWORK — Tags A), B), C)
# =============================================================================

fig2 <- panel_A + panel_B + panel_C +
  plot_layout(widths = c(1.5, 1.1, 1.2)) +
  plot_annotation(
    tag_levels = list(c("A)", "B)", "C)")),
    theme = theme(
      plot.tag = element_text(face = "bold", size = 14, family = "sans"),
      plot.margin = margin(10, 10, 10, 10)
    )
  )

# =============================================================================
# 8. GUARDAR
# =============================================================================

ggsave("Figure_2_Risk_of_Bias_v3.png", plot = fig2,
       width = 14, height = 4.5, units = "in", dpi = 300,
       device = ragg::agg_png, bg = "white")

ggsave("Figure_2_Risk_of_Bias_v3.pdf", plot = fig2,
       width = 14, height = 4.5, units = "in",
       device = cairo_pdf, bg = "white")

cat("\n✓ PNG: Figure_2_Risk_of_Bias_v3.png\n")
cat("✓ PDF: Figure_2_Risk_of_Bias_v3.pdf\n\n")

# =============================================================================
# 9. VERIFICACIÓN
# =============================================================================

cat("=== DATOS VERIFICADOS ===\n")
cat(sprintf("Total estudios: %d\n", n_studies))
cat("\nRisk of Bias:\n")
print(df %>% count(overall_pretty) %>%
        mutate(pct = sprintf("%.1f%%", 100 * n / n_studies)))
cat("\nHábitats (orden en el gráfico, top → bottom):\n")
print(df_habitat %>%
        arrange(desc(habitat_grouped)) %>%
        mutate(pct = sprintf("%.1f%%", 100 * pct)) %>%
        select(habitat_grouped, n, pct))
