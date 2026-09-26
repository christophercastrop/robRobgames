# 20 — Cost Model, Presupuestos y Unit Economics

> Moneda: **USD** (DevEx, APIs y la mayoría de proveedores facturan en USD). Convertir a EUR con el tipo del día de decisión.
> Todos los importes son **[ESTIMACIÓN]** salvo precios de catálogo marcados HV. Salarios varían enormemente por país: se dan rangos.

## 1. Precios base verificados

| Concepto | Precio | Fuente |
|---|---|---|
| Claude Opus 5.5 | $4 / $20 por M tokens in/out; cache read $0.20/M | HV (catálogo de modelos del SDK de Anthropic, caché 2026-06-24) |
| Claude Sonnet 5 | $2 / $10 | HV (idem) |
| Claude Haiku 4.5 | $1 / $5 | HV (idem) |
| Claude Fable 5.1 | $10 / $50 | HV (idem) |
| Batch API | −50% | HV (idem) |
| Planes de suscripción Claude (Pro/Max) | Pro ~$20/mes; Max ~$100–200/mes | HT (precios públicos históricos; verificar) |
| Roblox Plus | $4.99/mes | HV/HT (roblox-plus.md, prensa) |
| Fee de publicación all-ages sin Plus | 1,000 Robux/juego, reembolsable a 90 días | HV DevForum |
| DevEx | $0.0038/R$ estándar; $0.0054/R$ US 18+ elegible | HV |
| Extended Services | DataStore storage $0.12/GB-mes sobre el incluido; requests $0.08–$0.80/M según tipo; Memory Store $0.10/GB-hora; compute $0.001/hora de juego sobre 100k h/mes (opcional) | HV `extended-services.md` |
| Servidores de juego / ancho de banda | **Incluidos** (los paga Roblox) | HV/INF |
| Luau Execution, Configs, Experiments, Analytics Query | Sin coste declarado | HV (no aparece precio) |
| Audio uploads | Gratis hasta 2,000/30 días (ID-verified) | HV |
| Ads | Subasta (segundo precio); sin precio fijo publicado | HV (mecánica) / CPC-CPI **desconocido** ⇒ medir |

## 2. Coste de LLM por actividad [ESTIMACIÓN]

Supuestos: sesiones agénticas de código consumen ~10–30 M tokens de input/día-agente con ~85–90% de cache hits y 0.3–0.6 M de output.

| Actividad | Modelo | Coste unitario |
|---|---|---|
| Día-agente de ingeniería (Opus 5.5) | 20 M in (90% caché) + 0.5 M out | ≈ 2M×$4 + 18M×$0.20 + 0.5M×$20 ≈ **$22/día** (rango $10–40) |
| Día-agente de ingeniería (Sonnet 5) | idem | ≈ **$11/día** |
| Clasificación de 5,000 juegos (Haiku 4.5, batch) | 10 M tokens | ≈ **$5–10/pasada** |
| Concepto + GDD (Opus) | 2–5 M tokens | ≈ $15–40 |
| Revisión de seguridad/PR (Opus, fork) | 1–3 M | ≈ $5–15 por PR grande |
| Live Analyst diario por juego (Sonnet) | 1–2 M | ≈ $3–6/día |

Coste LLM por etapa de un juego:

| Etapa | Días-agente | LLM [EST] |
|---|---|---|
| Concept (×3–5) | 2–3 | $50–120 |
| Greybox prototype | 4–8 | $100–300 |
| MVP | 25–50 | $500–1,500 |
| Soft launch + 4 semanas LiveOps | 15–30 | $200–600 |
| **Total hasta decisión G4/G5** | | **≈ $1–2.5k** |

Con plan **Claude Max** (tarifa plana) parte de este coste queda absorbido en LEAN mientras no se superen los límites de uso [HT].

## 3. Infraestructura mensual [ESTIMACIÓN]

| Pieza | LEAN | PROFESSIONAL | SCALE |
|---|---|---|---|
| GitHub (plan + Actions) | $0–20 | $50–150 | $200–500 |
| Postgres gestionado | $0–25 | $50–150 | $300–800 |
| VPS/jobs | $10–20 | $40–100 | $200–500 |
| Metabase/Grafana | $0 (OSS) | $0–100 | $100–500 |
| LLM (API + planes) | $200–500 | $1.5–4k | $5–15k |
| Image/3D gen (licencia comercial) | $0–30 | $50–200 | $200–1k |
| Roblox Plus (cuentas publicadoras) | $5 | $10–20 | $20–50 |
| Extended Services | $0 | $0–50 | según juegos grandes |
| **Total infra+LLM** | **≈ $250–600** | **≈ $2–5k** | **≈ $6–20k** |

## 4. Producción (humana) y costes Roblox

| Rol | LEAN | PROFESSIONAL | SCALE |
|---|---|---|---|
| Operador/PM/diseño (founder) | 1 (coste de oportunidad) | 1 | 1–2 |
| Arte 3D/2D | Kits comprados/licenciados + freelance puntual ($1–3k/juego) | 1 artista (FTE o freelance) | 2–3 |
| QA/playtesters | Amigos/comunidad (incentivos) | 0.5 FTE + testers pagados | 1–2 FTE + device lab |
| Community/soporte | Founder | 0.5 FTE | 2–3 |
| Ingeniería humana (review, arquitectura) | Founder | 1 senior Roblox | 2 |
| Música/SFX | Biblioteca | Freelance | Freelance/licencias |
| **Coste mensual personas** | $0–3k | **$12–35k** | **$50–130k** |

Costes Roblox por juego: fee/Plus (≈$5), compras de prueba (reales, pequeñas: ~$10–30), assets de marketplace (opcional), **publicidad**.

## 5. Publicidad (tests de retención y escalado)

CPC/CPI de Roblox Ads **no es público** ⇒ ⛔ dato no observable antes de gastar. Plan: campaña de calibración de **$300–500** en el primer soft launch para medir
coste por visita y por nuevo usuario; después presupuestar:

- Test de retención G4: n ≈ 3,000–5,000 nuevos usuarios (ver potencia estadística en `08_OPPORTUNITY_ENGINE.md` §5) × CPI medido.
- Escalado G6: sólo con `LTV₁₈₀/CAC ≥ 1.5`, tope diario y revisión semanal (SPEND_AD_BUDGET humano).

## 6. Presupuestos (§93)

| | LEAN | PROFESSIONAL | SCALE |
|---|---|---|---|
| **Inicial** | $1.5–4k (PC/Mac con GPU si no existe, 2 móviles de prueba gama baja/iOS, kits de arte) | $10–25k (workstations, device lab básico, kit de arte por 2–3 géneros, setup legal) | $40–100k |
| **Mensual fijo** | $0.3–0.6k (+ tiempo del founder) | $15–40k | $60–150k |
| **Por juego hasta G4/G5** | $1.5–5k (LLM $1–2.5k + arte $0.5–2k + ads test $0.3–2.5k) | $8–20k | $15–40k |
| **Variable** | LLM por día-agente; ads | idem | idem + LiveOps de contenido |
| **Publicitario** | Sólo calibración/tests | Tests + escalado de 1 juego con ROAS | Escalado de portfolio con ROAS caps |

## 7. Ingresos: de Robux a beneficio (§56) — ejemplo numérico [ESTIMACIÓN]

Supuestos de un juego "medio-bueno" en LIVE: CCU medio 1,000; playtime medio por DAU 25 min ⇒ **DAU ≈ 1,000 × 1,440 / 25 ≈ 57,600**.

| Línea | Supuesto [HIPÓTESIS] | Robux/día | USD/mes (×30, DevEx $0.0038) |
|---|---|---|---|
| Compras in-game (share 70–88%) | 1.5 Robux ganados por DAU/día | 86,400 | $9,850 |
| Creator Rewards (Daily Engagement) | 8% de DAU son Active Spenders con el juego entre sus 3 primeros ≥10 min → 5 R$ | 23,040 | $2,630 |
| Rewarded video / immersive ads | 0.2 R$/DAU/día | 11,520 | $1,310 |
| **Total earned** | | **≈121k R$/día** | **≈ $13.8k/mes** |
| Porción US 18+ (si elegible, p. ej. 15% de compras a $0.0054) | | | +≈ $620 |
| − Impuestos (ej. 25% efectivo) | | | −≈ $3.6k |
| − LiveOps (0.5 FTE + contenido) | | | −≈ $4–8k |
| − Infra/LLM asignados | | | −≈ $0.3–1k |
| − Ads (si se escala) | | | −variable |
| **Beneficio operativo** | | | **≈ $2–6.5k/mes** antes de ads (muy sensible a supuestos) |

Un juego con CCU medio 100 (DAU ≈ 5,800) generaría ≈ $1.4k/mes brutos ⇒ **no cubre LiveOps con personal** ⇒ MAINTENANCE automatizado o KILL.
[INFERENCIA] La economía de la fábrica depende de una **cola larga muy asimétrica**: pocos juegos con CCU ≥ 1k pagan todo; el resto debe costar poco y morir pronto.

## 8. Unit economics del portfolio (§85)

```
EV_portfolio/€ = Σ_juegos [P(llegar a LIVE rentable) × NPV_12m(ingresos netos)] / Σ costes (LLM + infra + personas + ads)
```

Sensibilidades principales: (1) tasa de juegos que superan G4 (hipótesis 10–20% de MVPs); (2) coste por MVP; (3) ARPDAU real; (4) coste de LiveOps por juego LIVE.
El modelo vive en `factory/finance/model.py` (+ hoja de cálculo exportable) y se actualiza con datos reales tras cada gate.
