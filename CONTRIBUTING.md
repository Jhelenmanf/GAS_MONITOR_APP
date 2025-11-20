# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a DetGas Monitor! Este documento proporciona las pautas para contribuir al proyecto.

## 📋 Código de Conducta

Este proyecto adhiere a un código de conducta. Al participar, se espera que mantengas este código. Por favor, reporta comportamientos inaceptables.

## 🚀 Cómo Contribuir

### Reportar Bugs

Si encuentras un bug, por favor crea un issue con:
- **Título claro y descriptivo**
- **Descripción detallada** del problema
- **Pasos para reproducir** el bug
- **Comportamiento esperado** vs. comportamiento actual
- **Capturas de pantalla** (si aplica)
- **Información del dispositivo** (OS, versión, etc.)

### Sugerir Mejoras

Para sugerir una nueva característica:
- Crea un issue con el tag `enhancement`
- Describe claramente la funcionalidad propuesta
- Explica por qué sería útil
- Proporciona ejemplos de uso si es posible

### Pull Requests

1. **Fork el repositorio** y crea tu rama desde `main`
   ```bash
   git checkout -b feature/mi-nueva-caracteristica
   ```

2. **Sigue las convenciones de código:**
   - Todos los comentarios en español
   - Usa nombres descriptivos para variables y funciones
   - Mantén la estructura del proyecto
   - Sigue el estilo de código existente

3. **Escribe código limpio:**
   - Sin código comentado innecesario
   - Sin console.log en producción
   - Maneja errores apropiadamente

4. **Prueba tu código:**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit con mensajes descriptivos:**
   ```bash
   git commit -m "Añade: Funcionalidad X para mejorar Y"
   ```

6. **Push a tu fork:**
   ```bash
   git push origin feature/mi-nueva-caracteristica
   ```

7. **Abre un Pull Request** con:
   - Título descriptivo
   - Descripción de los cambios
   - Referencias a issues relacionados
   - Capturas de pantalla (si aplica)

## 🎨 Estilo de Código

### Dart/Flutter
- Usa `flutter format` antes de hacer commit
- Sigue las [Dart Style Guidelines](https://dart.dev/guides/language/effective-dart/style)
- Prefiere `const` constructors cuando sea posible
- Usa trailing commas para mejor formateo

### Comentarios
```dart
// ═══════════════════════════════════════════════════════════
// 📊 TÍTULO DE SECCIÓN
// ═══════════════════════════════════════════════════════════

// Comentario explicativo de una función
void miFuncion() {
  // Comentario de implementación
}
```

### Nombres
- **Clases:** PascalCase (`MiClase`)
- **Funciones/Variables:** camelCase (`miFuncion`, `miVariable`)
- **Constantes:** camelCase con prefijo (`keyMiConstante`)
- **Archivos:** snake_case (`mi_archivo.dart`)

## 📚 Estructura del Proyecto

Mantén los archivos en las carpetas apropiadas:
```
lib/
├── core/              # Configuración y utilidades
├── data/              # Modelos y base de datos
├── services/          # Lógica de negocio
└── presentation/      # UI y widgets
```

## ✅ Checklist del Pull Request

Antes de enviar tu PR, asegúrate de:
- [ ] El código compila sin errores
- [ ] Todos los tests pasan
- [ ] El código sigue el estilo del proyecto
- [ ] Los comentarios están en español
- [ ] La documentación está actualizada (si aplica)
- [ ] No hay credenciales hardcodeadas
- [ ] El PR tiene una descripción clara

## 🔍 Proceso de Revisión

1. Un mantenedor revisará tu PR
2. Se pueden solicitar cambios
3. Una vez aprobado, se hará merge

## 📝 Commit Messages

Usa mensajes claros y descriptivos:
- ✅ `Añade: Sistema de notificaciones push`
- ✅ `Corrige: Error en validación de formulario`
- ✅ `Mejora: Rendimiento del gráfico`
- ❌ `fix`
- ❌ `changes`
- ❌ `update`

## 🐛 Debugging

Para debugging:
```bash
flutter run --verbose
flutter logs
```

## 📞 ¿Necesitas Ayuda?

Si tienes preguntas:
- Abre un issue con el tag `question`
- Revisa la documentación existente
- Consulta los issues cerrados

## 🙏 Agradecimientos

¡Gracias por contribuir a DetGas Monitor! Cada contribución ayuda a mejorar el proyecto.

---

**Última actualización:** 2025-11-20
