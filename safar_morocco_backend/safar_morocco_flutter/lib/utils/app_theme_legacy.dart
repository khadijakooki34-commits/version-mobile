// Fichier de compatibilité temporaire pour éviter les erreurs de compilation
import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeLegacy {
  // Alias pour la compatibilité
  static Color get textLightColor => AppTheme.textSecondary;
  static Color get textDarkColor => AppTheme.textPrimary;
  static Color get textHintColor => AppTheme.textHint;
}
