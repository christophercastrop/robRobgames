# 14 — Economía, Monetización, Simulador y Unit Economics

## 1. Economía de juegos Roblox (§23): patrones (no números)

| Elemento | Patrón observado en géneros exitosos [INFERENCIA de análisis de géneros + doc oficial "Balance virtual economies"] | Riesgo |
|---|---|---|
| Soft currency | Una moneda principal ganada por el core loop; a veces una secundaria por modo/evento | Inflación si sources crecen exponencialmente sin sinks equivalentes |
| Hard currency (gems) | Útil para empaquetar compras y ofertas; **aumenta obligaciones de compliance** (compras indirectas de random items requieren odds [HV]) | Opacidad percibida; si se usa para random → odds + PolicyService |
| Sources | Core action, quests, daily, eventos, idle/offline, rewarded ads | Farm/bots |
| Sinks | Upgrades con coste creciente, consumibles, cosméticos, rebirth/prestige (reset), crafting, fees de trading | Sinks insuficientes → inflación; excesivos → frustración |
| Curvas | Coste exponencial suave (`c·g^n`, g≈1.10–1.25) vs producción lineal/escalonada; prestige multiplicador para reiniciar la curva | Paredes de progresión (churn) |
| Prestige / rebirth | Reset a cambio de multiplicador permanente; extiende la vida del contenido | Ciclo demasiado corto = grind vacío |
| Collections | Sets completables (pets, cartas), rareza visible | Si la adquisición es pagada y aleatoria → paid random items |
| Crafting / merge | Sink de duplicados | Complejidad de UI |
| Random rewards | Gratis: sin obligación de odds; **pagados (directa o indirectamente)**: odds exactas que suman 100%, actualización dinámica, alternativa de compra directa para usuarios restringidos por `PolicyService.ArePaidRandomItemsRestricted` [HV `paid-random-items.md`] | Regulatorio + reputacional |
| Trading | Aumenta socialización y valor de coleccionables; requiere `IsPaidItemTradingAllowed` para ítems pagados y control de arbitraje regional (`GetUsersPriceLevelsAsync`) [HV] | Duplicación, estafas, arbitraje |
| Cosméticos | Monetización sin pay-to-win; buena para co-play/expresión | Coste de contenido |
| Convenience | Auto-collect, slots extra, teleports | Pay-to-skip excesivo daña retención de no pagadores |
| Boosters | x2 temporal (dev product) o permanente (pass) | Canibalización pass vs product |

**Regla de la fábrica** [DEC-020]: el núcleo del loop **no** depende de paid random items (simplifica compliance y acceso a Kids/Select); se permiten como
capa opcional con el componente `OddsTable` y `Policy` del SDK.

## 2. Mecanismos oficiales de monetización (§24) — vigentes a 2026-09-26

| Mecanismo | Disponibilidad | Elegibilidad | Experiencia de jugador | Modelo de ingreso | Fee/share | Restricciones | Mejor uso | Riesgos |
|---|---|---|---|---|---|---|---|---|
| **Passes** | GA | Juego publicado | Compra única, permanente | Robux | Creador **70%** del precio (base) [HV tabla Plus]; con suscriptores Plus el share efectivo sube a 78%/88% (descuento subvencionado) [HV] | 1–1,000,000,000 Robux; cross-game sales deshabilitadas desde 2026-05-30 [HV] | VIP, x2 permanente, slots | Pay-to-win |
| **Developer Products** | GA | Idem | Compra repetible | Robux | 70% base (idem) | `ProcessReceipt` obligatorio; venta externa (Shop/Store tab) requiere thumbnail y test mode previo [HV] | Monedas, boosts, revives | Duplicación si el handler no es idempotente |
| **Subscriptions** (in-game) | GA | Cuenta verificada (ID o teléfono) para Robux | Mensual auto-renovable | Robux (≥49) o local ($2.99/4.99/7.99/9.99/14.99) | Robux: **70%**; local: **70% el 1er mes, 100% los siguientes** (pagado en Robux) [HV] | Cambio de precio (Robux) 1 vez/60 días con 30 días de aviso; precio local inmutable; borrar = reembolsos; regional pricing forzado en Robux [HV] | Battle pass, VIP mensual | Churn; compromiso de valor continuo |
| **Private servers** | GA | Juego público | Servidor propio mensual | Robux | (HT: 70%) | Incompatible con paid access [HV] | Juegos sociales/roleplay | — |
| **Paid access (Robux)** | GA | — | Pago único de entrada | 25–1000 Robux | Escrow ≤7 días [HV] | Sin reembolsos; reduce alcance | Betas cerradas, premium | Mata discovery |
| **Paid access (moneda local)** | GA | Tipalti, país soportado | Pago único (desktop/web) | USD | 50%/60%/70% para $9.99/$29.99/$49.99 [HV] | Revisión de moderación; escrow ≥60 días; "demo mode" [HV] | Juegos premium de nicho adulto | Alcance mínimo |
| **Immersive ads** (image/video/portal) | GA | Juego público, 13+, ID-verified + 2FA, questionnaire aprobado, **≥2,000 visitantes únicos/mes** [HV] | Anuncios en el mundo 3D | CPM/impresiones, teleports | Pago el 25 del mes siguiente [HV] | Fraude → deducciones [HV] | Hubs sociales con tráfico | Estética |
| **Rewarded video ads** | GA (abierto feb-2026 [HT]) | Mismos requisitos (13+, ID, juego público ≥2k únicos/mes) [HV] | Opt-in: ver vídeo → recompensa | eCPM | — | Recompensa = **Developer Product** del universe, **no aleatoria, no Robux**; no dañar al personaje durante el anuncio; sugerido valor 3–10 Robux [HV] | Monetizar no pagadores | Canibalización de compras |
| **Creator Rewards** | GA (desde 2025-07) | Automático | — | **5 Robux/día** por Active Spender que juega ≥10 min si el juego está entre sus 3 primeros del día; **35%** de las primeras $100 de compras de usuarios nuevos/reactivados traídos por share link (juego con ≥100 DAU medio 60 días) [HV `creator-rewards.md`] | — | Definiciones y discreción de Roblox | Juegos de hábito diario | No controlable |
| **Roblox Plus** (sustituto de Premium) | GA (2026-04-30) | — | — | Descuentos subvencionados (share 78–88%); **250 Robux/mes × 3** por alta de Plus vía `PromptRobloxSubscriptionPurchase`; hasta **100 Robux/suscriptor** por ≥60 min/30 días en tu private server de pago; 10% de Robux transfers in-game [HV `roblox-plus.md`] | — | — | Prompts contextuales de Plus | — |
| **Robux transfers** | GA | — | Envío de Robux entre usuarios dentro del juego | 10% (Plus) | [HV] | Restricciones de edad/consentimiento | Sustituto de cross-game sales | — |
| **Commerce products** (Shopify) | GA limitado | Elegibilidad de creador; **sólo usuarios de EE. UU.** (13+, 18+ en Texas); máx. 500 productos/juego; bundling digital sólo con ≥1M Robux/mes medios o compromiso de $50k en ads [HV] | Merch físico | USD | — | — | Marcas establecidas | No para pilotos |
| **Catalog items / UGC** | GA | Requisitos de Marketplace | Avatar items | Robux | Comisión; el juego recibe comisión si se compra desde avatar inspect/editor in-game [HV] | Tasas de subida | Juegos de moda/avatar | — |
| **Price optimization / Managed pricing / Regional pricing** | GA | Precios **no hard-coded** (usar `GetProductInfo`) [HV] | Precios distintos por región (30–100% del base) y tests de precio (~3–4 semanas, 2% holdout) [HV] | — | — | No aplica a suscripciones (optimización) | Siempre activar tras tener volumen | Arbitraje → `GetUsersPriceLevelsAsync` |
| **Creator Store** (plugins/modelos) | GA | — | — | USD (≥$4.99 plugins, ≥$2.99 modelos) | Escrow 30 días [HV] | — | Vender tooling de la fábrica (opcional) | Distrae del core |
| **Engagement-Based Payouts (Premium)** | **DEPRECADO 2025-07-24** | — | — | — | — | — | — | No modelar |
| **Cross-game passes/products** | **DESHABILITADO 2026-05-30** | — | — | — | — | — | — | No modelar |

Tipo de cambio DevEx: estándar **$0.0038/Robux**, US 18+ **$0.0054/Robux** (compras elegibles de adultos US verificados en juegos que cumplen requisitos R15),
legacy $0.0035 para saldos anteriores a 2025-09-05; mínimo 30,000 Robux; 13+; cash-out 1 vez/mes [HV `developer-exchange.md`, `18-plus-devex-rate.md`].

## 3. Monetization intelligence (§25) — sin violar políticas

| Dato | Método permitido |
|---|---|
| Precio de acceso, private servers de terceros | `/v1/games` (price), página del juego |
| Passes de terceros y precios | **Revisión humana** de la tienda/página del juego (sin API documentada); registrar en `competitor_offers` |
| Dev products, bundles, starter packs, ofertas limitadas | **Playtest humano** con cuenta de investigación (sin comprar o con presupuesto de investigación aprobado) + plantilla de captura |
| Suscripciones | Página del juego / in-game |
| Patrones (VIP, x2, auto-collect, slots, skips, cosméticos, limited) | Codificación manual en taxonomía `offer_type` → base para priors del Designer |
| Ingresos de terceros | **No observable**; estimaciones de terceros sólo como contexto, nunca como dato |

## 4. Economy Simulator (§26)

`factory/econsim` (Python, numpy) — **[DEC-021]** agent-based + Monte Carlo:

- **Entrada**: `config/economy.yaml` (monedas, sources con tasas por acción/minuto, sinks con curvas, upgrades, prestige, productos y precios, probabilidades de
  compra por arquetipo) + **arquetipos de jugador** (casual, regular, grinder, spender, whale) con distribuciones de sesión (lognormal), días activos
  (curva de retención paramétrica), eficiencia de juego, propensión de compra por nivel de frustración/deseo.
- **Motor**: simula N=10k–100k jugadores × 60–90 días con paso = sesión; cada sesión consume acciones → sources; el agente decide gastos (política codicioso-razonable)
  y compras (modelo logístico de propensión); aplica prestige.
- **Salidas**: balance medio y p90 por día y cohorte (**inflación**), tiempo a cada hito de progresión (**walls**), % de jugadores estancados, uso de sinks,
  ingresos simulados, ARPDAU/ARPPU/conversión **condicionales a los supuestos**, LTV simulado, sensibilidad (tornado) a ±20% en parámetros clave.
- **Detección de economías rotas** (reglas automáticas): balance mediano creciendo > X%/día sin sinks relevantes; hito clave inalcanzable para casual en
  horizonte de diseño; un producto con ROI infinito (compra que elimina toda necesidad futura); exploit de arbitraje entre sources; paid random items sin
  alternativa determinista para restringidos.
- **Paridad con el juego**: las fórmulas se generan de `economy.yaml` tanto para Python como para Luau (`shared/EconomyFormulas.luau`) + test de paridad en CI.
- **Calibración**: tras soft launch, se ajustan arquetipos con datos reales (economy events) → el simulador se vuelve predictivo para *cambios* (A/B offline antes de A/B real).

## 5. Unit economics (§55) y Robux ≠ beneficio (§56)

```text
Gasto del jugador (USD en compra de Robux)
  → Robux gastados en tu juego (R_spent)
  → Robux ganados por el creador = R_spent × share (0.70 base; 0.78–0.88 con Plus subsidiado)
     + Creator Rewards + ads (Robux) + Plus signups/private-server time
  → Earned Robux elegibles para DevEx (excluye Robux recibidos por transfers, etc.)
  → USD = Earned Robux × tasa DevEx (0.0038 estándar; 0.0054 porción US 18+ elegible)
  → − impuestos (según jurisdicción; DevEx requiere W-9/W-8)
  → − infraestructura (LLM, cloud, tools)
  → − publicidad (Ads Manager)
  → − mano de obra (humanos)
  → − assets/licencias
  = beneficio operativo
```

Ejemplo [ESTIMACIÓN]: un jugador compra 400 Robux por ~$4.99 (≈$0.0125/Robux, varía por paquete/plataforma [HT]) y los gasta en tu juego:
creador recibe 280 Robux → DevEx estándar 280 × 0.0038 = **$1.06** (≈21% del gasto del jugador) antes de impuestos y costes. Con la tasa US 18+: $1.51 (≈30%).

Fórmulas:

| Métrica | Definición |
|---|---|
| CAC | gasto de ads (USD) / nuevos usuarios atribuidos (Ads reporting) |
| payer conversion | pagadores únicos / usuarios activos (periodo) |
| ARPDAU | ingresos netos al creador (Robux→USD) / DAU |
| ARPPU | ingresos / pagadores |
| LTV_h | ver `13_ANALYTICS.md` §5, en USD post-DevEx |
| ROAS_h | LTV_h × nuevos usuarios de la campaña / gasto |
| Contribution margin | LTV_h − CAC − coste variable por usuario (≈0 en Roblox: servidores los paga Roblox; salvo Extended Services) |

Nota importante: en Roblox **el coste de servidores y ancho de banda lo asume la plataforma** (salvo Extended Services opcionales) [HV extended-services.md]
⇒ el coste marginal por jugador es casi cero; los costes reales son **producción, LiveOps y adquisición**.
