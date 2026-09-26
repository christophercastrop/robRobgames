# 18 — Compliance, Factory Policy Engine y controles anti-clon

> Ninguna checklist garantiza la aprobación de Roblox. El Policy Engine reduce riesgo; **no certifica**. Revisar políticas cada 60 días.
> Documentos de referencia: Terms of Use, Community Standards (incluye sección *Roblox economy – paid random items*), Advertising Standards,
> Experience Guidelines/Maturity questionnaire, Restricted Content Policy, DMCA guidelines. Nota: `en.help.roblox.com` devolvió 403 a la herramienta de
> verificación; las reglas citadas abajo proceden de las páginas del Creator Hub que las resumen/enlazan [HV cuando se indica fichero].

## 1. Políticas vigentes relevantes (§52)

| Área | Regla verificada | Fuente |
|---|---|---|
| Maturity & compliance | Cuestionario obligatorio; etiquetas Minimal/Mild/Moderate/Restricted; responder según el contenido **más extremo** accesible; sin guías ⇒ tratado como 13+ y sin contenido 17+; desajuste declarado vs real ⇒ retirada de etiqueta/discovery y moderación de cuenta | HV `content-maturity.md`, `experience-guidelines.md` |
| Acceso por edad | Kids (5–8): Minimal/Mild; Select (9–15): hasta Moderate; excluye social hangouts y dibujo libre por defecto; Restricted = 18+ verificado | HV newsroom 2026-04, `content-maturity.md` |
| Publicación | 3 niveles (personal, 16+, todas las edades con ID+2FA+Plus o fee 1,000 R$ + evaluación) | HV DevForum 2026-05 |
| Monetización honesta | Descuentos genuinos y no de ultra-corta duración; sin falsa escasez; sin countdowns falsos o que se reinician; no presionar/confundir | HV `monetization/index.md` |
| Paid random items | Odds numéricas de todos los resultados (suman 100%), actualización dinámica, explicar efectos de ítems que alteran odds; aplica a compras indirectas (monedas compradas con Robux); `PolicyService.ArePaidRandomItemsRestricted` ⇒ bloquear y ofrecer alternativa (p. ej. compra directa) | HV `paid-random-items.md` |
| Trading | `IsPaidItemTradingAllowed` para ítems pagados/resultados de random pagados; control de arbitraje regional | HV |
| Suscripciones | No condicionar beneficios pagados a tareas extra (p. ej. postear en redes) | HV `subscriptions.md` |
| Rewarded ads | Divulgar que es un anuncio, qué se debe hacer y qué se recibe; recompensa no aleatoria, developer product, no Robux; no perjudicar al personaje | HV `rewarded-video-ads.md` |
| Publicidad | Advertising Standards: contenido, divulgación, privacidad, seguridad, integridad del sistema de ads; fraude de impresiones ⇒ deducciones | HV `comply-with-advertising-standards.md`, `immersive-ads.md` |
| Enlaces externos / redes | Social links sólo visibles a usuarios age-verified ≥16; creador debe tener ≥16 verificado | HV `social-media-links.md` |
| Chat | Chat condicionado a age check; en <9 desactivado por defecto salvo consentimiento parental | HV Roblox IR 2026 |
| Texto de usuario | Filtrado obligatorio (TextService) | HT (política conocida; SDK lo impone) |
| Datos personales | RTBF automatizado con plantillas; no recolectar PII | HV `right-to-be-forgotten.md`, `RTBF-and-creators.md` |
| UGC en juego | Declarar en cuestionario; free-form drawing/creation restringe a 16+ | HV `content-maturity.md` |
| Copyright/IP | DMCA; audio sólo con permiso; detección automática de audio | HV `dmca-guidelines.md`, `audio/assets.md` |
| Metadata | No keywords irrelevantes, no giveaways como gancho, no engaño, originalidad | HV `discovery.md` |
| Regional | Roblox puede restringir contenido/juegos por país | HV `regional-content-availability.md` |
| 18+ DevEx | Requisitos R15-only para la tasa US 18+ | HV `18-plus-devex-rate.md` |
| **Safety guide (2026-09-26)** | Filtrar **todo** texto de usuario visible a otros con `TextService:FilterStringAsync()` — si Roblox detecta que no se filtra, **puede retirar el juego** hasta corregirlo | HV `safety.md` |
| Espacios privados | En juegos accesibles a <18, evitar entornos que transcurren principalmente en espacios privados (dormitorios, baños, armarios); limitar con *bounding boxes* assets que invitan a mal uso (camas, superficies para dormir) | HV `safety.md` + [DevForum "Strengthening our safety policies and tools"](https://devforum.roblox.com/t/strengthening-our-safety-policies-and-tools/3882864) |
| Entornos adultos | Juegos que transcurren principalmente en discotecas/bares deben restringirse a mayores de 18 | HV `safety.md` |
| UGC en juego | Pre-moderación, contenido efímero, privilegios de UGC sólo a usuarios de confianza o sólo opciones predefinidas | HV `safety.md` (recomendación) |
| Editores de avatar in-game | Monitorizar y restringir si aumentan los abusos | HV `safety.md` (recomendación) |
| Moderación de jugadores | `Players:BanAsync()` (razón pública/privada, duración, detección de alts), `Player:Kick()`, gating con `Player:IsVerified()` para ranking/trading | HV `safety.md`, `production/bans.md` |
| Anuncios in-game | `PolicyService` también gobierna la elegibilidad de anuncios (`AreAdsAllowed`), branded content y enlaces sociales | HV `safety.md` |
| Safety dashboard | Creator Dashboard → Safety → Overview: *abuse report submitters per 1,000 playtime hours* (visible con ≥1,000 h/día de juego la semana anterior), reports por categoría, filtro por canal (Avatar, Chat, Voice, Experience, Audio), insight automático si se supera el percentil 90 | HV `safety.md` |

## 2. Factory Policy Engine (§53)

```text
Game (repo + build .rbxl + metadata + assets LEDGER + economy.yaml + configs)
  ↓
Policy Scan (reglas deterministas + clasificadores LLM/visión)
  ↓
Risk Findings (id, regla, severidad, evidencia, fichero/asset, sugerencia)
  ↓
BLOCK / WARN / PASS   (+ borrador de respuestas del Maturity & Compliance Questionnaire para el humano)
```

`factory policy scan games/<slug>` — reglas iniciales:

| ID | Regla | Tipo | Severidad |
|---|---|---|---|
| POL-001 | Producto/UI con resultado aleatorio pagado (directo o vía moneda comprable) sin `OddsTable` y sin gate `Policy.paidRandom` | estático (economy.yaml + código) | BLOCK |
| POL-002 | Odds declaradas no suman 100% (tolerancia de redondeo documentada) | estático | BLOCK |
| POL-003 | Trading de ítems pagados sin `IsPaidItemTradingAllowed` | estático | BLOCK |
| POL-004 | Precios hard-coded en UI (impide price optimization y puede mostrar precio incorrecto) | estático | WARN |
| POL-005 | Countdown/oferta "limitada" sin ventana real en config | estático + config | BLOCK |
| POL-006 | Recompensa de rewarded ad aleatoria / no developer product | estático | BLOCK |
| POL-007 | Texto de usuario mostrado sin filtrado | estático | BLOCK |
| POL-008 | Enlaces externos/URLs en UI o metadata | estático | WARN (revisión) |
| POL-009 | Asset sin entrada en LEDGER (origen/licencia) | estático | BLOCK |
| POL-010 | Audio sin licencia registrada | estático | BLOCK |
| POL-011 | Similitud visual alta (embedding) de icono/thumbnail/asset con corpus de competidores o marcas | visión | WARN ≥ umbral 1 / BLOCK ≥ umbral 2 |
| POL-012 | Nombre/descripción con marcas registradas, nombres de juegos existentes, keywords irrelevantes, giveaways | LLM + listas | BLOCK/WARN |
| POL-013 | Contenido que eleva la madurez respecto al target (violencia, sangre, miedo, humor crudo, romance, alcohol, gambling) | LLM sobre GDD + assets + strings | WARN → actualizar cuestionario |
| POL-014 | Social hangout / free-form drawing con target <16 | GDD + código | BLOCK para target Kids/Select |
| POL-015 | Recolección de PII o envío de datos a terceros no declarados | estático (HttpService allowlist) | BLOCK |
| POL-016 | Claves de DataStore sin patrón `{UserId}` compatible con RTBF | estático | WARN |
| POL-017 | Beneficios de suscripción condicionados a acciones externas | GDD + código | BLOCK |
| POL-018 | Metadata no coincide con gameplay (thumbnail muestra contenido inexistente) | visión + humano | WARN |
| POL-019 | Juego con target <18 cuyo contenido principal ocurre en espacios privados (dormitorio/baño/armario) o con assets "cama/superficie para dormir" sin bounding box de uso | GDD + tags de assets + LLM | BLOCK |
| POL-020 | Entorno principal "adulto" (discoteca/bar) sin restricción 18+ | GDD + LLM | BLOCK |
| POL-021 | UGC compartido (texto, dibujo, construcciones, outfits) sin al menos una salvaguarda: pre-moderación, efímero, privilegio por confianza o sólo presets | GDD + código | BLOCK |
| POL-022 | Sistema de moderación ausente: sin `BanAsync`/`Kick` accesible a herramientas de moderación del juego ni runbook | código + ops | WARN |
| POL-023 | Anuncios in-game (immersive/rewarded) sin comprobar `PolicyService` (`AreAdsAllowed`) / `AdService` availability | estático | BLOCK |

Salida: `games/<slug>/compliance/policy-report.md` + `questionnaire-draft.md`. **El humano** envía el cuestionario y firma el release.

## 3. NO CLONAR (§18): del análisis competitivo al juego original

```text
competitor analysis (datos públicos + playtest humano)
  → mechanic extraction (verbos, loops, ritmos; SIN nombres, arte, mapas, textos)
  → player need (qué necesidad satisface: colección, maestría, expresión, social…)
  → design abstraction (patrón genérico en la KB: "loop de colección con rareza visible + set bonus")
  → new combination (patrón × tema × meta-loop × social hook distintos)
  → original game (+ originality report)
```

**Controles**:

| Riesgo | Control automático | Control humano |
|---|---|---|
| Copia de mapas | Prohibido importar places/modelos de terceros; scanner de assets externos; layouts generados desde blockouts propios | Revisión visual de layout vs competidor top-3 |
| Personajes | Similitud de embeddings de siluetas/colores vs corpus; lista de personajes con IP (anime, cine, juegos) | Revisión de arte |
| Nombres | Búsqueda de nombre en tracked set + base de marcas (lista curada + búsqueda web); distancia de edición/semántica | — |
| Marcas | Listas de marcas y franquicias; OCR en imágenes | Legal si hay duda |
| Thumbnails | Similitud perceptual (pHash + embedding) vs thumbnails de competidores del cluster; umbral BLOCK | Aprobación de creative |
| UI | El design system propio garantiza identidad; alerta si se replica layout+paleta de un competidor concreto | — |
| Música/audio | Sólo biblioteca con licencia; sin samples de temas conocidos | — |
| Assets | LEDGER obligatorio | — |
| IP protegida (tema basado en franquicia) | Gate duro en Opportunity Engine | Legal |
| Trade dress excesivamente parecido (conjunto de nombre+icono+paleta+loop idéntico) | **Originality score**: nº de ejes diferentes (mecánica, tema, meta-loop, social, estilo visual) vs cada competidor top-3; mínimo 2 ejes principales distintos y 0 coincidencias de nombre/arte | Reviewer (fork) intenta argumentar que es un clon; humano decide |

**⛔ STOP-02**: cualquier concepto que dependa de IP de terceros (licencias, parodias de franquicias, personajes de anime reconocibles) requiere decisión legal humana.

## 3b. Diseño safety-first (checklist obligatoria del GDD)

Derivada de `safety.md` [HV]; la skill S12 la verifica en G1 y G3:

- [ ] Todo texto de usuario visible a otros pasa por `SDK.Moderation.filterForBroadcast` / `filterForUser` (wrappers de `TextService:FilterStringAsync`).
- [ ] Cada feature de UGC declara su salvaguarda (pre-moderación, efímero, trusted-only o presets).
- [ ] Sin entornos principales en espacios privados para audiencias <18; assets tipo cama con bounding box/limitación de interacción.
- [ ] Entornos adultos → 18+ o rediseño.
- [ ] Editor de avatar in-game: plan de monitorización y kill switch (`kill.avatar_editor`).
- [ ] Moderación: comando/panel server-side con `BanAsync` (razón pública y privada, duración, alts) y `Kick`; bans persistentes vía Ban API / User Restrictions API (Open Cloud).
- [ ] Features de ranking/trading de alto valor evaluadas para gating con `IsVerified`.
- [ ] `PolicyService`: anuncios, paid random items, trading, social links, branded content.
- [ ] Cuestionario de madurez actualizado **inmediatamente** si el contenido cambia.
- [ ] Safety dashboard en el panel semanal del Live Analyst (alerta si aparece el insight de p90).

## 4. Gates de compliance en el pipeline

| Momento | Gate |
|---|---|
| G0 Opportunity | Gate duro IP / madurez objetivo |
| G1 Concept | Originality report sin BLOCK |
| Cada PR | Reglas estáticas POL-001…010, 015–017 |
| G3 MVP | Policy scan completo + cuestionario borrador |
| Release | Policy PASS o WARN con justificación firmada por humano |
| Trimestral | Revisión de políticas de Roblox (diff de `Roblox/creator-docs` en `production/monetization`, `promotion`, `publishing`) → actualización de reglas |

La revisión trimestral puede automatizarse (A3): job que hace `git log`/diff del repo oficial `Roblox/creator-docs` sobre esas carpetas y abre un Issue con cambios.
