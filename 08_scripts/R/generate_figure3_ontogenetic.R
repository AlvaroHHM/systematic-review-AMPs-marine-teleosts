#!/usr/bin/env Rscript
# =============================================================================
# generate_figure3_ontogenetic.R
# -----------------------------------------------------------------------------
# Figure 3: Ontogenetic succession of mucosal immunity in marine teleost larvae
# Style: cowplot + ggsci (pal_aaas), consistent with Figure 2
# Output: PNG (300 dpi) + PDF (vectorial)
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(cowplot)
  library(ggsci)
  library(dplyr)
  library(ggtext)
  library(scales)
  library(ragg)
})

# =============================================================================
# 1. PALETA (consistente con Figura 2)
# =============================================================================

aaas <- pal_aaas("default", alpha = 1)(10)
col_p1 <- aaas[2]   # rojo  (#EE0000)
col_p2 <- aaas[3]   # verde (#008B45)
col_p3 <- aaas[1]   # azul  (#3B4992)

bg_p1 <- scales::alpha(col_p1, 0.10)
bg_p2 <- scales::alpha(col_p2, 0.10)
bg_p3 <- scales::alpha(col_p3, 0.10)

col_text          <- "#212121"
col_grey          <- "#424242"
col_border        <- "#B0BEC5"
col_timeline      <- "#37474F"
col_summary_bg    <- "#ECEFF1"
col_summary_border<- "#90A4AE"

# =============================================================================
# 2. GEOMETRÍA (coordenadas x: 0-100, y: 0-100)
# =============================================================================

# Columna izquierda (labels) y 3 columnas de contenido
col_starts  <- c(18, 44, 70)
col_ends    <- c(42, 68, 94)
col_centers <- (col_starts + col_ends) / 2

# Filas (de arriba a abajo)
phase_top    <- 85;  phase_bottom <- 78
row1_top     <- 76;  row1_bottom  <- 68
row2_top     <- 66;  row2_bottom  <- 58
row3_top     <- 56;  row3_bottom  <- 48
row4_top     <- 46;  row4_bottom  <- 38
sum_top      <- 33;  sum_bottom   <- 5

# =============================================================================
# 3. TEMA BASE (cowplot + axis limpieza)
# =============================================================================

theme_schematic <- theme_cowplot(font_size = 12, font_family = "sans") +
  theme(
    axis.line        = element_blank(),
    axis.text        = element_blank(),
    axis.title       = element_blank(),
    axis.ticks       = element_blank(),
    panel.grid       = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    plot.margin      = margin(10, 10, 10, 10)
  )

# =============================================================================
# 4. LIENZO VACÍO
# =============================================================================

p <- ggplot() +
  xlim(0, 100) + ylim(0, 100) +
  theme_schematic

# =============================================================================
# 5. TÍTULO
# =============================================================================

#p <- p + annotate("text", x = 50, y = 97,
  #                label = "FIGURE 3. Ontogenetic succession of mucosal immunity in marine teleost larvae",
              #    fontface = "bold", size = 11, color = col_text)

# =============================================================================
# 6. TIMELINE con marcadores dpe
# =============================================================================

tl_y <- 91.5
tl_x_start <- col_starts[1]
tl_x_end   <- col_ends[3]

# Línea principal
p <- p + annotate("segment", x = tl_x_start, xend = tl_x_end,
                  y = tl_y, yend = tl_y,
                  linewidth = 1.2, color = col_timeline,
                  lineend = "butt")

# Marcadores dpe
dpe_x      <- seq(tl_x_start, tl_x_end, length.out = 6)
dpe_labels <- c("0 dpe", "3 dpe", "6 dpe", "9 dpe", "12 dpe", "15+ dpe")

for (i in seq_along(dpe_x)) {
  p <- p + annotate("segment",
                    x = dpe_x[i], xend = dpe_x[i],
                    y = tl_y - 1, yend = tl_y + 1,
                    linewidth = 0.9, color = col_timeline)
  p <- p + annotate("text",
                    x = dpe_x[i], y = tl_y + 2.2,
                    label = dpe_labels[i],
                    fontface = "bold", size = 5, color = col_text)
}

# =============================================================================
# 7. CABECERAS DE FASE (3 cajas)
# =============================================================================

phase_info <- data.frame(
  xmin     = col_starts,
  xmax     = col_ends,
  ymin     = phase_bottom,
  ymax     = phase_top,
  fill_bg  = c(bg_p1, bg_p2, bg_p3),
  col_bord = c(col_p1, col_p2, col_p3),
  title    = c("PHASE 1 (Fragile)", "PHASE 2 (Transition)", "PHASE 3 (Adapted)"),
  subtitle = c("Lecithotrophic Phase", "Live Feed Transition", "Post-flexion / Weaning"),
  range    = c("(0-3 dpe)", "(4-12 dpe)", "(15+ dpe)")
)

p <- p + geom_rect(data = phase_info,
                   aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                   fill = phase_info$fill_bg,
                   color = phase_info$col_bord,
                   linewidth = 1.2, inherit.aes = FALSE)

for (i in 1:3) {
  p <- p + annotate("text", x = col_centers[i], y = phase_top - 1.8,
                    label = phase_info$title[i],
                    fontface = "bold", size = 5,
                    color = phase_info$col_bord[i])
  p <- p + annotate("text", x = col_centers[i], y = phase_top - 4.2,
                    label = phase_info$subtitle[i],
                    fontface = "bold", size = 5, color = col_text)
  p <- p + annotate("text", x = col_centers[i], y = phase_top - 6.2,
                    label = phase_info$range[i],
                    size = 5, color = col_grey)
}

# =============================================================================
# 8. FILAS DE CONTENIDO (4 filas × 3 columnas)
# =============================================================================

rows <- list(
  list(
    label    = "FEED TYPE",
    sublabel = NULL,
    ytop     = row1_top,
    ybottom  = row1_bottom,
    cells    = c(
      "Yolk reserves\n(endogenous)",
      "Rotifers + Artemia\n(live prey introduction)",
      "Formulated feed\n(inert diet)"
    )
  ),
  list(
    label    = "MICROBIAL\nSUCCESSION",
    sublabel = "(Li et al., 2026)",
    ytop     = row2_top,
    ybottom  = row2_bottom,
    cells    = c(
      "Uncolonized /\nLow microbial density",
      "Pseudoalteromonas\n\u2192 Stenotrophomonas\n\u2192 Cohaesibacter",
      "Psychrobacter dominance\n(core genus from day 19)"
    )
  ),
  list(
    label    = "MUCOSAL\nEFFECTORS",
    sublabel = NULL,
    ytop     = row3_top,
    ybottom  = row3_bottom,
    cells    = c(
      "UBIM / S30FAU\n(maternal transcripts)",
      "LEG3, CCL11, CCL20\n(lectins + chemokines)",
      "PA2G1B, piscidins (moro1),\n\u03b2-defensins, HAMP2"
    )
  ),
  list(
    label    = "GUT REGIONAL\nSPECIALIZATION",
    sublabel = "(Calduch-Giner 2016;\nXue 2026)",
    ytop     = row4_top,
    ybottom  = row4_bottom,
    cells    = c(
      "Undifferentiated\ndigestive tube",
      "Midgut mucosal\ndifferentiation",
      "Anterior/Midgut: Nutrients\nPosterior: Defense, BEST4+ &\nlysosome-rich enterocytes"
    )
  )
)

for (r in rows) {
  y_center <- (r$ytop + r$ybottom) / 2

  # ── Label de fila (columna izquierda, alineada a la derecha) ──
  if (is.null(r$sublabel)) {
    p <- p + annotate("text", x = 16, y = y_center,
                      label = r$label,
                      hjust = 1, vjust = 0.5,
                      fontface = "bold", size = 5,
                      color = col_text, lineheight = 1.1)
  } else {
    p <- p + annotate("text", x = 16, y = y_center + 1.5,
                      label = r$label,
                      hjust = 1, vjust = 0.5,
                      fontface = "bold", size = 3.3,
                      color = col_text, lineheight = 1.1)
    p <- p + annotate("text", x = 16, y = y_center - 2.2,
                      label = r$sublabel,
                      hjust = 1, vjust = 0.5,
                      fontface = "italic", size = 5,
                      color = col_grey, lineheight = 1.1)
  }

  # ── Celdas de contenido (3 columnas) ──
  for (i in 1:3) {
    # Caja
    p <- p + annotate("rect",
                      xmin = col_starts[i], xmax = col_ends[i],
                      ymin = r$ybottom, ymax = r$ytop,
                      fill = "white", color = col_border,
                      linewidth = 0.4)
    # Texto
    p <- p + annotate("text", x = col_centers[i], y = y_center,
                      label = r$cells[i],
                      hjust = 0.5, vjust = 0.5,
                      size = 5, color = col_text, lineheight = 1.35)
  }
}

# =============================================================================
# 9. CAJA INFERIOR (KEY TRANSITIONS & MILESTONES)
# =============================================================================

p <- p + annotate("rect",
                  xmin = col_starts[1], xmax = col_ends[3],
                  ymin = sum_bottom, ymax = sum_top,
                  fill = col_summary_bg, color = col_summary_border,
                  linewidth = 0.9)

# Título del summary
p <- p + annotate("text",
                  x = col_starts[1] + 2, y = sum_top - 2.8,
                  label = "KEY TRANSITIONS & ONTOGENETIC MILESTONES:",
                  hjust = 0, vjust = 0.5,
                  fontface = "bold", size = 5, color = col_text)

# Bullets con markdown (bold + italic + normal)
bullets_df <- data.frame(
  x = col_starts[1] + 2,
  y = c(sum_top - 8, sum_top - 14.5, sum_top - 21),  # más separación vertical
  label = c(
    "\u2022 **Mouth opening (3\u20134 dpe):**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;First exogenous feed intake and initiation of environmental microbial exposure.",
    "\u2022 **Live feed transition (4\u201312 dpe):**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Active bacterial succession and recruitment of chemokines/lectins for mucosal defense.",
    "\u2022 **Formulated feed & weaning (15+ dpe):**<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*Psychrobacter* core dominance, expression of mature piscidins (moro1), and gut compartmentalization."
  )
)

p <- p + geom_richtext(
  data = bullets_df,
  aes(x = x, y = y, label = label),
  hjust = 0, vjust = 0.5,
  size = 5, color = col_text, family = "sans",
  fill = NA, label.color = NA,
  label.padding = unit(0, "lines"),
  label.margin = unit(0, "lines")
)

# =============================================================================
# 10. GUARDAR
# =============================================================================

ggsave("Figure_3_Ontogenetic_Succession.png", plot = p,
       width = 16, height = 12.5, units = "in", dpi = 300,
       device = ragg::agg_png, bg = "white")

ggsave("Figure_3_Ontogenetic_Succession.pdf", plot = p,
       width = 16, height = 12.5, units = "in",
       device = cairo_pdf, bg = "white")

cat("\n\u2713 PNG: Figure_3_Ontogenetic_Succession.png\n")
cat("\u2713 PDF: Figure_3_Ontogenetic_Succession.pdf\n")
