import 'package:flutter/material.dart';

class AstroPalette {
  static const appBgTop = Color(0xFFF4ECFF);
  static const appBgMid = Color(0xFFE8DAFF);
  static const appBgBottom = Color(0xFFD9C4FF);

  static const heroTop = Color(0xFF7C68C8);
  static const heroMid = Color(0xFF6B57B8);
  static const heroBottom = Color(0xFF5A469F);

  static const darkText = Color(0xFF35285B);
  static const darkTextStrong = Color(0xFF2F2155);
  static const darkSecondary = Color(0xFF7E6FA8);
  static const mutedLabel = Color(0xFF9A8ABC);

  static const lightText = Colors.white;
  static const lightTextSoft = Color(0xFFF3ECFF);

  static const accent = Color(0xFFA88CF6);
  static const accentStrong = Color(0xFF8F73E8);

  static const glowWhiteLilac = Color(0x55F3E8FF);
  static const glowLilacBlue = Color(0x44DCC8FF);
  static const glowLilacMint = Color(0x33CDB7FF);

  static Color darkGlassFill = Colors.white.withOpacity(0.16);
  static Color lightGlassFill = Colors.white.withOpacity(0.22);
  static Color glassBorder = Colors.white.withOpacity(0.34);

  static const appBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [appBgTop, appBgMid, appBgBottom],
  );

  static const heroSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroTop, heroMid, heroBottom],
  );

  static const iconBubble = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1E6FF), Color(0xFFD9C5FF)],
  );

  static const activeSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D7FF), Color(0xFFB493F7)],
  );
}