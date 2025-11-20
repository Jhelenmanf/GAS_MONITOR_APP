# 📋 Características Detalladas - DetGas Monitor

Este documento describe en detalle todas las características implementadas en la aplicación.

---

## 🔐 Sistema de Autenticación

### Registro de Usuario
**Campos requeridos:**
- Nombre completo (mínimo 2 caracteres)
- Usuario (mínimo 4 caracteres, sin @)
- Contraseña (mínimo 6 caracteres)
- Confirmar contraseña

**Validaciones:**
- Usuario único en la base de datos
- Solo caracteres alfanuméricos y guión bajo en usuario
- Contraseñas coincidentes
- Hash SHA-256 para almacenamiento seguro

**Flujo:**
1. Usuario completa formulario
2. Sistema valida datos
3. Verifica que usuario no exista
4. Crea hash de contraseña
5. Guarda en SQLite
6. Redirige a login

### Login
**Campos:**
- Usuario
- Contraseña
- Checkbox "Recordarme"

**Proceso:**
1. Verifica usuario en base de datos
2. Compara hash de contraseña
3. Actualiza último login
4. Guarda sesión en SharedPreferences
5. Conecta a MQTT
6. Redirige a dashboard

### Sesión Persistente
- Si "Recordarme" está activado, sesión permanece después de cerrar app
- Limpieza automática de datos al reabrir
- Un solo usuario activo a la vez
- Cada usuario tiene datos separados

---

## 📊 Dashboard de Monitoreo

### Gauge Principal
**Componente:** Syncfusion Radial Gauge

**Características:**
- Escala de 0-100 PPM
- 3 rangos de color:
  - 🟢 Verde (0-21): Seguro
  - 🟡 Amarillo (21-30): Precaución
  - 🔴 Rojo (30-100): Peligro
- Aguja dinámica que sigue el valor
- Valor numérico en el centro
- Animaciones suaves

### Indicador de Estado
**Ubicación:** Superior derecha

**Estados:**
- ✅ Conectado (verde) - Sistema recibiendo datos
- ❌ Desconectado (rojo) - Sin comunicación

**Actualización:** Automática cada 10 segundos

### Estadísticas en Tiempo Real

#### Promedio
- Calcula promedio de lecturas últimas 10 horas
- Actualiza con cada nueva lectura
- Formato: XX.X PPM

#### Máxima
- Valor máximo registrado últimas 10 horas
- Se resetea después de limpieza automática
- Formato: XX.X PPM

#### Alertas del Día
- Cuenta lecturas con nivel_alarma > 0 desde medianoche
- Incluye precaución y peligro
- Se resetea diariamente

#### Última Actualización
- Timestamp de última lectura recibida
- Formato: HH:mm:ss
- Actualiza en tiempo real

---

## 🎛️ Control de Electroválvula

### Estado Visual
**Indicadores:**
- 🔓 Icono de candado abierto (válvula abierta)
- 🔒 Icono de candado cerrado (válvula cerrada)
- Color verde para abierta
- Color rojo para cerrada
- Texto descriptivo

### Botón de Cierre
**Comportamiento:**
- Activo solo cuando válvula está abierta
- Muestra diálogo de confirmación
- Envía comando MQTT al presionar "Confirmar"
- Deshabilitado cuando válvula está cerrada

**Mensaje de Confirmación:**
```
¿Estás seguro que deseas cerrar la válvula de gas?

La válvula debe abrirse manualmente después de 
verificar la seguridad.
```

### Cierre Automático
**Toggle configurable:**
- ON: Válvula se cierra cuando PPM > 30
- OFF: Solo cierre manual
- Estado guardado en SharedPreferences
- Persiste después de cerrar app

**Lógica:**
1. Sistema detecta PPM > 30
2. Si cierre automático está ON:
   - Envía comando MQTT
   - Registra acción en historial
   - Envía notificación crítica

### Información de Seguridad
**Mensajes mostrados:**
- ⚠️ La válvula SOLO puede cerrarse electrónicamente
- ✋ Debe abrirse manualmente después de verificar seguridad

---

## 🕒 Historial de Lecturas

### Gráfico Interactivo
**Librería:** fl_chart

**Características:**
- Gráfico de líneas suave
- Eje X: Tiempo (HH:mm)
- Eje Y: PPM (0-100)
- Puntos coloreados según nivel:
  - Verde: Seguro
  - Amarillo: Precaución
  - Rojo: Peligro
- Tooltip al tocar punto:
  - Valor PPM
  - Timestamp exacto
- Área sombreada bajo la línea
- Grid de referencia

**Datos mostrados:**
- Últimas 10 horas
- Ordenados cronológicamente
- Máximo 100 puntos visibles

### Lista de Eventos
**Información por evento:**
- Timestamp (dd/MM/yyyy HH:mm:ss)
- Valor PPM
- Nivel de alarma (badge coloreado)
- Icono según nivel
- Acción tomada (si aplica)

**Formato:**
```
25.3 PPM [Precaución]
20/11/2025 14:30:25
```

**Scroll infinito:** Carga más eventos al hacer scroll

### Gestión de Datos

#### Limpieza Automática
**Trigger:** Al abrir la app

**Proceso:**
1. Calcula timestamp de hace 10 horas
2. Elimina lecturas más antiguas
3. Actualiza contador de lecturas
4. Recalcula estadísticas

#### Borrar Todo
**Proceso:**
1. Usuario presiona botón "Borrar Todo"
2. Sistema muestra confirmación
3. Usuario confirma
4. Elimina TODAS las lecturas del usuario
5. Actualiza vista
6. Muestra mensaje de éxito

**⚠️ Nota:** Esta acción NO se puede deshacer

### Pull to Refresh
- Arrastra hacia abajo para actualizar
- Recarga lecturas desde base de datos
- Aplica limpieza automática
- Actualiza gráfico y lista

---

## 🔔 Sistema de Notificaciones

### Nivel 1: Precaución (21-30 PPM)
**Características:**
- Título: "⚠️ Precaución: Gas Detectado"
- Mensaje: "Nivel de gas: XX.X PPM"
- Prioridad: Alta
- Sonido: Beep intermitente
- Vibración: Patrón corto [0, 500, 200, 500]
- Color: Amarillo
- Canal: gas_warning

### Nivel 2: Peligro (>30 PPM)
**Características:**
- Título: "🚨 ¡PELIGRO! Gas Crítico"
- Mensaje: "Nivel: XX.X PPM - Válvula cerrada automáticamente"
- Prioridad: Máxima
- Sonido: Alarma continua
- Vibración: Patrón largo [0, 1000, 500, 1000, 500, 1000]
- Color: Rojo
- Full-screen intent: Sí
- Canal: gas_danger

### Desconexión del Sistema
**Trigger:** Sin datos por >30 segundos

**Características:**
- Título: "⚠️ Sistema Desconectado"
- Mensaje: "Sin comunicación con el sensor hace >30 segundos"
- Prioridad: Alta
- Canal: system_alerts

### Configuración
**Opciones del usuario:**
- Activar/desactivar notificaciones
- Activar/desactivar sonido
- Activar/desactivar vibración

**Almacenamiento:** SharedPreferences

### Background Service
**Implementación:** WorkManager (pendiente integración nativa)

**Función:**
- Mantiene servicio vivo en background
- Recibe datos MQTT con app cerrada
- Dispara notificaciones según nivel
- Se reinicia automáticamente si se mata

---

## ⚙️ Configuración

### Mi Perfil
**Información mostrada:**
- Foto de perfil (avatar genérico)
- Nombre completo
- Usuario (@usuario)
- Último acceso (fecha y hora)
- Fecha de registro

**No editable:** Esta versión no permite editar perfil

### Notificaciones
**Controles:**
- Toggle: Activar notificaciones
- Toggle: Sonido de alarma (solo si notif. activas)
- Toggle: Vibración (solo si notif. activas)

**Efecto:** Inmediato al cambiar

### Almacenamiento
**Información mostrada:**
- Cantidad de lecturas guardadas
- Tamaño aproximado en MB
- Política: "Últimas 10 horas"

**Acciones:**
- Botón: "Borrar Todo Mi Historial"
- Confirmación requerida
- Elimina solo datos del usuario actual

### Conexión MQTT
**Información:**
- Estado actual (Conectado/Desconectado)
- Broker: HiveMQ Cloud
- Botón: "Probar Conexión"

**Test de conexión:**
1. Verifica estado actual
2. Muestra loading
3. Responde con resultado
4. Muestra mensaje de éxito/error

### Información
**Datos mostrados:**
- Versión de la app: 1.0.0
- Limpieza automática: 10 horas

---

## 📡 Comunicación MQTT

### Conexión
**Configuración:**
- Broker: HiveMQ Cloud
- Puerto: 8883 (TLS/SSL)
- Usuario: detgas
- Contraseña: Figueroa2003.
- Keep-alive: 20 segundos
- Auto-reconnect: Activado

**Proceso:**
1. Crea cliente único con timestamp
2. Configura SSL/TLS
3. Autentica con credenciales
4. Se suscribe a topics
5. Mantiene conexión activa

### Topics

#### gas/sensor/data (Suscripción)
**Recibe cada 10 segundos:**
```json
{
  "ppm": 25.3,
  "valorSensor": 2048,
  "gasDetectado": true,
  "nivelAlarma": 1,
  "timestamp": 1732127754000
}
```

**Procesamiento:**
1. Parsea JSON
2. Crea objeto GasReading
3. Guarda en SQLite
4. Actualiza UI
5. Verifica nivel de alarma
6. Envía notificación si necesario
7. Cierra válvula si auto-close ON y PPM > 30

#### gas/valve/status (Suscripción)
**Recibe al cambiar estado:**
```json
{
  "estado": "cerrada",
  "timestamp": 1732127754000
}
```

**Actualiza:** Indicador visual en Control Page

#### gas/valve/control (Publicación)
**Envía al presionar cerrar:**
```json
{
  "action": "CLOSE"
}
```

**QoS:** At Least Once (1)

### Reconexión Automática
**Comportamiento:**
- Detecta desconexión
- Espera 5 segundos
- Intenta reconectar
- Se suscribe nuevamente a topics
- Notifica al usuario del estado

---

## 💾 Base de Datos SQLite

### Tabla: usuarios
```sql
CREATE TABLE usuarios (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  usuario TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  last_login INTEGER
);
```

**Índices:** Automáticos en PRIMARY KEY y UNIQUE

### Tabla: lecturas
```sql
CREATE TABLE lecturas (
  id TEXT PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  ppm REAL NOT NULL,
  valor_sensor INTEGER NOT NULL,
  gas_detectado INTEGER NOT NULL,
  nivel_alarma INTEGER NOT NULL,
  accion_tomada TEXT,
  usuario_id TEXT NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
);

CREATE INDEX idx_timestamp ON lecturas(timestamp);
CREATE INDEX idx_usuario ON lecturas(usuario_id);
```

**Relación:** Foreign key con CASCADE delete

### Operaciones Comunes

#### Insertar Lectura
```dart
await db.insertReading(reading);
```

#### Obtener Lecturas Usuario
```dart
await db.getUserReadings(userId, hours: 10);
```

#### Limpiar Antiguas
```dart
await db.cleanOldReadings(userId, hours: 10);
```

#### Estadísticas
```dart
await db.getReadingStats(userId);
// Retorna: {promedio, maximo, total}
```

### Ubicación Física
- **Android:** `/data/data/com.detgas.app/databases/detgas.db`
- **iOS:** `/Documents/detgas.db`

---

## 🎨 Diseño y UI/UX

### Tema Oscuro
**Colores principales:**
- Background: #121212 (Negro)
- Cards: #1E1E1E (Gris oscuro)
- Text Primary: #FFFFFF (Blanco)
- Text Secondary: #B0B0B0 (Gris claro)

**Colores de estado:**
- Safe: #4CAF50 (Verde)
- Warning: #FFC107 (Amarillo/Ámbar)
- Danger: #F44336 (Rojo)
- Connected: #4CAF50 (Verde)
- Disconnected: #F44336 (Rojo)

### Tipografía
**Fuente:** Google Fonts - Poppins

**Tamaños:**
- Títulos: 24-36px, Bold
- Subtítulos: 18-20px, SemiBold
- Cuerpo: 14-16px, Regular
- Pequeño: 12px, Regular

### Navegación

#### Bottom Navigation Bar
**3 tabs:**
1. 📊 Monitor (Dashboard)
2. 🎛️ Control (Válvula)
3. 🕒 Historial (Gráficos y eventos)

**Comportamiento:**
- Mantiene estado entre tabs
- Animación suave
- Color activo: Verde (#4CAF50)
- Color inactivo: Gris (#B0B0B0)

#### Drawer (Menú Lateral)
**Estructura:**
- Header con avatar, nombre y @usuario
- Monitor
- Control de Válvula
- Historial
- --- Separador ---
- Mi Perfil (abre Settings)
- Configuración
- --- Separador ---
- Cerrar Sesión (con confirmación)

### Componentes Reutilizables

#### Cards
- Fondo: #1E1E1E
- Border radius: 16px
- Elevation: 2
- Padding: 16px

#### Botones
- Primary: Verde (#4CAF50)
- Danger: Rojo (#F44336)
- Disabled: Gris (#B0B0B0)
- Border radius: 12px
- Height: 56px

#### Formularios
- Background: #1E1E1E
- Border radius: 12px
- Label color: #B0B0B0
- Text color: #FFFFFF

### Animaciones
- Transiciones de página: Slide + Fade
- Loading: Circular Progress (verde)
- Gauge: Smooth needle animation
- Chart: Animated drawing
- Splash screen: Fade in

---

## 📱 Plataformas y Compatibilidad

### Android
**Requisitos:**
- Mínimo: Android 6.0 (API 23)
- Target: Android 14 (API 34)
- Permisos requeridos:
  - INTERNET
  - VIBRATE
  - WAKE_LOCK
  - POST_NOTIFICATIONS
  - SCHEDULE_EXACT_ALARM
  - USE_FULL_SCREEN_INTENT

**Características:**
- Material Design 3
- Notificaciones con canales
- Background service con WorkManager
- Almacenamiento local seguro

### iOS
**Requisitos:**
- Mínimo: iOS 12.0
- Target: iOS 17.0
- Permisos requeridos:
  - Internet (automático)
  - Notifications (solicitado en runtime)

**Características:**
- Cupertino widgets donde aplica
- Notificaciones con UNUserNotificationCenter
- Background refresh
- Almacenamiento local seguro

### Responsive Design
- Funciona en teléfonos (portrait)
- Funciona en tablets (landscape)
- Ajusta tamaños según pantalla
- SafeArea para notches

---

**Última actualización:** 2025-11-20
