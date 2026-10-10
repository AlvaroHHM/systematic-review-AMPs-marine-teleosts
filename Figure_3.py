import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Configuración global de tipografía y resolución
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['font.family'] = 'sans-serif'

# 1. Datos completos de los N = 24 estudios incluidos en la revisión
data = [
    {"study": "Zhang et al. (2021)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic-Demersal"},
    {"study": "Choi et al. (2025)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic"},
    {"study": "Jeon et al. (2026)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic"},
    {"study": "Bo et al. (2019)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic-Demersal"},
    {"study": "Ferez-Puche et al. (2024)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Umasuthan et al. (2016)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic-Demersal"},
    {"study": "Fu et al. (2022)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic"},
    {"study": "Zheng et al. (2018)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Machado et al. (2020)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Moderate", "d5_design": "Low", "overall": "Low (Minor concerns)", "habitat": "Pelagic"},
    {"study": "Liang et al. (2022)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Pelagic / Diadromous"},
    {"study": "Guerrero-Tortolero et al. (2021)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Pelagic"},
    {"study": "Yúfera et al. (2012)", "d1_rep": "Moderate", "d2_sra": "Low", "d3_depth": "Moderate", "d4_val": "Moderate", "d5_design": "Low", "overall": "Moderate", "habitat": "Demersal"},
    {"study": "Calduch-Giner et al. (2016)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Anderson et al. (2018)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Darias et al. (2008)", "d1_rep": "Low", "d2_sra": "Moderate", "d3_depth": "Moderate", "d4_val": "Low", "d5_design": "Low", "overall": "Moderate", "habitat": "Demersal"},
    {"study": "Yan et al. (2023)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic-Demersal"},
    {"study": "Xue et al. (2026)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Benthic-Demersal"},
    {"study": "Pomianowski et al. (2021)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Moderate", "d5_design": "Low", "overall": "Low (Minor concerns)", "habitat": "Benthic"},
    {"study": "Najafpour et al. (2024)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Ferraresso et al. (2008)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Moderate", "d4_val": "Low", "d5_design": "Low", "overall": "Low (Minor concerns)", "habitat": "Demersal"},
    {"study": "Guo et al. (2023)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Multi-habitat (DB)"},
    {"study": "Li et al. (2026)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Liu et al. (2026)", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Demersal"},
    {"study": "Liu et al. (2026) iFish", "d1_rep": "Low", "d2_sra": "Low", "d3_depth": "Low", "d4_val": "Low", "d5_design": "Low", "overall": "Low", "habitat": "Multi-habitat (DB)"}
]

# Intentar cargar CSV si existe, si no usar datos embebidos
excluded = ["Tessera et al. (2012)", "Asensio-Calavia et al. (2026)", "Miccoli et al. (2021)", "Wang et al. (2024)"]
try:
    df = pd.read_csv('Table_S2_Risk_of_Bias.csv')
    df = df[~df['study'].isin(excluded)].copy()
except FileNotFoundError:
    df = pd.DataFrame(data)

n_total = len(df)

# Dominios del marco MINSEQE
domains = [
    ('d1_rep', 'D1. Biological Replication (n ≥ 3)'),
    ('d2_sra', 'D2. Repository Data Accession (SRA/GEO)'),
    ('d3_depth', 'D3. Depth & BUSCO Completeness (>80%)'),
    ('d4_val', 'D4. Orthogonal Validation (qRT-PCR/MIC)'),
    ('d5_design', 'D5. Controlled Experimental Design')
]

summary_data = []
for col, name in domains:
    if col in df.columns:
        counts = df[col].value_counts()
        summary_data.append({
            'Domain': name,
            'Low Risk': (counts.get('Low', 0) / n_total) * 100,
            'Some Concerns': (counts.get('Moderate', 0) / n_total) * 100,
            'High Risk': (counts.get('High', 0) / n_total) * 100
        })

summary_df = pd.DataFrame(summary_data)

# 2. Configurar el lienzo de 3 Paneles
fig = plt.figure(figsize=(16, 11), dpi=300)
gs = fig.add_gridspec(2, 2, height_ratios=[1, 1.1], width_ratios=[1.5, 1.0],
                      hspace=0.55, wspace=0.30)

ax1 = fig.add_subplot(gs[0, :])
ax2 = fig.add_subplot(gs[1, 0])
ax3 = fig.add_subplot(gs[1, 1])

# Paleta: Verde (Bajo), Azul (Intermedio), Rojo (Moderado/Preocupaciones)
c_low = '#27AE60'
c_blue = '#2980B9'
c_red = '#E74C3C'

# --- PANEL A: Barras MINSEQE ---
y_pos = np.arange(len(summary_df))
height = 0.48
ax1.barh(y_pos, summary_df['Low Risk'], height, color=c_low, label='Low Risk')
ax1.barh(y_pos, summary_df['Some Concerns'], height, left=summary_df['Low Risk'], color=c_red, label='Some Concerns')
ax1.barh(y_pos, summary_df['High Risk'], height, left=summary_df['Low Risk'] + summary_df['Some Concerns'], color='#900C3F', label='High Risk')
ax1.set_yticks(y_pos)
ax1.set_yticklabels(summary_df['Domain'], fontsize=5, fontweight='bold', color='#2C3E50')
ax1.invert_yaxis()
ax1.set_xlabel('Percentage of Included Studies (%)', fontsize=6, fontweight='bold', color='#2C3E50')
ax1.set_xlim(0, 100)
ax1.tick_params(axis='x', labelsize=4)   # <-- Números del eje X
ax1.set_title('A', fontsize=8, fontweight='bold', pad=10, loc='left', color='#1A365D')

for i in range(len(summary_df)):
    low_v = summary_df.loc[i, 'Low Risk']
    mod_v = summary_df.loc[i, 'Some Concerns']
    if low_v > 10:
        ax1.text(low_v / 2, i, f"{low_v:.1f}%", ha='center', va='center', color='white', fontweight='bold', fontsize=7)
    if mod_v > 3:
        ax1.text(low_v + (mod_v / 2), i, f"{mod_v:.1f}%", ha='center', va='center', color='white', fontweight='bold', fontsize=6)

ax1.legend(loc='upper right', bbox_to_anchor=(1.0, 1.28), ncol=3, frameon=False, fontsize=6)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# --- PANEL B: Dona Calidad Global ---
sizes_b = [18, 4, 2]
labels_b = ['Low Risk\n(75.0%, n=18)', 'Minor Concerns\n(16.7%, n=4)', 'Moderate Risk\n(8.3%, n=2)']
colors_b = [c_low, c_blue, c_red]
wedges_b, texts_b, autotexts_b = ax2.pie(
    sizes_b,
    labels=labels_b,
    colors=colors_b,
    autopct='%1.1f%%',
    startangle=140,
    pctdistance=0.72,
    textprops=dict(color="#2C3E50", fontsize=5, fontweight='bold')
)
for autotext in autotexts_b:
    autotext.set_color('white')
    autotext.set_fontweight('bold')
centre_b = plt.Circle((0, 0), 0.52, fc='white')
ax2.add_artist(centre_b)
ax2.text(0, 0, "N = 24\nStudies", ha='center', va='center', fontsize=5, fontweight='bold', color='#1A365D')
ax2.set_title('B', fontsize=8, fontweight='bold', pad=10, loc='left', color='#1A365D')

# --- PANEL C: Dona Hábitat Ecológico ---
sizes_c = [10, 5, 4, 3, 2]
labels_c = [
    'Demersal\n(41.7%, n=10)',
    'Benthic-Demersal\n(20.8%, n=5)',
    'Benthic\n(16.7%, n=4)',
    'Pelagic / Diadromous\n(12.5%, n=3)',
    'Multi-habitat DB\n(8.3%, n=2)'
]
colors_c = [c_blue, '#9B59B6', c_red, c_low, '#95A5A6']
wedges_c, texts_c, autotexts_c = ax3.pie(
    sizes_c,
    labels=labels_c,
    colors=colors_c,
    autopct='%1.1f%%',
    startangle=120,
    pctdistance=0.72,
    textprops=dict(color="#2C3E50", fontsize=5, fontweight='bold')
)
for autotext in autotexts_c:
    autotext.set_color('white')
    autotext.set_fontweight('bold')
centre_c = plt.Circle((0, 0), 0.52, fc='white')
ax3.add_artist(centre_c)
ax3.text(0, 0, "14 Teleost\nSpecies", ha='center', va='center', fontsize=5, fontweight='bold', color='#1A365D')
ax3.set_title('C', fontsize=8, fontweight='bold', pad=10, loc='left', color='#1A365D')

# 3. Ajustar márgenes para que los labels del Panel A no se salgan
fig.subplots_adjust(left=0.30, right=0.95, top=0.92, bottom=0.05,
                    hspace=0.38, wspace=0.30)

# Guardar con márgenes ajustados
plt.savefig('Figure3_Risk_of_Bias_Summary.png', dpi=300, bbox_inches='tight', pad_inches=0.2)
plt.show()
