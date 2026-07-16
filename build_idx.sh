#!/bin/bash

echo "🚀 Démarrage des builds Flutter (APK Android, Windows EXE, Web)..."

# --- 1️⃣ APK Android ---
echo "📱 Build Android APK..."
flutter build apk --release
echo "✅ Android APK généré : build/app/outputs/flutter-apk/app-release.apk"

# --- 2️⃣ Windows EXE ---
echo "💻 Build Windows EXE (nécessite Flutter Desktop activé)..."
flutter config --enable-windows-desktop
flutter build windows --release
echo "✅ Windows EXE généré : build/windows/runner/Release/"

# --- 3️⃣ Web ---
echo "🌐 Build Web..."
flutter config --enable-web
flutter build web --release
echo "✅ Web build généré : build/web/"

echo "🎉 Tous les builds sont terminés !"
