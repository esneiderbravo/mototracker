# MotoTracker — Feature Registry

> **Propósito:** Documento vivo que registra todas las funcionalidades implementadas y el roadmap planeado. Actualizar cada vez que se agregue, cambie o elimine una feature.

---

## Stack Técnico

| Capa | Tecnología |
|---|---|
| Framework | Flutter (Dart) |
| Estado | Riverpod |
| Backend / DB | Supabase (PostgreSQL + Auth + Storage) |
| IA | Groq (llama-3.1-8b-instant) |
| Navegación | go_router |
| i18n | slang (ES / EN) |
| Tema | Dark theme personalizado con ThemeTokens |

---

## ✅ Features Implementadas

### 🔐 Autenticación (`features/auth`)
- [x] Splash screen animado con arte de MotoTracker
- [x] Login / registro con email y contraseña (Supabase Auth)
- [x] Cambio de contraseña
- [x] Sesión persistente (redirección automática al abrir la app)
- [x] Guardias de ruta: redirige a login si no hay sesión activa

### 🏍️ Garaje (`features/garage`)
- [x] Lista de motos del usuario en tiempo real (Supabase Realtime stream)
- [x] Tarjetas de moto con foto, nombre, año, placa, kilometraje y color
- [x] Estado vacío con CTA para agregar primera moto
- [x] Agregar moto con formulario moderno
  - [x] Búsqueda con IA: autocompletar marca, modelo, año y color a partir de texto libre
  - [x] Selección de foto desde galería (image_picker)
  - [x] Upload de imagen a Supabase Storage
  - [x] Validadores por campo (requeridos, solo números, etc.)
  - [x] Formatters: solo dígitos en Año y Kilometraje, mayúsculas+sin espacios en Placa
- [x] Detalle de moto
  - [x] Hero photo + nombre + año + placa
  - [x] Tiles de Kilometraje y Color
  - [x] Sección de especificaciones (marca, modelo, año, placa, fecha creación)
  - [x] **AI Insights**: recomendaciones personalizadas generadas por IA basadas en la moto
  - [x] AI Insights en el idioma del usuario (ES / EN)
  - [x] Estado de carga, error con retry, y estado vacío para insights
  - [x] Eliminación de moto con diálogo de confirmación
  - [x] Refresh inmediato del garaje al agregar o eliminar motos
- [x] Zona de peligro con botón de eliminar + loading state

### 🤖 Inteligencia Artificial (`features/ai`)
- [x] Servicio genérico `AiService` con contrato limpio
- [x] Implementación con Groq (llama-3.1-8b-instant)
- [x] **Autofill desde texto libre**: extrae marca, modelo, año y color
- [x] **Insights de moto**: genera 3–5 recomendaciones accionables sobre mantenimiento, seguridad, rendimiento y valor de reventa
- [x] Prompts estructurados con salida JSON estricta
- [x] Respuestas en el idioma configurado del usuario
- [x] Validación de API key antes de llamar al proveedor

### 👤 Perfil (`features/profile`)
- [x] Pantalla de perfil del usuario
- [x] Cerrar sesión

### 🎨 UI / UX Compartido
- [x] Dark theme con palette naranja (`ThemeTokens`)
- [x] Bottom navigation (Garaje / Perfil)
- [x] Toast notifications posicionados debajo del Dynamic Island / notch con animación slide+fade
- [x] Widgets reutilizables: `AsyncValueBuilder`, `AppAlerts`, `MotoBottomNav`
- [x] Input formatters reutilizables: `UpperCaseTextFormatter`, `DigitsOnlyFormatter`, `AlphanumericNoSpaceFormatter`

### 🌍 Internacionalización
- [x] Español (ES) — idioma por defecto
- [x] Inglés (EN)
- [x] Generación automática de strings con `slang`

### ⚙️ Infraestructura
- [x] Configuración de entorno con `dart-define-from-file` (`config/env.json`)
- [x] Arquitectura limpia: domain / data / presentation por feature
- [x] Router centralizado con go_router
- [x] CI-ready: scripts de formato (`tool/format.sh`, `tool/check_format.sh`)

---

## 🗺️ Roadmap — Features Planificadas

> Prioridades sugeridas. El orden puede cambiar según feedback.

### 🔧 Mantenimientos
- [ ] Registrar mantenimientos por moto (aceite, frenos, cadena, filtros, etc.)
- [ ] Historial de mantenimientos con fechas y kilometraje
- [ ] Recordatorios de próximo mantenimiento (por km o por fecha)
- [ ] **IA**: sugerir mantenimientos pendientes basado en km actual y modelo de moto
- [ ] **IA**: estimar costo de mantenimiento según marca/modelo/año

### 📄 Documentos Legales
- [ ] Registro de SOAT: fecha de vencimiento, número de póliza, aseguradora
- [ ] Notificación de vencimiento de SOAT (30, 15 y 5 días antes)
- [ ] Registro de Revisión Técnico-Mecánica (RTM / Tecnomecánica)
- [ ] Notificación de vencimiento de RTM
- [ ] Historial de documentos por moto
- [ ] **IA**: alertas inteligentes agrupadas de todos los documentos próximos a vencer

### 🛣️ Rutas
- [ ] Registro de rutas realizadas (origen, destino, km recorridos, fecha)
- [ ] Mapa interactivo con visualización de ruta
- [ ] Galería de fotos por ruta
- [ ] **IA**: sugerir rutas populares según ubicación y tipo de moto
- [ ] Compartir ruta con la comunidad

### 👥 Comunidad
- [ ] Perfil público del motociclista (apodo, motos, rutas)
- [ ] Feed de actividad (rutas compartidas, logros, mantenimientos)
- [ ] Grupos / clubes de motos
- [ ] Sistema de seguidores
- [ ] Eventos y convocatorias de rodadas

### 📊 Estadísticas e Insights
- [ ] Dashboard con resumen: km totales, mantenimientos realizados, gastos
- [ ] Gráfico de evolución de kilometraje
- [ ] Gasto total en mantenimiento por moto / por período
- [ ] **IA**: análisis de patrones de uso y recomendaciones personalizadas

### 🔔 Notificaciones
- [ ] Push notifications para recordatorios de mantenimiento
- [ ] Push notifications para vencimiento de documentos
- [ ] Notificaciones de actividad en la comunidad

### 🔎 Búsqueda y Comparación
- [ ] Buscar otras motos en la comunidad por marca/modelo
- [ ] Comparar especificaciones entre dos motos
- [ ] **IA**: comparativa de costos de mantenimiento entre modelos

### 🛒 Marketplace / Directorio (largo plazo)
- [ ] Directorio de talleres recomendados por la comunidad
- [ ] Directorio de aseguradoras con comparativa de SOAT
- [ ] Marketplace de repuestos entre usuarios

---

## 📁 Estructura de Archivos

```
lib/
├── app/                        # App root y configuración
├── core/
│   ├── constants/              # Env, configuración
│   ├── router/                 # go_router
│   ├── theme/                  # ThemeTokens, AppTheme
│   └── utils/                  # Validators, TextFormatters, LocaleController
├── features/
│   ├── ai/                     # Servicio de IA (Groq)
│   ├── auth/                   # Autenticación (Supabase)
│   ├── garage/                 # Garaje y motos
│   └── profile/                # Perfil de usuario
├── i18n/                       # Strings ES / EN (slang)
├── shared/
│   └── widgets/                # Widgets compartidos
└── main.dart
```

---

## 📝 Convención de actualización

Cada vez que se implemente o modifique una feature:
1. Mover el ítem de **Roadmap** a **Implementadas** con `[x]`.
2. Agregar fecha opcional en comentario: `<!-- implementado: 2026-04-02 -->`.
3. Actualizar la estructura de archivos si aplica.
4. Hacer commit incluyendo `docs: update FEATURES.md`.

