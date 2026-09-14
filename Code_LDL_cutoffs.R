# PAckages

library(arm)
library(MASS)
library(merTools)
library(lme4)
library(broom)
library(ggplot2)
library(tidyr)
library(sjPlot)
library(sjmisc)
library(dplyr)
library(lmerTest)
library(wesanderson)
library(effects)
library(MuMIn)
library(lsmeans)
library(glmmTMB)
library(optimx)
library(mgcv)
library(tidymv)
library(tidyverse)
library(broom.mixed)
library(car)
library(mediation)
library(medmod)
library(readxl)
library(readr)
library(ggsignif)

#Dataset
cognition_LDL_C <- read_excel("C:/Users/COREDE-PC03/Documents/Artigo Da ros Plots and figures/Codes/cognition_LDL_C.xlsx")
cognition_LDL_C <- as.data.frame(cognition_LDL_C)
cognition_LDL_C <- subset(cognition_LDL_C, cognition_LDL_C$AGE >= 65)

cognition_LDL_C <- cognition_LDL_C[!is.na(cognition_LDL_C$CLINICAL_LDL_C), ]

cognition_LDL_C$CLINICAL_LDL_C <- as.numeric(cognition_LDL_C$CLINICAL_LDL_C)

cognition_LDL_C$ABETA_positivity_ratio1 <- ifelse(cognition_LDL_C$ABETA_positivity_ratio == 1, "(A)+", "(A)-")
cognition_LDL_C$ABETA_positivity_ratio1 <- factor(cognition_LDL_C$ABETA_positivity_ratio1, levels = c("(A)-", "(A)+"))

## DEMOGRAFICOS - estratificado por A+ vs A-
table1::table1(~ AGE + CLINICAL_LDL_C + PTGENDER + PTEDUCAT + APOE4_status + MMSE +
                 ABETA_to_use + PTAU_to_use | ABETA_positivity_ratio1,
               data = subset(cognition_LDL_C, cognition_LDL_C$Years_bl_to_use == 0))


### ANALISES CROSS-SECTIONAL (baseline) ###

cognition_LDL_C$ABETA_bl_to_use <- as.numeric(cognition_LDL_C$ABETA_bl_to_use)
cognition_LDL_C$PTAU_bl_to_use <- as.numeric(cognition_LDL_C$PTAU_bl_to_use)
cognition_LDL_C$mPACCtrailsB_bl <- as.numeric(cognition_LDL_C$mPACCtrailsB_bl)

bl_data <- subset(cognition_LDL_C, Years_bl_to_use == 0)

# ============================================================
# Criar grupos por cut-offs clinicos de LDL-C (mmol/L)
# Optimal: <2.6 | Near optimal: 2.6-3.3 | Borderline high: 3.3-4.1
# High: 4.1-4.9 | Very high: >=4.9
# ============================================================
bl_data$LDL_group <- cut(
  bl_data$CLINICAL_LDL_C,
  breaks = c(-Inf, 2.6, 3.3, 4.1, 4.9, Inf),
  labels = c("Optimal\n(<2.6)",
             "Near optimal\n(2.6-3.3)",
             "Borderline high\n(3.3-4.1)",
             "High\n(4.1-4.9)",
             "Very high\n(\u22654.9)"),
  right = FALSE
)

# Tambem criar no dataset completo para analises longitudinais
cognition_LDL_C$LDL_group <- cut(
  cognition_LDL_C$CLINICAL_LDL_C,
  breaks = c(-Inf, 2.6, 3.3, 4.1, 4.9, Inf),
  labels = c("Optimal\n(<2.6)",
             "Near optimal\n(2.6-3.3)",
             "Borderline high\n(3.3-4.1)",
             "High\n(4.1-4.9)",
             "Very high\n(\u22654.9)"),
  right = FALSE
)

# Paleta de cores para 5 grupos
ldl_colors <- c("Optimal\n(<2.6)" = "#2E8B57",
                "Near optimal\n(2.6-3.3)" = "#F2AD00",
                "Borderline high\n(3.3-4.1)" = "#F98400",
                "High\n(4.1-4.9)" = "#B40F20",
                "Very high\n(\u22654.9)" = "#7B0051")

# Verificar N por grupo
table(bl_data$LDL_group)
table(bl_data$LDL_group, bl_data$ABETA_positivity_ratio1)

## DEMOGRAFICOS - estratificado por LDL group
table1::table1(~ AGE + CLINICAL_LDL_C + PTGENDER + PTEDUCAT + APOE4_status + MMSE +
                 ABETA_to_use + PTAU_to_use | LDL_group,
               data = bl_data)

# ============================================================
# Comparacoes entre todos os pares (Kruskal-Wallis + Dunn)
# ============================================================
kruskal.test(ABETA_bl_to_use ~ LDL_group, data = bl_data)
kruskal.test(PTAU_bl_to_use ~ LDL_group, data = bl_data)
kruskal.test(mPACCtrailsB_bl ~ LDL_group, data = bl_data)

# Post-hoc Dunn test para comparacoes pareadas
if (!require(dunn.test)) install.packages("dunn.test")
library(dunn.test)

dunn.test(bl_data$ABETA_bl_to_use, bl_data$LDL_group, method = "bonferroni")
dunn.test(bl_data$PTAU_bl_to_use, bl_data$LDL_group, method = "bonferroni")
dunn.test(bl_data$mPACCtrailsB_bl, bl_data$LDL_group, method = "bonferroni")


### BOXPLOTS LDL (cut-offs clinicos) ###

# Definir comparacoes para ggsignif (apenas grupos adjacentes para clareza)
comparisons_adjacent <- list(
  c("Optimal\n(<2.6)", "Near optimal\n(2.6-3.3)"),
  c("Near optimal\n(2.6-3.3)", "Borderline high\n(3.3-4.1)"),
  c("Borderline high\n(3.3-4.1)", "High\n(4.1-4.9)"),
  c("High\n(4.1-4.9)", "Very high\n(\u22654.9)")
)

# Figure 1d - CSF ABETA 42 por LDL group (cut-offs clinicos)
ggplot(data = bl_data, aes(y = ABETA_bl_to_use, x = LDL_group, group = LDL_group,
                           color = LDL_group, fill = LDL_group)) +
  geom_boxplot(alpha = 0.2, outlier.shape = NA) +
  labs(title = "Figure 1d", x = "", y = "CSF ABETA 42") +
  scale_y_continuous(limits = c(0, 2300), expand = c(0, 0)) +
  scale_color_manual(values = ldl_colors) +
  scale_fill_manual(values = ldl_colors) +
  theme_light() +
  theme(panel.grid.major = element_blank(),
        axis.text.x = element_text(size = 12, family = "Helvetica", colour = "black"),
        axis.title.y = element_text(size = 20, family = "Helvetica", colour = "black"),
        axis.text.y = element_text(size = 17, family = "Helvetica", colour = "black"),
        legend.text = element_text(size = 12, family = "Helvetica", colour = "black"),
        legend.title = element_blank(),
        legend.position = "right",
        legend.background = element_rect(fill = "white", linetype = "solid", linewidth = 0.5, color = "grey")) +
  geom_signif(comparisons = comparisons_adjacent,
              test = "wilcox.test",
              map_signif_level = TRUE, step_increase = 0.08, size = 0.5, color = "black",
              family = "Helvetica", textsize = 3.5)

# Figure 1e - CSF PTAU por LDL group (cut-offs clinicos)
ggplot(data = bl_data, aes(y = PTAU_bl_to_use, x = LDL_group, group = LDL_group,
                           color = LDL_group, fill = LDL_group)) +
  geom_boxplot(alpha = 0.2, outlier.shape = NA) +
  labs(title = "Figure 1e", x = "", y = "CSF PTAU") +
  coord_cartesian(ylim = c(0, 60)) +
  scale_color_manual(values = ldl_colors) +
  scale_fill_manual(values = ldl_colors) +
  theme_light() +
  theme(panel.grid.major = element_blank(),
        axis.text.x = element_text(size = 12, family = "Helvetica", colour = "black"),
        axis.title.y = element_text(size = 20, family = "Helvetica", colour = "black"),
        axis.text.y = element_text(size = 17, family = "Helvetica", colour = "black"),
        legend.text = element_text(size = 12, family = "Helvetica", colour = "black"),
        legend.title = element_blank(),
        legend.position = "right",
        legend.background = element_rect(fill = "white", linetype = "solid", linewidth = 0.5, color = "grey")) +
  geom_signif(comparisons = comparisons_adjacent,
              test = "wilcox.test",
              map_signif_level = TRUE, step_increase = 0.08, size = 0.5, color = "black",
              family = "Helvetica", textsize = 3.5,
              y_position = c(42, 45, 48, 51))

# Figure 1f - mPACCtrailsB por LDL group (cut-offs clinicos)
ggplot(data = bl_data, aes(y = mPACCtrailsB_bl, x = LDL_group, group = LDL_group,
                           color = LDL_group, fill = LDL_group)) +
  geom_boxplot(alpha = 0.2, outlier.shape = NA) +
  labs(title = "Figure 1f", x = "", y = "mPACCtrailsB") +
  scale_y_continuous(limits = c(-8, 8), expand = c(0, 0)) +
  scale_color_manual(values = ldl_colors) +
  scale_fill_manual(values = ldl_colors) +
  theme_light() +
  theme(panel.grid.major = element_blank(),
        axis.text.x = element_text(size = 12, family = "Helvetica", colour = "black"),
        axis.title.y = element_text(size = 20, family = "Helvetica", colour = "black"),
        axis.text.y = element_text(size = 17, family = "Helvetica", colour = "black"),
        legend.text = element_text(size = 12, family = "Helvetica", colour = "black"),
        legend.title = element_blank(),
        legend.position = "right",
        legend.background = element_rect(fill = "white", linetype = "solid", linewidth = 0.5, color = "grey")) +
  geom_signif(comparisons = comparisons_adjacent,
              test = "wilcox.test",
              map_signif_level = TRUE, step_increase = 0.08, size = 0.5, color = "black",
              family = "Helvetica", textsize = 3.5)


### SCATTER PLOTS ###

# Scatter CLINICAL_LDL_C (continuo) vs mPACCtrailsB no baseline, por A+/A-
ggplot(data = bl_data, aes(x = CLINICAL_LDL_C, y = mPACCtrailsB_bl,
                           color = ABETA_positivity_ratio1)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1) +
  labs(title = "LDL-C vs Cognitive Score by Amyloid Status",
       x = "LDL-C (mmol/L)", y = "mPACCtrailsB") +
  geom_vline(xintercept = c(2.6, 3.3, 4.1, 4.9),
             linetype = "dashed", color = "grey50", linewidth = 0.4) +
  annotate("text", x = c(1.3, 2.95, 3.7, 4.5, 5.5), y = Inf,
           label = c("Optimal", "Near\noptimal", "Borderline\nhigh", "High", "Very\nhigh"),
           vjust = 1.5, size = 2.5, family = "Helvetica", color = "grey40") +
  scale_color_manual(values = c("(A)-" = "#2E8B57", "(A)+" = "#B40F20")) +
  theme_light() +
  theme(panel.grid.major = element_blank(),
        axis.text = element_text(size = 14, family = "Helvetica", colour = "black"),
        axis.title = element_text(size = 16, family = "Helvetica", colour = "black"),
        legend.text = element_text(size = 14, family = "Helvetica", colour = "black"),
        legend.title = element_blank(),
        legend.position = "right",
        legend.background = element_rect(fill = "white", linetype = "solid", linewidth = 0.5, color = "grey"))


### ANALISES LONGITUDINAIS ###

# ============================================================
# Modelo com LDL_group categorico (cut-offs clinicos)
# ============================================================

# Usar versao sem quebra de linha para os modelos
cognition_LDL_C$LDL_clinical <- cut(
  cognition_LDL_C$CLINICAL_LDL_C,
  breaks = c(-Inf, 2.6, 3.3, 4.1, 4.9, Inf),
  labels = c("Optimal", "Near optimal", "Borderline high", "High", "Very high"),
  right = FALSE
)
cognition_LDL_C$LDL_clinical <- relevel(cognition_LDL_C$LDL_clinical, ref = "Optimal")

# Modelo LDL categorico x ABETA_positivity x tempo sobre cognicao
modelo_LDL_cat <- lmer(mPACCtrailsB ~ LDL_clinical * ABETA_positivity_ratio * Years_bl_to_use +
                         AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                         APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                         (1 + Years_bl_to_use | RID),
                       REML = TRUE,
                       control = lmerControl(optimizer = "Nelder_Mead"),
                       data = cognition_LDL_C)

summary(modelo_LDL_cat)
anova(modelo_LDL_cat, type = 3)
tab_model(modelo_LDL_cat)

# Modelo CLINICAL_LDL_C (continuo) - mantido para comparacao
modelo_LDL <- lmer(mPACCtrailsB ~ CLINICAL_LDL_C * ABETA_positivity_ratio * Years_bl_to_use +
                     AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                     APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                     (1 + Years_bl_to_use | RID),
                   REML = TRUE,
                   control = lmerControl(optimizer = "Nelder_Mead"),
                   data = cognition_LDL_C)

summary(modelo_LDL)
anova(modelo_LDL, type = 3)
tab_model(modelo_LDL)

# Plot do modelo LDL categorico: preditos por tempo e grupo, facetado por A+/A-
plot_model(modelo_LDL_cat,
           type = "pred",
           terms = c("Years_bl_to_use", "LDL_clinical", "ABETA_positivity_ratio"),
           title = "",
           legend.title = "LDL-C",
           colors = c("#2E8B57", "#F2AD00", "#F98400", "#B40F20", "#7B0051")) +
  labs(x = "Time from baseline (years)", y = "mPACC score") +
  coord_cartesian(xlim = c(0, 6), ylim = c(-6, 2)) +
  scale_y_continuous(breaks = seq(-8, 4, 2), expand = c(0, 0)) +
  scale_x_continuous(breaks = seq(0, 6, 1), expand = c(0, 0)) +
  theme_light() +
  theme(
    text = element_text(size = 11, family = "Helvetica", colour = "black"),
    plot.title = element_text(size = 14, family = "Helvetica"),
    axis.ticks = element_line(colour = "black", linewidth = 0.8),
    axis.text.y = element_text(size = 11, family = "Helvetica", colour = "black"),
    axis.text.x = element_text(size = 11, family = "Helvetica", colour = "black"),
    axis.title.y = element_text(size = 12, family = "Helvetica", colour = "black", margin = margin(t = 0, r = 10, b = 0, l = 0)),
    axis.title.x = element_text(size = 12, family = "Helvetica", colour = "black", margin = margin(t = 10, r = 0, b = 0, l = 0)),
    axis.line = element_line(colour = "black", linewidth = 0.2),
    panel.grid.major.y = element_line(colour = "gray", linewidth = 0.2),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.background = element_rect(linewidth = 0.3, linetype = "solid", colour = "black"),
    strip.background = element_rect(fill = "gray80", colour = "black", linewidth = 0.2),
    strip.text = element_text(size = 12, family = "Helvetica", colour = "black", face = "bold")
  )

# Plot do modelo LDL continuo com linhas verticais nos cut-offs
plot_model(modelo_LDL,
           type = "pred",
           terms = c("Years_bl_to_use", "CLINICAL_LDL_C [meansd]", "ABETA_positivity_ratio"),
           title = "",
           legend.title = "LDL-C",
           colors = c("#2E8B57", "#F2AD00", "#B40F20")) +
  labs(x = "Time from baseline (years)", y = "mPACC score") +
  coord_cartesian(xlim = c(0, 6), ylim = c(-6, 2)) +
  scale_y_continuous(breaks = seq(-8, 4, 2), expand = c(0, 0)) +
  scale_x_continuous(breaks = seq(0, 6, 1), expand = c(0, 0)) +
  theme_light() +
  theme(
    text = element_text(size = 11, family = "Helvetica", colour = "black"),
    plot.title = element_text(size = 14, family = "Helvetica"),
    axis.ticks = element_line(colour = "black", linewidth = 0.8),
    axis.text.y = element_text(size = 11, family = "Helvetica", colour = "black"),
    axis.text.x = element_text(size = 11, family = "Helvetica", colour = "black"),
    axis.title.y = element_text(size = 12, family = "Helvetica", colour = "black", margin = margin(t = 0, r = 10, b = 0, l = 0)),
    axis.title.x = element_text(size = 12, family = "Helvetica", colour = "black", margin = margin(t = 10, r = 0, b = 0, l = 0)),
    axis.line = element_line(colour = "black", linewidth = 0.2),
    panel.grid.major.y = element_line(colour = "gray", linewidth = 0.2),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.background = element_rect(linewidth = 0.3, linetype = "solid", colour = "black"),
    strip.background = element_rect(fill = "gray80", colour = "black", linewidth = 0.2),
    strip.text = element_text(size = 12, family = "Helvetica", colour = "black", face = "bold")
  )


# ============================================================
# Modelo PTAU longitudinal com LDL categorico
# ============================================================
cognition_LDL_C$PTAU <- as.numeric(cognition_LDL_C$PTAU)

modelo_PTAU_LDL_cat <- lmer(PTAU ~ LDL_clinical * ABETA_positivity_ratio * Years_bl_to_use +
                              AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                              APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                              (1 + Years_bl_to_use | RID),
                            REML = TRUE,
                            control = lmerControl(optimizer = "Nelder_Mead"),
                            data = cognition_LDL_C)

summary(modelo_PTAU_LDL_cat)
anova(modelo_PTAU_LDL_cat, type = 3)
tab_model(modelo_PTAU_LDL_cat)

# Modelo PTAU longitudinal com CLINICAL_LDL_C continuo (mantido)
modelo_PTAU_LDL <- lmer(PTAU ~ CLINICAL_LDL_C * ABETA_positivity_ratio * Years_bl_to_use +
                          AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                          APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                          (1 + Years_bl_to_use | RID),
                        REML = TRUE,
                        control = lmerControl(optimizer = "Nelder_Mead"),
                        data = cognition_LDL_C)

summary(modelo_PTAU_LDL)

# ============================================================
# Modelo ABETA longitudinal com LDL categorico
# ============================================================
cognition_LDL_C$ABETA <- as.numeric(cognition_LDL_C$ABETA)

modelo_ABETA_LDL_cat <- lmer(ABETA ~ LDL_clinical * ABETA_positivity_ratio * Years_bl_to_use +
                               AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                               APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                               (1 | RID),
                             REML = TRUE,
                             control = lmerControl(optimizer = "Nelder_Mead"),
                             data = cognition_LDL_C)

summary(modelo_ABETA_LDL_cat)
anova(modelo_ABETA_LDL_cat, type = 3)
tab_model(modelo_ABETA_LDL_cat)

# Modelo ABETA longitudinal com CLINICAL_LDL_C continuo (mantido)
modelo_ABETA_LDL <- lmer(ABETA ~ CLINICAL_LDL_C * ABETA_positivity_ratio * Years_bl_to_use +
                           AGE * Years_bl_to_use + PTGENDER * Years_bl_to_use +
                           APOE4_status * Years_bl_to_use + PTEDUCAT * Years_bl_to_use +
                           (1 | RID),
                         REML = TRUE,
                         control = lmerControl(optimizer = "Nelder_Mead"),
                         data = cognition_LDL_C)

summary(modelo_ABETA_LDL)

