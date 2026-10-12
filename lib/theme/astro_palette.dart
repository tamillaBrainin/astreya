import 'package:flutter/material.dart';

class AstroPalette {
  static const appBgTop = Color(0xFFF4ECFF);
  static const appBgMid = Color(0xFFE7D7FF);
  static const appBgBottom = Color(0xFFD5BEFF);

  static const heroTop = Color(0xFF7C68C8);
  static const heroMid = Color(0xFF6B57B8);
  static const heroBottom = Color(0xFF5A469F);

  static const darkText = Color(0xFF2F2552);
  static const darkTextStrong = Color(0xFF2F2552);
  static const darkSecondary = Color(0xFF6C5F91);
  static const mutedLabel = Color(0xFF9285B3);

  static const lightText = Color(0xFFF8F3FF);
  static const lightTextSoft = Color(0xFFE9DEFF);

  static const accent = Color(0xFF58D5D0);
  static const accentStrong = Color(0xFF2FA9B2);
  static const accentMagenta = Color(0xFFC24FAF);
  static const turquoise = Color(0xFF7EE7E1);
  static const turquoiseSoft = Color(0xFFAEEFED);
  static const turquoiseBright = Color(0xFF3FC6D4);
  static const magenta = Color(0xFFE96DFF);
  static const magentaSoft = Color(0xFFF1B3FF);
  static const magentaBright = Color(0xFFD45BFF);
  static const silver = Color(0xFFC9D0DB);
  static const silverSoft = Color(0xFFE9EEF4);

  static const glowWhiteLilac = Color(0x55F3E8FF);
  static const glowLilacBlue = Color(0x44D8C8FF);
  static const glowLilacMint = Color(0x337EE7E1);

  static Color darkGlassFill = Colors.white.withOpacity(0.20);
  static Color lightGlassFill = Colors.white.withOpacity(0.26);
  static Color glassBorder = Colors.white.withOpacity(0.38);

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

  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x775944A5),
      Color(0x555F4BB6),
      Color(0x226FE0DF),
      Color(0x00FFFFFF),
    ],
  );

  static const iconBubble = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAEEFED), Color(0xFFDCCBFF)],
  );

  static const magentaSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1B3FF), Color(0xFFD6C0FF)],
  );

  static const premiumAccentSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6FE3E1), Color(0xFFE96DFF)],
  );

  static const activeSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1E6FF), Color(0xFFDCCBFF)],
  );
}