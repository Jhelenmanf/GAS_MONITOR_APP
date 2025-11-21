# 🚀 Guía de Inicio Rápido - DetGas Monitor

Esta guía te ayudará a tener la aplicación funcionando en menos de 5 minutos.

---

## ⚡ Inicio Rápido

### 1. Prerrequisitos
```bash
# Verifica que tienes Flutter instalado
flutter --version

# Debe mostrar Flutter 3.0.0 o superior
```

Si no tienes Flutter, descárgalo de: https://flutter.dev

### 2. Clonar e Instalar
```bash
# Clonar repositorio
git clone https://github.com/Jhelenmanf/GAS_MONITOR_APP.git
cd GAS_MONITOR_APP

# Instalar dependencias
flutter pub get
```

### 3. Ejecutar
```bash
# Conecta un dispositivo o inicia un emulador
flutter devices

# Ejecuta la app
flutter run
```

¡Eso es todo! La app debería abrirse en tu dispositivo.

---

## 📱 Primera Vez Usando la App

### Paso 1: Registro
1. En la pantalla de login, toca **"¿No tienes cuenta? Regístrate"**
2. Completa el formulario:
   - Nombre: `Juan Pérez`
   - Usuario: `juanp` (sin @)
   - Contraseña: `123456` (mínimo 6 caracteres)
   - Confirmar contraseña: `123456`
3. Toca **"CREAR CUENTA"**

### Paso 2: Login
1. Ingresa tus credenciales:
   - Usuario: `juanp`
   - Contraseña: `123456`
2. (Opcional) Activa **"Recordarme"**
3. Toca **"INICIAR SESIÓN"**

### Paso 3: Explorar el Dashboard
- Verás el gauge circular esperando datos del sensor
- El indicador de conexión mostrará el estado MQTT
- Las estadísticas aparecerán cuando haya lecturas

---

## 🔧 Configuración Rápida

### Activar Cierre Automático
1. Ve a la tab **"Control"**
2. Activa el switch **"Cerrar automáticamente cuando PPM > 30"**
3. ¡Listo! La válvula se cerrará automáticamente en caso de peligro

### Configurar Notificaciones
1. Abre el menú lateral (☰)
2. Toca **"Configuración"**
3. En la sección "Notificaciones":
   - Activa **"Activar notificaciones"**
   - Activa **"Sonido de alarma"**
   - Activa **"Vibración"**

---

## 📊 Probando la Aplicación

### Sin Hardware Real (Simulación)
Si no tienes el ESP32 conectado, puedes simular datos:

1. La app se conectará a HiveMQ Cloud
2. Puedes usar una herramienta MQTT para enviar datos de prueba:

**Herramientas recomendadas:**
- MQTT Explorer (Desktop)
- MyMQTT (Android)
- MQTTool (iOS)

**Configuración:**
```
Broker: 8d1f3016a8dd40d5b0565c2cce462b15.s1.eu.hivemq.cloud
Puerto: 8883
Usuario: detgas
Contraseña: Figueroa2003.
SSL/TLS: Activado
```

**Enviar datos de prueba al topic:** `gas/sensor/data`
```json
{
  "ppm": 25.3,
  "valorSensor": 2048,
  "gasDetectado": true,
  "nivelAlarma": 1,
  "timestamp": 1732127754000
}
```

### Con Hardware Real
1. Configura tu ESP32 con sensor MQ-5
2. Conecta al mismo broker HiveMQ
3. El ESP32 enviará datos cada 10 segundos
4. La app los recibirá automáticamente

---

## 🎯 Funciones Principales

### Ver Lecturas en Tiempo Real
- **Tab:** Monitor
- **Actualización:** Cada 10 segundos
- **Gauge:** Muestra PPM actual con colores dinámicos

### Cerrar Válvula Manualmente
- **Tab:** Control
- **Botón:** "CERRAR VÁLVULA"
- **Confirmación:** Se solicitará confirmación
- **Resultado:** Comando enviado por MQTT

### Ver Historial
- **Tab:** Historial
- **Gráfico:** Últimas 10 horas
- **Lista:** Todos los eventos
- **Actualizar:** Arrastra hacia abajo

### Cambiar Configuración
- **Menú:** Abrir drawer (☰)
- **Opción:** "Configuración"
- **Secciones:** Perfil, Notificaciones, Almacenamiento, Conexión

---

## 🐛 Solución Rápida de Problemas

### "No conecta a MQTT"
```bash
# Verifica tu conexión a internet
ping google.com

# Reinicia la app
# El servicio se reconecta automáticamente
```

### "No aparecen datos"
- Verifica que el ESP32 esté enviando datos
- Revisa el topic correcto: `gas/sensor/data`
- Verifica el indicador de conexión en la app

### "Error al compilar"
```bash
# Limpia el proyecto
flutter clean

# Reinstala dependencias
flutter pub get

# Intenta de nuevo
flutter run
```

### "Notificaciones no funcionan"
1. Android: Ve a Configuración > Apps > DetGas > Notificaciones
2. Asegúrate de que los permisos estén otorgados
3. Verifica en la app: Configuración > Notificaciones

---

## 📚 Siguientes Pasos

1. **Lee la documentación completa:**
   - [README.md](../README.md)
   - [INSTALACION.md](INSTALACION.md)
   - [FEATURES.md](FEATURES.md)

2. **Explora todas las funciones:**
   - Crea múltiples usuarios
   - Prueba el cierre automático
   - Revisa el historial
   - Configura notificaciones

3. **Personaliza:**
   - Ajusta los umbrales (edita `app_constants.dart`)
   - Cambia colores (edita `app_colors.dart`)
   - Modifica la UI según tus necesidades

---

## 🆘 ¿Necesitas Ayuda?

- **Documentación:** Revisa la carpeta `docs/`
- **Issues:** https://github.com/Jhelenmanf/GAS_MONITOR_APP/issues
- **Contribuir:** Lee [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## ✅ Checklist de Inicio

- [ ] Flutter instalado y verificado
- [ ] Proyecto clonado
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] App ejecutada en dispositivo
- [ ] Usuario registrado
- [ ] Login exitoso
- [ ] Dashboard visible
- [ ] Conexión MQTT establecida
- [ ] Primera lectura recibida (si tienes hardware)
- [ ] Notificaciones configuradas
- [ ] Cierre automático activado

---

**¡Listo para monitorear gas en tiempo real! 🔥**

---

**Última actualización:** 2025-11-20
