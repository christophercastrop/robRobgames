# 00 — Executive Summary

**Fecha de corte: 2026-09-26.**

## Visión

Una **Roblox Game Factory** no es una máquina de publicar juegos: es un sistema para **probar hipótesis de juego más barato y más rápido que un estudio tradicional,
matar pronto las malas y concentrar recursos en las pocas que retienen jugadores**, acumulando aprendizaje reutilizable (SDK, KB, priors) entre juegos.

## Conclusiones principales

1. **El ciclo técnico ya es automatizable en gran medida con herramientas oficiales** [HECHO VERIFICADO]:
   - Roblox publica un **MCP integrado en Studio** (feb–mar 2026) con edición de scripts, `execute_luau`, control de playtest, **input simulado**, navegación y
     capturas → no hay que construir un MCP de Studio.
   - **Open Cloud** permite publicar places, ejecutar **Luau headless** (tests en CI), gestionar DataStores/MemoryStores, **Configs** (remote config nativo),
     **Experiments** (A/B nativo), **Analytics Query**, **logs de servidores de producción**, passes/dev products, notificaciones, eventos, thumbnails y hasta
     **campañas de ads** (experimental). 189 de 228 operaciones relevantes son BETA/EXPERIMENTAL.
   - Toolchain Git-first maduro: **Rojo 7.7** (jul-2026), Rokit, Wally, StyLua, Selene, luau-lsp, Lune, Jest-Lua.
2. **Lo decisivo sigue siendo humano** [INFERENCIA]: diversión, arte coherente, feel, community management, decisiones de gasto/precio y compliance final.
   El E2E multi-cliente y en dispositivos reales **no es automatizable oficialmente**.
3. **La plataforma cambió las reglas en 2026** [HV]: Premium → **Roblox Plus**; publicación **en 3 niveles** con evaluación para llegar a <16; cuentas **Kids/Select**;
   **age check** para chat; fin de ventas **cross-game**; **Creator Rewards** (5 R$/Active Spender/día si estás entre sus 3 primeros juegos); DevEx $0.0038
   (US 18+: $0.0054); discovery basado en **play-through, bounce <60 s, play days D1/D2–7/D8–28 y playtime**, medido sólo sobre tráfico orgánico de Home, y
   **penalización explícita de juegos no-únicos**. Todo esto **desfavorece la estrategia de clones de volumen** y favorece retención genuina.
4. **Arquitectura recomendada**: monorepo; 6 roles de agente (Market Analyst, Game Designer, Engineer×N, Reviewer independiente, Release Manager, Live Analyst)
   + **orquestador determinista**; 19 skills (de 28 propuestas); **dos planos** (Cloud/Linux y Studio/Win-macOS); **Studio MCP oficial** + **`roblox-cloud-mcp`
   propio y fino** cuyo valor es el **modelo de permisos** (dry-run, aprobación humana ligada a hash, auditoría); SDK compartido (datos, economía, compras,
   policy, configs, analytics, LiveOps, UI).
5. **Trend Intelligence**: CCU/visitas/favoritos/votos/género oficial (`genre_l1/l2`) son accesibles vía endpoints **documentados** en la referencia oficial
   (acceso anónimo); rankings de charts/sorts sólo vía endpoints no documentados ⇒ **⛔ STOP-01** (decisión legal). DAU/retención/ingresos de competidores
   **no son observables**.
6. **Economía de la fábrica** [ESTIMACIÓN]: el creador recibe ≈21% del gasto del jugador tras share (70%) y DevEx; coste marginal de servidores ≈0 (Roblox);
   el coste real es **personas + LiveOps + UA**. Coste LLM por juego hasta decisión de soft launch ≈ $1–2.5k; un juego con CCU medio 1,000 puede generar
   ≈$14k/mes brutos; con CCU 100, ≈$1.4k/mes (no sostiene LiveOps con personal).

## Respuesta a la pregunta económica central (§89)

> ¿Puede construirse hoy una fábrica Roblox significativamente automatizada con mejores probabilidades económicas que desarrollar cada juego artesanalmente?

| Dimensión | Veredicto |
|---|---|
| **Técnicamente posible** | **Sí**, para el ciclo idea→código→tests→staging→publicación→analytics→experimentos→LiveOps paramétrico. Autonomía segura: A3 en ingeniería/tests/staging/analytics; A2 en producción, economía y gasto; A0–A1 en diversión, arte clave y comunidad. |
| **Económicamente razonable** | **Probablemente sí, bajo condiciones**: (a) se usa para **reducir el coste por hipótesis** (greybox en días, MVP en semanas) y **matar pronto**; (b) se reutiliza SDK/arte/KB; (c) pocos juegos LIVE con LiveOps real. Frente a un equipo artesanal equivalente, la ventaja esperada es **2–4× más intentos por euro** [ESTIMACIÓN], no una mayor probabilidad de éxito por intento. |
| **Experimental** | Playtest automatizado en Studio, predicción de oportunidades con datos públicos, generación 3D/animación, creative variants automáticos, ads automatizados. |
| **Todavía no viable** | Juzgar diversión/retención sin jugadores reales; E2E multi-cliente automatizado; arte y personajes coherentes sin humanos; community management autónomo; conocer métricas de competidores. |

**No se promete rentabilidad.** La primera fase (90 días) debe tratarse como **validación del proceso** con presupuesto acotado (LEAN: ≈$0.3–0.6k/mes + ≈$1.5–5k por juego
+ tiempo del operador).

## Qué hacer primero

Ver `RECOMMENDED-ARCHITECTURE.md` → **TOP 20 NEXT ACTIONS**. En síntesis: montar el monorepo y CI, conectar el MCP oficial de Studio, crear universes CI/staging,
arrancar el recolector de tendencias (necesita histórico), construir el SDK núcleo con tests de engine vía Luau Execution, y llevar un juego "hello-factory" por todo
el pipeline antes de elegir el piloto (Incremental Simulator cooperativo, tema decidido con datos).
