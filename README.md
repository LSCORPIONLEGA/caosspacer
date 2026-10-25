# CaosSpacer — ducking espectral por sidechain (equivalente a Trackspacer)

Plugin que **talla huecos en el espectro de una pista donde otra pista (el sidechain) tiene energía**: por ejemplo, hace sitio a la voz dentro de una guitarra o a la caja dentro de un pad, sin bajar todo el volumen. Es una **implementación propia e independiente** (STFT con ventana raíz de Hann y solape del 75 %, ganancia por banda controlada por el sidechain). No usa código de Trackspacer ni está afiliado a Wavesfactory, y **no la he comparado oído a oído con el original**: hace la misma técnica, pero el sonido exacto puede diferir.

## ⚠️ Qué hay y qué NO hay en esta carpeta (importante)

| Pieza | Estado |
|---|---|
| `dsp/` motor de audio (C++ puro) | ✅ **Compilado y probado** (Linux): reconstrucción −138 dB, corte de −15 a −17 dB donde suena el sidechain, bloques de cualquier tamaño idénticos, 120 pruebas aleatorias sin errores, ~1 % de un núcleo |
| `dsp/ts_cli.cpp` procesa WAV (principal + sidechain → salida) | ✅ Compilado y probado |
| `dsp/ts_api.cpp` API en C para hacer un `.dll` | ✅ Compilado y probado como `.so` en Linux; **no pude compilarlo como `.dll` de Windows** (aquí no hay compilador de Windows) |
| `plugin/` proyecto JUCE → **`.vst3`** (en Windows es una DLL con extensión .vst3) | ⚠️ **Escrito pero NO compilado ni probado en ningún DAW** (aquí no hay JUCE ni internet). Puede necesitar algún ajuste menor al compilar |
| `plugin/Source/PluginEditor.*` editor gráfico (curva en vivo + perillas) | ⚠️ Escrito, **no compilado**. Es opcional: el flujo compila aparte la versión con editor gráfico y, si falla, la versión normal (editor genérico con deslizadores) sigue funcionando |
| `.github/workflows/build-windows.yml` | ⚠️ Escrito y con YAML válido, **no ejecutado** |

Por eso **el `.dll`/`.vst3` de Windows no viene ya hecho**: hay que compilarlo (es automático, ver abajo).

## 🪟 Instalador para Windows 10
Lee **EMPIEZA_AQUI.txt** (guía paso a paso). El flujo de GitHub genera `CaosSpacer-Setup.exe` (instalador con Inno Setup, script en `installer/CaosSpacer.iss`), que copia el plugin a `C:\Program Files\Common Files\VST3\`. ⚠️ El instalador y su compilación no se pudieron probar aquí; no está firmado, así que SmartScreen pedirá "Más información → Ejecutar de todas formas".

## Cómo obtener el .dll / .vst3 (la forma fácil: GitHub, sin instalar nada)
1. Sube **toda esta carpeta** a un repositorio de GitHub (el flujo está en `.github/workflows/`).
2. En GitHub: pestaña **Actions** → "Compilar CaosSpacer (Windows)" (se ejecuta solo al subir; también con *Run workflow*).
3. Al terminar, abre la ejecución y descarga los artefactos:
   - **CaosSpacer-vst3** → carpeta `CaosSpacer.vst3` (el plugin; dentro está la DLL). Editor genérico con deslizadores: es la versión segura.
   - **CaosSpacer-vst3-grafico** → igual pero con editor gráfico propio (curva de reducción en vivo). Si no aparece, es que esa compilación falló: usa la anterior.
   - **CaosSpacer-dll-y-cli** → `CaosSpacerDSP.dll` (solo el motor, API en C) y `ts_cli.exe`.
4. Copia `CaosSpacer.vst3` a `C:\Program Files\Common Files\VST3\` y reescanea plugins en tu DAW.

Si algo falla al compilar, copia el error del registro de Actions y te lo corrijo.

## Compilar en tu PC (alternativa)
Necesitas Visual Studio 2022 Community (gratis, con "Desarrollo para escritorio con C++") y CMake. Ejecuta `build_windows.bat` (VST3) o `build_dll_windows.bat` (solo el motor `.dll` + `ts_cli.exe`).

## Uso en el DAW
- Ponlo como efecto en la pista que quieres **hacer sitio** (la que será atenuada).
- Envía la pista **dominante** (voz, bombo…) a la **entrada sidechain** del plugin (cada DAW lo llama distinto: *sidechain input*, *key*, *aux send*).
- Si el DAW no tiene sidechain activo, el plugin no corta nada (pasa la señal).
- **Latencia**: 2048 muestras por defecto (46 ms a 44,1 kHz); el plugin se la comunica al DAW para que compense. *Resolution* 1024 = 23 ms, 4096 = 93 ms (más detalle en graves).

## Parámetros
| Parámetro | Qué hace |
|---|---|
| Amount | Profundidad máxima del corte (100 % = hasta −30 dB) |
| Threshold / Range | Nivel de banda del sidechain donde empieza el corte / cuántos dB hasta el corte máximo (por defecto −50 dB y 30 dB) |
| Freq Low / High | Zona del espectro que se puede tallar (fuera de ella no se toca) |
| Attack / Release | Rapidez con que el corte aparece y desaparece |
| Smoothing | Cuánto se "derrama" el corte a las bandas vecinas sin perder profundidad |
| Shape | Curva de respuesta (1 = lineal; >1 solo corta con sidechain fuerte) |
| Bands | Número de bandas (8-64) |
| Resolution | 1024 / 2048 / 4096 puntos (latencia vs. detalle) |
| Mix, Bypass | Seco/mojado y puenteo |

## Probar sin DAW (herramienta de línea de comandos)
```
ts_cli principal.wav sidechain.wav salida.wav amount=80 attack=10 release=200
```
Acepta WAV PCM 16/24/32 bits y float32, mono o estéreo (misma frecuencia de muestreo). La salida queda alineada con la entrada.

## API del `.dll` (para usarlo desde otros programas)
`ts_create(sampleRate)`, `ts_set(h, id, valor)`, `ts_process(h, inL, inR, scL, scR, outL, outR, n)`, `ts_latency(h)`, `ts_curve(h, db, max)`, `ts_destroy(h)`. IDs: 0 amount, 1 threshold, 2 range, 3 freqLow, 4 freqHigh, 5 attack, 6 release, 7 smoothing, 8 shape, 9 bands, 10 resolution (0-2), 11 mix, 12 bypass.

## Calidad de sonido (`tests/test_quality.py`)
Con sidechain estable no hay rizado en la ganancia (0,04 dB), no se añaden armónicos (−75 dB bajo la fundamental), la imagen estéreo se conserva exactamente (R/L = 0,5000) y un clic fuera de la zona tallada conserva forma y posición.

## Pruebas (en Linux/Mac: `sh build_test_linux.sh`)
Reconstrucción sin sidechain, talla en el punto correcto (seno de 1 kHz sobre ruido blanco y sidechain de graves), respeto del rango de frecuencias, ataque/liberación, mezcla, igualdad entre tamaños de bloque, parámetros aleatorios y valores extremos, 3 resoluciones × 3 frecuencias de muestreo, consumo de CPU.

## Licencias
El motor (`dsp/`) es tuyo para usar como quieras. El proyecto de plugin usa **JUCE** (AGPLv3 o licencia comercial: si lo distribuyes sin abrir el código, necesitas licencia JUCE) y el formato **VST3** (SDK de Steinberg, hoy con licencia MIT). "VST" es marca de Steinberg; "Trackspacer" es marca de Wavesfactory.
