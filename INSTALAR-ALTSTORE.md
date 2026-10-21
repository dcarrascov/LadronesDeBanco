# Instalar Ladrones de Banco en tu iPhone con AltStore (gratis)

Necesitas: tu PC con Windows, tu iPhone (iOS 17 o superior), un cable USB y un Apple ID.
Recomendado: un Apple ID secundario, creado solo para esto.

## 1. Conseguir el .ipa

1. En GitHub, abre el repositorio → pestaña **Actions** → **Compilar IPA**.
2. Entra en la última ejecución con ✅ verde.
3. Abajo, en **Artifacts**, descarga `LadronesDeBanco-ipa` (es un .zip) y descomprímelo: dentro está `LadronesDeBanco.ipa`.

Cada vez que se sube un cambio a `main`, GitHub genera un .ipa nuevo.

## 2. Preparar el PC (una sola vez)

1. Instala **iTunes** e **iCloud** descargados desde la web de Apple
   (no las versiones de la Microsoft Store; AltServer no funciona con esas).
2. Descarga **AltServer para Windows** desde https://altstore.io e instálalo.
   Quedará como un ícono con forma de rombo junto al reloj de Windows.
3. Conecta el iPhone por cable, pulsa **Confiar** en el iPhone.
4. En iTunes, selecciona el iPhone y marca **"Sincronizar con este iPhone vía Wi-Fi"** → Aplicar.
   Esto permite que AltServer renueve la app sin cable.

## 3. Instalar AltStore en el iPhone (una sola vez)

1. Clic en el ícono de AltServer → **Install AltStore** → elige tu iPhone.
2. Escribe tu Apple ID y contraseña (solo se envían a Apple).
3. En el iPhone:
   - **Ajustes → Privacidad y seguridad → Modo desarrollador** → activar (se reinicia).
   - **Ajustes → General → VPN y gestión de dispositivos** → toca tu Apple ID → **Confiar**.

## 4. Instalar Ladrones de Banco

1. Pasa `LadronesDeBanco.ipa` al iPhone: guárdalo en iCloud Drive o envíatelo y guárdalo en la app **Archivos**.
2. Abre **AltStore** → pestaña **My Apps** → botón **+** → elige el `.ipa`.
3. Listo: aparece en tu pantalla de inicio.

## 5. Que no caduque nunca

Con un Apple ID gratuito las apps duran 7 días, pero AltStore las renueva solo si:

- el PC está encendido con **AltServer abierto**, y
- el iPhone y el PC están en la **misma red Wi-Fi**.

Basta con que eso ocurra una vez por semana. También puedes renovar a mano: AltStore → My Apps → **Refresh All**.

Si alguna vez caduca, no se pierden tus datos: renuévala y vuelve con todo.

## Actualizar a una versión nueva

Descarga el .ipa nuevo (paso 1) e instálalo igual (paso 4). Se reemplaza la app y tus datos se conservan.

## Límites de la cuenta gratuita

- Máximo 3 apps instaladas así a la vez (AltStore cuenta como una).
- Máximo 10 apps distintas por semana.
