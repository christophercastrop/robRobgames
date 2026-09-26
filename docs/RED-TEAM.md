# RED TEAM — por qué la fábrica podría fracasar (§88)

Sin suavizar. Cada ataque incluye la mejor respuesta disponible y lo que **no** tiene respuesta.

## 1. Rentabilidad
- **Ataque**: la distribución de resultados en Roblox es extremadamente asimétrica; la mayoría de juegos nunca supera decenas de CCU. Con DevEx a $0.0038 y share
  del 70%, el creador recibe ~21% del gasto del jugador [EST]. Un juego con CCU medio 100 genera ≈$1.4k/mes brutos — no paga ni medio salario de LiveOps.
  Un portfolio de juegos mediocres **pierde dinero** con certeza.
- **Respuesta**: la tesis no es "muchos juegos" sino **matar barato y concentrar**. Si el coste por intento hasta G4 es ≤$5k (LEAN) y 1 de cada 10–15 intentos
  llega a CCU ≥1k, la esperanza puede ser positiva — pero esto es **[HIPÓTESIS]** sin evidencia propia todavía.
- **Sin respuesta**: no conocemos la tasa base real de éxito de nuestro proceso hasta haber lanzado ~10 juegos.

## 2. Automatización
- **Ataque**: lo automatizable (código, tests, publicación) no es el cuello de botella del éxito; lo decisivo (diversión, feel, arte coherente, comunidad) es lo
  menos automatizable. Una fábrica puede producir código correcto de juegos aburridos más rápido.
- **Respuesta**: la fábrica reduce el coste de **probar** ideas (greybox en días), lo que aumenta el nº de hipótesis de diversión evaluadas por humanos.
- **Sin respuesta**: la evaluación de "¿es divertido?" sigue siendo humana y lenta (playtests).

## 3. Calidad
- **Ataque**: el código generado por agentes acumula deuda; los juegos Roblox exitosos requieren pulido fino (game feel, animación, VFX, audio) que los LLM no perciben
  (no juegan en tiempo real, sólo ven capturas y logs).
- **Respuesta**: SDK + reviewer + humanos en pulido; el MCP permite capturas y consola pero **no** percibe el feel.
- **Sin respuesta**: [INFERENCIA] Claude no puede evaluar latencia de input, "juiciness" o frustración de forma fiable.

## 4. Escalabilidad
- **Ataque**: cada juego LIVE exige LiveOps semanal, soporte y comunidad; con 10+ juegos el equipo humano se satura.
- **Respuesta**: WIP limits, MAINTENANCE automatizado y kill disciplinado; LiveOps data-driven.
- **Sin respuesta**: community management de calidad no escala con agentes sin riesgo (menores, moderación).

## 5. Mercado
- **Ataque**: Roblox está saturado de juegos; los estudios grandes (con equipos de 20–100 personas y presupuestos de UA) dominan el top; la home premia retención
  a 28 días, que requiere profundidad de contenido.
- **Respuesta**: nichos con diferenciación real, co-play y horizontes de progresión largos; no competir en el top-10.

## 6. Dependencia de Roblox
- **Ataque**: una sola plataforma controla distribución, monetización, políticas y APIs (83% beta/experimental). Cambios como publicación por niveles (2026-05),
  cuentas Kids/Select, retirada de Premium o fin de ventas cross-game pueden romper modelos de un día para otro.
- **Respuesta**: adaptadores, monitorización de cambios, diversificación de géneros/audiencias.
- **Sin respuesta**: riesgo de plataforma inevitable.

## 7. Descubrimiento
- **Ataque**: el ranking de Home sólo usa tráfico orgánico de Recommended for You; sin ese flujo inicial un juego nuevo puede no recibir nunca muestra suficiente.
  La evaluación para all-ages exige engagement genuino de 16+.
- **Respuesta**: soft launch 16+ con calibración pagada para medir; share links/referrals; notificaciones; eventos.
- **Sin respuesta**: el algoritmo es opaco; la volatilidad puede anular buenos juegos.

## 8. Adquisición
- **Ataque**: CPI/CAC de Roblox Ads no es público y el LTV de un juego nuevo es pequeño; UA rentable puede no existir para juegos pequeños.
- **Respuesta**: usar ads como instrumento de **medición**, no de crecimiento, hasta probar LTV>CAC.

## 9. Costes de IA
- **Ataque**: agentes en bucle consumen tokens; un MVP puede costar miles si el agente itera sin rumbo.
- **Respuesta**: presupuestos por work item, cortes a 2×, modelos baratos para bulk; el coste LLM estimado ($1–2.5k/juego hasta G4) es menor que el humano.
- **Riesgo residual**: bajo en términos relativos; el mayor coste son personas.

## 10. Mantenimiento
- **Ataque**: SDK compartido = cambio que rompe N juegos; dependencias OSS con bus factor alto; APIs beta cambiantes.
- **Respuesta**: tests de compatibilidad de todos los juegos activos, vendoring en MAINTENANCE, wrappers.

## 11. Encontrar tendencias antes que otros
- **Ataque**: todos ven los mismos charts; los datos públicos (CCU/visitas) muestran lo que **ya** pasó; estudios con relaciones con creadores de contenido se enteran antes.
  Sin endpoints de sorts (STOP-01) vemos aún menos.
- **Respuesta**: detectar aceleración en clusters jóvenes y necesidades insatisfechas; pero **no** prometemos ventaja informacional — la ventaja buscada es la
  **velocidad de prueba y descarte**, no la predicción.

## 12. Convertir tendencias en retención
- **Ataque**: una tendencia trae clics (PTR), no retención; los juegos trend-chasers suelen tener D7 bajo y el ranking de 28 días los castiga.
- **Respuesta**: G4 basado en D2–7/D8–28 y kill rápido; diseño con horizonte de progresión y co-play.

## 13. Diversión automática
- **Ataque**: no existe evidencia de que un LLM diseñe juegos divertidos de forma consistente. Los conceptos generados tienden a la media (recombinaciones seguras).
- **Respuesta**: el LLM genera **opciones** y artefactos; humanos juzgan y playtesters validan; la KB captura qué funcionó.
- **Sin respuesta**: la creatividad diferencial probablemente seguirá viniendo de humanos durante 2026–2027.

## Veredicto del red team

La idea **no fracasa por lo técnico** (todo el ciclo técnico es automatizable hoy en un grado alto). Puede fracasar por: (1) tasa base de éxito baja combinada con
costes humanos fijos, (2) incapacidad de producir diversión y arte diferencial, (3) cambios de plataforma. La fábrica es defendible sólo si se mide por
**coste por hipótesis probada** y **disciplina de kill**, y si el primer año se trata como investigación con presupuesto acotado.
