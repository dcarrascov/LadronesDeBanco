# Cómo contribuir a Ladrones de Banco

[English](CONTRIBUTING.md) · **Español**

Las contribuciones son bienvenidas: avisos de errores, ideas y *pull requests*. ¡Gracias por ayudar!

## Avisar de un error o proponer una idea

Abre un [issue](../../issues) contando qué pasó, o qué te gustaría que hiciera la app. Si es un error, indica:

- tu modelo de iPhone y versión de iOS,
- los pasos para reproducirlo,
- qué esperabas y qué pasó en cambio (una captura ayuda).

## Enviar un cambio

1. Haz un **fork** del repositorio y crea una rama desde `main`, por ejemplo `feature/recordatorio-whatsapp` o `fix/fecha-recordatorio`.
2. **Haz tu cambio** siguiendo el estilo del código:
   - El código y sus nombres están en español (`Persona`, `saldo`, `Recordatorios`…). Mantenlo así.
   - Los textos de la interfaz están en español.
   - Usa solo SwiftUI y SwiftData, sin dependencias de terceros.
3. **Mantén el simulador al día.** Si cambias una pantalla, actualiza también [`simulador/index.html`](simulador/index.html), para que la réplica web siga igual que la app.
4. **Comprueba que compila.** Sube tu rama: el workflow **Compilar IPA** de GitHub Actions se ejecuta en tu *fork* y tiene que terminar en verde. Eso demuestra que el código Swift compila y que la app incluye su ejecutable. En una Mac también puedes ejecutar `bash compilar-ipa.sh`.
5. **Abre un pull request** hacia `main`. Explica qué cambia y por qué, y añade una captura si cambia la interfaz.

## Mensajes de commit

Un título corto en inglés, en imperativo y sin descripción:

```
Add WhatsApp reminder button
```

## Ideas pendientes

- Enviar el recordatorio de cobro por WhatsApp con el importe.
- Registrar lo que *tú* debes, no solo lo que te deben.
- Fecha límite por deuda.
- Hacer la foto de perfil con la cámara.
- Estadísticas, o exportar a Excel.

## Licencia

Al contribuir, aceptas que tu código se publique bajo la [licencia MIT](LICENSE) del proyecto. No añadas imágenes ni otro material que no tengas derecho a compartir.
