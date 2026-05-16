# Flutter default
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep model classes for proper serialization
-keep class com.example.catatan_keuangan.models.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep custom font families used by the app
-keep class io.flutter.** { *; }

# Optimize fonts: remove unused glyphs from bundled fonts
# This helps R8/ProGuard strip unused characters from the PlusJakartaSans variable font
-dontwarn sun.awt.**
-dontwarn fontmanager.**
-keep class * extends java.awt.Font { *; }

# Remove unused resources from dependencies (aggressive shrinking)
-assumenosideeffects class android.util.Log { *; }

# Google Play Core (referenced by Flutter embedding)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }



# Flutter Play Store SplitCompat
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
