# 📖 Guía de Instalación - DetGas Monitor

## 📋 Requisitos Previos

### Software Necesario:
- **Flutter SDK** (3.0.0 o superior)
  - Descargar desde: https://flutter.dev/docs/get-started/install
- **Android Studio** (para desarrollo Android)
  - Descargar desde: https://developer.android.com/studio
- **Xcode** (para desarrollo iOS - solo macOS)
  - Descargar desde App Store

### Verificar Instalación:
```bash
flutter doctor
```

Este comando verificará que todo esté correctamente instalado.

---

## 🚀 Instalación Paso a Paso

### 1. Clonar el Repositorio
```bash
git clone https://github.com/Jhelenmanf/GAS_MONITOR_APP.git
cd GAS_MONITOR_APP
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

Este comando descargará todas las dependencias necesarias del proyecto.

### 3. Configurar Permisos

#### Android:
Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`:
- Internet
- Vibración
- Notificaciones
- Alarmas exactas
- Full-screen intent (para notificaciones críticas)

#### iOS:
Los permisos ya están configurados en `ios/Runner/Info.plist`.

### 4. Ejecutar la Aplicación

#### En un Dispositivo/Emulador Android:
```bash
flutter run
```

#### En un Simulador iOS (solo macOS):
```bash
flutter run -d ios
```

#### Listar Dispositivos Disponibles:
```bash
flutter devices
```

---

## 🔧 Configuración Adicional

### Base de Datos SQLite
La base de datos se crea automáticamente al iniciar la aplicación por primera vez.

**Ubicación:**
- Android: `/data/data/com.detgas.app/databases/detgas.db`
- iOS: `/Documents/detgas.db`

### Conexión MQTT
Las credenciales de HiveMQ Cloud están incluidas en el código:
- **Broker:** `8d1f3016a8dd40d5b0565c2cce462b15.s1.eu.hivemq.cloud`
- **Puerto:** 8883 (TLS/SSL)
- **Usuario:** detgas
- **Contraseña:** Figueroa2003.

No es necesario configurar nada adicional.

---

## 🛠️ Compilación para Producción

### Android APK:
```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (para Google Play Store):
```bash
flutter build appbundle --release
```

### iOS (requiere cuenta de desarrollador de Apple):
```bash
flutter build ios --release
```

---

## ❓ Solución de Problemas Comunes

### Problema: "Flutter SDK not found"
**Solución:** Asegúrate de haber agregado Flutter al PATH del sistema.

### Problema: Error de compilación en Android
**Solución:** 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problema: Dependencias no se descargan
**Solución:**
```bash
flutter pub cache repair
flutter pub get
```

### Problema: Error con Google Fonts
**Solución:** Verifica tu conexión a internet. Google Fonts se descargan automáticamente.

### Problema: Notificaciones no funcionan
**Solución:** 
- Android: Verifica que la app tenga permisos de notificación en la configuración del sistema.
- iOS: Acepta los permisos cuando la app los solicite.

### Problema: No se conecta a MQTT
**Solución:**
- Verifica tu conexión a internet
- Asegúrate de que el dispositivo no esté bloqueando conexiones seguras (TLS/SSL)

---

## 📱 Requisitos del Dispositivo

### Android:
- Versión mínima: Android 6.0 (API 23)
- Almacenamiento: Al menos 50 MB libres
- Conexión a Internet (WiFi o datos móviles)

### iOS:
- Versión mínima: iOS 12.0
- Almacenamiento: Al menos 50 MB libres
- Conexión a Internet (WiFi o datos móviles)

---

## 🧪 Modo de Desarrollo

Para ejecutar en modo debug con hot reload:
```bash
flutter run
```

**Hot Reload:** Presiona `r` en la terminal para recargar cambios sin reiniciar la app.

**Hot Restart:** Presiona `R` para reiniciar completamente la app.

---

## 📞 Soporte

Si encuentras algún problema durante la instalación:

1. Revisa la documentación oficial de Flutter: https://flutter.dev/docs
2. Consulta los issues del repositorio: https://github.com/Jhelenmanf/GAS_MONITOR_APP/issues
3. Contacta al desarrollador

---

**Última actualización:** 2025-11-20
