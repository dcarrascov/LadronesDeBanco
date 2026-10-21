#!/bin/bash
# Genera LadronesDeBanco.ipa (sin firmar) para instalarlo con AltStore.
# Uso: abre Terminal en esta carpeta y ejecuta:  bash compilar-ipa.sh
set -euo pipefail
cd "$(dirname "$0")"

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "❌ No encuentro Xcode. Instálalo desde la App Store y luego ejecuta:"
  echo "   sudo xcode-select -s /Applications/Xcode.app"
  exit 1
fi
xcodebuild -version

rm -rf build
mkdir -p build
echo "⏳ Compilando… (el registro completo queda en build/compilacion.log)"

if ! xcodebuild build \
  -project LadronesDeBanco.xcodeproj \
  -target LadronesDeBanco \
  -configuration Release \
  -sdk iphoneos \
  SYMROOT="$PWD/build" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" > build/compilacion.log 2>&1; then
  echo ""
  echo "❌ La compilación falló. Errores encontrados:"
  grep -E "error:" build/compilacion.log | sort -u || tail -n 40 build/compilacion.log
  echo ""
  echo "Envía el archivo build/compilacion.log para corregirlo."
  exit 1
fi

# Sin ejecutable la app no abre aunque xcodebuild diga que todo fue bien.
if [ ! -f build/Release-iphoneos/LadronesDeBanco.app/LadronesDeBanco ]; then
  echo "❌ La app se generó sin ejecutable: el código Swift no se compiló."
  echo "Envía el archivo build/compilacion.log para corregirlo."
  exit 1
fi

mkdir -p build/Payload
cp -R build/Release-iphoneos/LadronesDeBanco.app build/Payload/
(cd build && zip -qry ../LadronesDeBanco.ipa Payload)

echo ""
echo "✅ Listo: $PWD/LadronesDeBanco.ipa"
open -R LadronesDeBanco.ipa
