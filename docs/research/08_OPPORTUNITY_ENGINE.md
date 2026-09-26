# 08 — Opportunity Engine, Portfolio, Stage Gates y Kill System

## 1. Qué factores tienen poder predictivo real (y cuáles no sabemos)

No existe evidencia pública rigurosa que cuantifique qué factores predicen el éxito de un juego Roblox nuevo [INFERENCIA: no se encontró
literatura primaria; los benchmarks públicos (p. ej. GameAnalytics "2026 Roblox Benchmark Report") describen métricas de juegos existentes, no
predicción ex-ante]. Por tanto:

| Factor | Evidencia disponible | Tratamiento |
|---|---|---|
| Retención a 28 días / play days | **Documentada** como señal principal de Home recommendations (Play Days per User D1, D2–7, D8–28; Playtime per User) [HV `discovery.md`] | Peso alto… pero **sólo medible tras lanzar**; ex-ante usar proxys de género |
| Play-through rate y first-play bounce | Documentadas [HV] | Depende de thumbnail/título/onboarding (controlable) → no discrimina oportunidades, sí ejecución |
| Co-play con amigos | Señal "importante" documentada [HV] | Favorecer mecánicas sociales/cooperativas |
| Unicidad (no clones) | Roblox **reduce exposición** a "non-unique games resembling existing titles" y metadata engañosa [HV `discovery.md`] | Penaliza estrategia de clonado: diferenciación es requisito, no bonus |
| Crecimiento del cluster | Observable (Trend Engine) | Peso medio; decae si `clone_wave` |
| Saturación/competencia | Observable (n juegos y concentración de CCU por cluster: HHI) | Peso medio |
| Complejidad técnica / coste | Estimable internamente | Peso alto en coste esperado |
| Content burden / LiveOps burden | Estimable (tipo de mecánica) | Peso alto en coste recurrente |
| Monetización del género | Parcialmente observable (precio de acceso, private servers); ARPDAU de género **no observable** salvo benchmarks de terceros | Prior débil |
| Riesgo IP | Evaluable (texto, visual) | **Gate duro**, no peso |
| Dependencia de moda pasajera | Aproximable: historia de clusters similares (vida media) | Penalización |

⇒ **[DECISIÓN PROPUESTA DEC-015]**: el modelo inicial es **bayesiano y explícito**: priors subjetivos documentados + recalibración con cada
lanzamiento propio. Nada de ML opaco hasta tener ≥15–20 lanzamientos propios.

## 2. Opportunity Score

Para un cluster/tesis `o`:

```
EV(o) = P(éxito | o) × Valor(éxito) − Coste(o)
OpportunityScore(o) = EV(o) / Coste(o)            # valor esperado por € (§85 del brief)
```

- `P(éxito | o)` = probabilidad de superar **G4 (retención)** estimada como:
  `logit(P) = β0 + β1·z(demanda) + β2·z(crecimiento_cluster) − β3·z(saturación) + β4·diferenciación + β5·social_fit − β6·moda`
  con β iniciales [HIPÓTESIS] documentados en `factory/score/priors.yaml` y β0 calibrado para que la tasa base ≈ tasa histórica esperada
  (prior: 10–20% de MVPs superan G4) [HIPÓTESIS].
- `Valor(éxito)` = ingresos netos a 12 meses del escenario "éxito" del género (§4 del cost model) — **[ESTIMACIÓN]** con rango.
- `Coste(o)` = coste de prototipo + MVP + soft launch (horas humanas × tarifa + tokens + assets) del T-shirt de complejidad.

Componentes (todos normalizados a z-scores dentro del tracked set):

| Componente | Cálculo |
|---|---|
| demanda | `ln(Σ CCU del cluster)` + `ln(1+ vistas YouTube 7d del cluster)` |
| crecimiento_cluster | `r7_weighted` y `r28_weighted` del cluster |
| saturación | `HHI` de CCU en el cluster + `n_new_30d` |
| diferenciación | 0–1, juicio del Designer validado por Reviewer: nº de ejes (mecánica/tema/meta-loop/social) en los que el concepto difiere del top-3 |
| social_fit | 0–1: co-play nativo, sesiones con amigos, mecánicas cooperativas |
| moda | vida media histórica de clusters del mismo tipo (p. ej. memes/virales cortos) |
| **Gates duros** | riesgo IP alto, requiere IP de terceros, rating > Moderate (pierde <16), paid random items como núcleo del loop, complejidad XL en fase piloto |

Salida: score, **intervalo** (propagando incertidumbre de priors), y top-3 riesgos. Las decisiones se toman sobre rangos, no puntos.

## 3. Recalibración (aprender de los propios juegos)

Cada juego lanzado aporta `(features ex-ante, resultado G2/G4/G5)`. Tras cada 5 lanzamientos: actualizar β con regresión logística bayesiana
(priors = β actuales) y publicar `priors.yaml` versionado en `DECISIONS.md`. Medir **Brier score** de las predicciones pasadas.

## 4. Portfolio strategy (§20)

Embudo propuesto [HIPÓTESIS sobre ratios; ESTIMACIÓN de coste en `20_COST_MODEL.md`]:

```text
40 oportunidades/mes puntuadas (automático, coste ~0)
  → 8 conceptos (1 día-agente cada uno, revisión humana 1 h)
    → 3 greybox prototypes (3–5 días cada uno)
      → 1–2 MVP (3–5 semanas)
        → 1 soft launch 16+ (4–6 semanas de datos)
          → 0–1 LIVE/SCALE por trimestre
```

Reglas:
- **WIP limits**: máx. 2 MVPs simultáneos en LEAN, 4 en PROFESSIONAL.
- **Asignación de presupuesto por opciones reales**: el coste crece por etapa; cada etapa compra información para decidir la siguiente.
- **Diversificación**: no más de 50% del presupuesto de MVP en un mismo `genre_l1`.
- **Reutilización**: preferir oportunidades que maximicen reuso del SDK (reduce coste y riesgo).
- **Portfolio review semanal (humano, 30–60 min)**: único punto donde se aprueban G0/G1 y se matan proyectos.

## 5. Stage gates (§57) — métricas y umbrales

Principio: **no inventar umbrales absolutos**. Se usan (a) umbrales **relativos** a benchmarks del propio dashboard de Roblox ("similar experiences"
benchmarks existen en Analytics [HV DevForum "Recommendations QPTR and Similar Experiences Benchmarks"]) y (b) umbrales iniciales **[HIPÓTESIS]**
que se recalibran.

| Gate | Pregunta | Métricas | Umbral inicial |
|---|---|---|---|
| **G0 Market Signal** | ¿Existe oportunidad? | OpportunityScore, intervalo, gates duros | Score en top-20% del mes y sin gates duros |
| **G1 Concept** | ¿Existe diferenciación? | Originality report, diferenciación ≥2 ejes, content burden, complejidad ≤ M | Aprobación humana |
| **G2 Prototype** | ¿Es divertido? | Playtest ≥8 personas externas: % que pide seguir jugando, tiempo voluntario de sesión, "¿volverías mañana?" (1–5), claridad del objetivo en <60 s | ≥60% quiere seguir; mediana sesión voluntaria ≥ duración objetivo; claridad ≥4/5 [HIPÓTESIS] |
| **G3 MVP** | ¿Funciona técnicamente? | CI verde, perf gates, crash/error rate en staging, persistencia, 0 críticos de seguridad, policy PASS | Todos los checks (binario) |
| **G4 Soft Launch (retención)** | ¿Hay señales de retención? | D1, D7, play days/usuario D2–7 y D8–28, first-play bounce <60 s, playtime/usuario, **vs benchmark de similares** | D1 y D7 ≥ mediana de "similar experiences" del dashboard **y** bounce ≤ mediana; mínimo n ≥ 2,000 nuevos usuarios [HIPÓTESIS] |
| **G5 Monetization** | ¿Señales económicas? | payer conversion, ARPDAU, ARPPU, % ingresos de ads/Creator Rewards | ARPDAU ≥ mediana de similares; conversion ≥ mediana [HIPÓTESIS] |
| **G6 Scale** | ¿Conviene invertir? | LTV (d30/d60 extrapolado) vs CAC de campañas de prueba; capacidad LiveOps | LTV₁₈₀ ≥ 1.5 × CAC con intervalo inferior > 1 [HIPÓTESIS] |

Tamaños de muestra: para detectar ΔD7 de 2 pp sobre base 8% con α=0.05, potencia 0.8 → ~3,200 usuarios por grupo (8%→10%) [ESTIMACIÓN, fórmula de
dos proporciones]; por eso G4 exige volumen mínimo antes de decidir.

## 6. Kill system (§58)

Decisiones: **CONTINUE · ITERATE · PAUSE · KILL · SCALE**. Se evalúan en cada gate y cada 2 semanas en LIVE.

| Situación | Decisión |
|---|---|
| Métricas ≥ umbral y tendencia estable/creciente | CONTINUE (o SCALE si pasa G6) |
| Métricas por debajo pero con una hipótesis causal concreta y testeable (p. ej. bounce alto por onboarding) y coste de iteración < 25% del coste ya previsto de la etapa | ITERATE (máx. **2 iteraciones por gate**) |
| Dependencia externa (evaluación de Roblox, recurso humano) | PAUSE (con fecha de revisión) |
| 2 iteraciones sin mejora significativa, o métrica núcleo < 50% del benchmark, o riesgo de política/IP, o LTV/CAC < 1 sin palanca | **KILL** |
| LIVE con ingresos netos < coste de LiveOps 2 meses seguidos | MAINTENANCE mínimo o KILL |

**Regla anti coste hundido**: el informe de gate **no** muestra lo gastado hasta ahora; sólo coste futuro y EV futuro. El kill lo propone el
Live Analyst y lo decide un humano en la revisión de portfolio. Cada kill genera postmortem (S17) — un kill barato y bien documentado es un **éxito de la fábrica**.

## 7. Objetivo económico (§85)

Métrica de la fábrica: **EV del portfolio por € y por hora humana**, no nº de juegos. KPI derivado: `kills_before_MVP / total_concepts`
(queremos que sea alto) y `coste_medio_por_juego_que_pasa_G4` (queremos que baje).
