# 🔥 DetGas Monitor - Sistema de Detección y Monitoreo de Gas IoT

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**DetGas Monitor** es una aplicación móvil Flutter completa para monitorear en tiempo real un sistema de detección de gas LPG usando sensores MQ-5 con ESP32, comunicación MQTT (HiveMQ Cloud) y control de electroválvula.

---

## ✨ Características Principales

### 🔐 Sistema de Autenticación
- ✅ Registro sin email (solo nombre, usuario y contraseña)
- ✅ Login con sesión persistente ("Recordarme")
- ✅ Múltiples usuarios con historial individual
- ✅ Hash de contraseñas con SHA-256

### 📊 Monitoreo en Tiempo Real
- 📡 Conexión MQTT con HiveMQ Cloud
- 🎯 Gauge circular mostrando PPM actual
- 🚦 3 niveles de alarma con colores:
  - 🟢 **Seguro** (0-21 PPM)
  - 🟡 **Precaución** (21-30 PPM)
  - 🔴 **Peligro** (>30 PPM)
- 📈 Estadísticas: Promedio, Máxima, Alertas del día

### 🎛️ Control de Electroválvula
- 🔒 Cierre remoto de válvula mediante MQTT
- ⚙️ Cierre automático cuando PPM > 30 (configurable)
- ⚠️ Confirmación de seguridad antes de cerrar

### 🕒 Historial de Lecturas
- 📈 Gráfico interactivo de líneas (últimas 10 horas)
- 📋 Lista de eventos con timestamp y nivel
- 🧹 Limpieza automática de datos antiguos
- 🗑️ Opción para borrar todo el historial

### 🔔 Sistema de Notificaciones
- 📱 Notificaciones locales con distintas prioridades
- 🔊 Sonido y vibración configurables
- 🚨 Full-screen intent para alertas críticas
- ⚡ Funcionan con app cerrada (WorkManager)

### ⚙️ Configuración Completa
- 👤 Perfil de usuario con información
- 🔔 Configuración de notificaciones
- 💾 Gestión de almacenamiento
- 📡 Estado de conexión MQTT
- ℹ️ Información de la aplicación

---

## 🚀 Instalación Rápida

### 1. Clonar el repositorio
```bash
git clone https://github.com/Jhelenmanf/GAS_MONITOR_APP.git
cd GAS_MONITOR_APP
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la aplicación
```bash
flutter run
```

📖 **Para más detalles, consulta [INSTALACION.md](docs/INSTALACION.md)**

---

## 📸 Capturas de Pantalla

> 🖼️ *Las capturas de pantalla se añadirán próximamente*

---

## 🛠️ Tecnologías Utilizadas

### Framework
- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación

### Gestión de Estado
- **flutter_bloc** - Patrón BLoC para gestión de estado
- **equatable** - Comparación de objetos

### Comunicación
- **mqtt_client** - Cliente MQTT para comunicación IoT

### Base de Datos
- **sqflite** - Base de datos SQLite local
- **path_provider** - Rutas del sistema de archivos
- **shared_preferences** - Almacenamiento de preferencias

### Notificaciones
- **flutter_local_notifications** - Notificaciones locales
- **workmanager** - Background service

### UI/UX
- **fl_chart** - Gráficos interactivos
- **syncfusion_flutter_gauges** - Gauge circular
- **google_fonts** - Fuente Poppins

### Utilidades
- **crypto** - Hash SHA-256 para contraseñas
- **uuid** - Generación de IDs únicos
- **intl** - Internacionalización y formato de fechas
- **permission_handler** - Gestión de permisos

---

## 📋 Requisitos del Sistema

### Android
- Versión mínima: **Android 6.0 (API 23)**
- Permisos: Internet, Notificaciones, Vibración

### iOS
- Versión mínima: **iOS 12.0**
- Permisos: Internet, Notificaciones

---

## 🔧 Configuración MQTT

La aplicación se conecta automáticamente a HiveMQ Cloud:

- **Broker:** `8d1f3016a8dd40d5b0565c2cce462b15.s1.eu.hivemq.cloud`
- **Puerto:** 8883 (TLS/SSL)
- **Usuario:** detgas
- **Contraseña:** Figueroa2003.

### Topics:
- `gas/sensor/data` - Recibe datos del sensor (cada 10 segundos)
- `gas/valve/status` - Recibe estado de la válvula
- `gas/valve/control` - Envía comandos de control

---

## 💾 Almacenamiento de Datos

### Base de Datos SQLite
La aplicación utiliza SQLite para almacenar:
- **Usuarios:** Información de autenticación
- **Lecturas:** Historial de mediciones de gas

### Política de Retención
- ✅ Se guardan las últimas **10 horas** de lecturas
- 🧹 Limpieza automática al abrir la app
- 🗑️ Cada usuario puede borrar su historial completo

---

## 🎨 Diseño

### Tema Oscuro
- Fondo: Negro (#121212)
- Cards: Gris oscuro (#1E1E1E)
- Fuente: Google Poppins

### Navegación
- **Bottom Navigation Bar:** Monitor, Control, Historial
- **Drawer:** Menú lateral con perfil y configuración

---

## 👨‍💻 Estructura del Proyecto

```
lib/
├── main.dart                     # Punto de entrada
├── core/
│   ├── constants/               # Constantes y configuración
│   └── utils/                   # Utilidades y validadores
├── data/
│   ├── models/                  # Modelos de datos
│   └── database/                # Helper de base de datos
├── services/                    # Servicios (MQTT, Auth, etc.)
└── presentation/
    ├── pages/                   # Páginas de la aplicación
    └── widgets/                 # Widgets reutilizables
```

---

## 📚 Documentación

- 📖 [Guía de Instalación](docs/INSTALACION.md)

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 👤 Autor

**Jhelen Manfredotti**
- GitHub: [@Jhelenmanf](https://github.com/Jhelenmanf)
- Usuario: @jhelenmanf

---

## 🙏 Agradecimientos

- Equipo de Flutter y Dart
- Comunidad de HiveMQ Cloud
- Creadores de las librerías utilizadas

---

**Versión:** 1.0.0  
**Última actualización:** 2025-11-20  
**Estado:** ✅ Producción
