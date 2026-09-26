# 17 — Asset Pipeline (2D, 3D, animación, audio, VFX), Blender MCP, Localización y Audio

## 1. Restricciones de plataforma relevantes [HV salvo indicación]

- Mesh individual ≤ **20,000 triángulos**; texturas albedo soportadas a **1024×1024** (`art/modeling/*`).
- Audio: `.mp3/.ogg/.wav/.flac`, < **20 MB** y < **7 minutos**; importación gratuita **2,000 audios/30 días** (ID-verified) o 100 (no verificado);
  moderación y transcodificación; audios de terceros sólo con permiso; canciones visibles en la página del juego si el uploader está ID-verified y aceptó
  las Audio Terms (`audio/assets.md`).
- Todo asset subido pasa **moderación** (asíncrona) y queda privado salvo permisos (asset privacy) [HV].
- Subida programática: `assets/v1` (BETA, 120/min) + permisos de assets + cuotas (`users/{id}/asset-quotas`) [HV OpenAPI].
- Generación nativa: `generate_mesh`, `generate_material`, `generate_procedural_model` en el MCP de Studio; **GenerationService** (4D, beta) [HV/HT].

## 2. Qué se puede automatizar con calidad suficiente (§46)

| Tipo | Automatización viable hoy | Calidad esperada | Nivel | Notas legales |
|---|---|---|---|---|
| Iconos de UI (monedas, ítems, botones) | Generación de imágenes + vectorización/limpieza; o set propio de iconos | Media-alta con estilo fijado y curación | A2 | Modelo con términos comerciales claros; registrar prompt/modelo/fecha |
| UI skins (paneles, marcos) | 9-slice generados/diseñados + tokens | Alta con design system | A2 | — |
| Thumbnails/icono del juego | Capturas reales + composición | Media-alta | A1–A2 | Nada de IP ajena; veracidad |
| Materiales/texturas | `generate_material` (Roblox) / texturas procedurales | Media | A2 | Roblox-native = sin problemas de licencia de terceros [INF] |
| Props low-poly | `generate_mesh` (Cube) / Blender procedural / kits propios | Media (inconsistente de estilo) | A1–A2 | Revisar tris y UVs |
| Personajes/criaturas clave | IA 3D aún inconsistente en rigging/topología para animar | Baja-media | **A0–A1** (humano) | — |
| Mundo/niveles | **Procedural** (scripts Luau que construyen con kits modulares) + blockout por agente vía `execute_luau` | Media para greybox; alta con kit de arte humano | A2 | — |
| Terreno | APIs de Terrain por script | Media | A2 | — |
| Animación | Librería propia + animaciones del catálogo con licencia; generación IA de animación = experimental | Baja-media | A0–A1 | — |
| VFX (partículas, beams) | Presets parametrizados del SDK | Media | A2 | — |
| SFX | Librería Creator Store/Roblox (licenciada para uso en Roblox) + generación con licencia comercial | Media | A2 | Registrar licencia |
| Música | Biblioteca licenciada de Roblox/partners; música generada con licencia clara | Media | A1 | Alto riesgo de copyright → humano |
| TTS/voces | `generateSpeechAsset` (Open Cloud, BETA) | Media | A2 | — |

**Conclusión** [INFERENCIA]: la IA acelera **2D, blockouts, props genéricos y variantes**; el **estilo artístico coherente, personajes y animación** siguen
siendo el cuello de botella humano. La fábrica invierte en **kits de arte modulares reutilizables por género** (hechos o curados por humanos) + generación para relleno.

## 3. Pipeline

```text
Brief (GDD §7/§8) → spec de asset (asset-spec.yaml: tipo, estilo, presupuesto tris/texturas, paleta)
 → producción (humano | Blender | Roblox generate_* | imagen IA)
 → validación automática (tris ≤ presupuesto ≤ 20k, texturas ≤1024, naming, pivotes, colisiones, sin scripts embebidos)
 → policy/IP scan (similitud visual vs corpus de competidores y marcas; OCR de texto; logos)
 → subida (assets/v1) → espera de moderación → registro en assets/LEDGER.yaml (id, origen, licencia, prompt, hash, fecha, autor)
 → uso vía Rojo (IDs en config) o paquete de arte (Roblox Packages) para kits compartidos
```

`LEDGER.yaml` es obligatorio: sin origen/licencia registrados, el policy engine **bloquea** la publicación.

## 4. Blender MCP (§47)

- **Proyecto**: `ahujasid/blender-mcp` (activo, último commit 2026-09-25) [HV]. Arquitectura conocida: add-on de Blender con socket local + servidor MCP;
  permite a Claude ejecutar **código Python arbitrario en Blender** (crear/modificar objetos, materiales; integra fuentes de assets externas) [HT, README].
- **Viabilidad del pipeline Claude → Blender → modelo → UV → texturas → LOD → export → Roblox**:

| Paso | Viable con agente | Comentario |
|---|---|---|
| Modelo (low-poly, hard-surface, props) | Sí (media) | Scripting procedural (bmesh) funciona bien para geometría simple |
| UV unwrap | Sí (automático: smart UV project) | Calidad aceptable para props; no para personajes |
| Texturas | Parcial | Bake de colores/materiales simples; texturas pintadas = humano o IA 2D |
| LOD | Sí (decimate) | Roblox gestiona LOD de meshes propio [HT]; LOD manual rara vez necesario |
| Export FBX/OBJ/glTF | Sí | Escala/ejes a configurar |
| Import a Roblox | Parcial | Subida vía `assets/v1` (modelo/mesh) o 3D Importer de Studio (humano) |

- **Riesgos**: ejecución de código arbitrario (aislar en VM/usuario sin credenciales), integraciones con servicios de assets de terceros (licencias variables),
  estilo inconsistente.
- **Decisión** [DEC-025]: **experimental, Fase 8+**, sólo para props y kits modulares, en workstation aislada; la fábrica no depende de ello para el piloto.

## 5. UI Factory

Ver design system en `10_SHARED_GAME_SDK.md` §5. Los assets 2D de UI salen de un **kit por juego** (tema) sobre componentes comunes; el agente de UI
sólo compone componentes y tokens (no dibuja).

## 6. Localización (§50)

Capacidades [HV/HT]: tablas de localización, **traducción automática** de Roblox (legacy APIs `autolocalization`, `automatic-translation` EXPERIMENTAL),
Open Cloud `:translateText` (BETA, 10,000/min), captura automática de texto (auto-localization), `LocalizationService` y traducción de contenido dinámico
(`production/localization/*`).

Pipeline [DEC-026]:

```text
source strings (claves en src/ + UI DS) → extract (script Lune: TextLabel.Text literales = error de lint; tabla fuente CSV/JSON)
 → translate (translateText API para 10–15 idiomas prioritarios según breakdown País/Idioma de analytics)
 → review (muestreo LLM de calidad + humano nativo para strings de tienda/compras y metadata)
 → publish (actualizar tabla vía API legacy o subir tabla en Creator Hub; fallback a traducción automática de Roblox para el resto)
```

Metadata (título/descripción) localizada con revisión humana (impacta PTR y cumplimiento).

## 7. Audio (§51)

Biblioteca compartida `packages/audio-library` (sólo IDs + metadatos + licencia): SFX de UI, pasos, recompensas, ambientes; música por mood.
Fuentes: Creator Store (licencia de uso en Roblox), audio propio, proveedores con licencia comercial explícita. Reglas: nada de música comercial sin licencia
(detección automática de copyright de Roblox + DMCA [HT]), volúmenes normalizados, SoundGroups (música/SFX/voz) con ajustes de usuario, audio espacial sólo donde
aporte (tiene coste en móvil [INFERENCIA]).
