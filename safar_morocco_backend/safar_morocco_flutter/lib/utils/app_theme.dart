import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🇲🇦 Thème Professionnel Marocain - Inspiré du tourisme et de l'élégance
  
  // Primary Colors - Palette professionnelle et moderne
  static const Color primaryColor = Color(0xFF1E40AF);      // Bleu professionnel profond
  static const Color primaryLight = Color(0xFF3B82F6);     // Bleu clair moderne
  static const Color primaryDark = Color(0xFF1E3A8A);      // Bleu foncé élégant
  
  // Secondary Colors - Touches marocaines
  static const Color secondaryColor = Color(0xFFDC2626);    // Rouge marocain élégant
  static const Color accentColor = Color(0xFFD97706);       // Or/ambre marocain
  static const Color tertiaryColor = Color(0xFF059669);     // Vert émeraude
  
  // Neutral Colors - Palette grise professionnelle
  static const Color darkColor = Color(0xFF111827);        // Noir profond
  static const Color lightColor = Color(0xFFFFFFFF);        // Blanc pur
  static const Color surfaceColor = Color(0xFFF9FAFB);      // Surface claire
  static const Color cardColor = Color(0xFFFFFFFF);        // Cartes blanches
  
  // Status Colors - Cohérentes et professionnelles
  static const Color successColor = Color(0xFF059669);     // Vert succès
  static const Color errorColor = Color(0xFFDC2626);       // Rouge erreur
  static const Color warningColor = Color(0xFFD97706);      // Orange avertissement
  static const Color infoColor = Color(0xFF1E40AF);         // Bleu info
  
  // Text Colors - Hiérarchie claire
  static const Color textPrimary = Color(0xFF111827);       // Texte principal
  static const Color textSecondary = Color(0xFF6B7280);     // Texte secondaire
  static const Color textTertiary = Color(0xFF9CA3AF);      // Texte tertiaire
  static const Color textHint = Color(0xFFD1D5DB);         // Texte hint
  
  // UI Colors - Finitions professionnelles
  static const Color borderColor = Color(0xFFE5E7EB);        // Bordures subtiles
  static const Color backgroundColor = Color(0xFFFAFAFA);    // Fond clair
  static const Color dividerColor = Color(0xFFF3F4F6);      // Diviseurs
  static const Color shadowColor = Color(0x1A000000);       // Ombres subtiles
  
  // Gradient Colors - Touches modernes
  static const List<Color> primaryGradient = [
    Color(0xFF1E40AF),
    Color(0xFF3B82F6),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFDC2626),
    Color(0xFFD97706),
  ];

  // 🔄 Alias de compatibilité (pour éviter les erreurs de compilation)
  // Ces anciens noms sont dépréciés mais gardés pour compatibilité
  @deprecated
  static const Color textLightColor = textSecondary;
  @deprecated
  static const Color textDarkColor = textPrimary;
  @deprecated
  static const Color textHintColor = textHint;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontSize: 28, // Réduit de 32 à 28
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontSize: 24, // Réduit de 28 à 24
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20, // Réduit de 24 à 20
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18, // Réduit de 20 à 18
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16, // Réduit de 18 à 16
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14, // Réduit de 16 à 14
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12, // Réduit de 14 à 12
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textPrimary,
          height: 1.5,
          fontSize: 14, // Réduit de 16 à 14
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.5,
          fontSize: 12, // Réduit de 14 à 12
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: textTertiary,
          fontSize: 10, // Réduit de 12 à 10
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Colors.white,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 16, // Réduit de 20 à 16
          fontWeight: FontWeight.w700,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: textHint,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return 8;
            if (states.contains(WidgetState.pressed)) return 2;
            return 0;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderColor),
        ),
        side: const BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 16,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Color(0xFF1E293B),
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  // Spacing (modern & balanced)
  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius (modern, softer)
  static const double radiusSmall = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 50.0;

  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Shadows (modern elevation)
  static final BoxShadow shadowSmall = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static final BoxShadow shadowMedium = BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static final BoxShadow shadowLarge = BoxShadow(
    color: Colors.black.withOpacity(0.16),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
