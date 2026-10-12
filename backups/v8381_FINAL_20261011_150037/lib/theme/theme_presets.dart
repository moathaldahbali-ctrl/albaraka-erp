// lib/theme/theme_presets.dart
// Theme presets - 6 presets x (light + dark)
// Last update: 2026-10-07

import 'package:flutter/material.dart';

class ThemePreset {
  final String id;
  final String nameAr;
  final String emoji;

  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightHeaderRow;

  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkHeaderRow;

  const ThemePreset({
    required this.id,
    required this.nameAr,
    required this.emoji,
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightHeaderRow,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkHeaderRow,
  });

  Color primaryFor(Brightness b) =>
      b == Brightness.dark ? darkPrimary : lightPrimary;
  Color secondaryFor(Brightness b) =>
      b == Brightness.dark ? darkSecondary : lightSecondary;
  Color headerRowFor(Brightness b) =>
      b == Brightness.dark ? darkHeaderRow : lightHeaderRow;
  Color backgroundFor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  Color surfaceFor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color borderFor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF424242) : const Color(0xFFBDBDBD);
  Color textPrimaryFor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFFEEEEEE) : const Color(0xFF212121);
  Color textSecondaryFor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
}

const List<ThemePreset> kThemePresets = [
  ThemePreset(
    id: 'baraka_gold',
    nameAr: '\u0630\u0647\u0628\u064a \u0627\u0644\u0628\u0631\u0643\u0629',
    emoji: '\u{1F7E0}',
    lightPrimary: Color(0xFFF39C12),
    lightSecondary: Color(0xFFE67E22),
    lightHeaderRow: Color(0xFFFFE0B2),
    darkPrimary: Color(0xFFF39C12),
    darkSecondary: Color(0xFFE67E22),
    darkHeaderRow: Color(0xFF5D4037),
  ),
  ThemePreset(
    id: 'emerald',
    nameAr: '\u0623\u062e\u0636\u0631 \u0632\u0645\u0631\u062f\u064a',
    emoji: '\u{1F7E2}',
    lightPrimary: Color(0xFF1B5E20),
    lightSecondary: Color(0xFFFFB300),
    lightHeaderRow: Color(0xFFC8E6C9),
    darkPrimary: Color(0xFF2E7D32),
    darkSecondary: Color(0xFFFFB300),
    darkHeaderRow: Color(0xFF1B5E20),
  ),
  ThemePreset(
    id: 'royal_blue',
    nameAr: '\u0623\u0632\u0631\u0642 \u0645\u0644\u0643\u064a',
    emoji: '\u{1F535}',
    lightPrimary: Color(0xFF1E3A8A),
    lightSecondary: Color(0xFFF39C12),
    lightHeaderRow: Color(0xFFBBDEFB),
    darkPrimary: Color(0xFF3F51B5),
    darkSecondary: Color(0xFFF39C12),
    darkHeaderRow: Color(0xFF1A237E),
  ),
  ThemePreset(
    id: 'charcoal',
    nameAr: '\u0631\u0645\u0627\u062f\u064a \u0623\u0646\u064a\u0642',
    emoji: '\u26AB',
    lightPrimary: Color(0xFF37474F),
    lightSecondary: Color(0xFFFFB300),
    lightHeaderRow: Color(0xFFCFD8DC),
    darkPrimary: Color(0xFF546E7A),
    darkSecondary: Color(0xFFFFB300),
    darkHeaderRow: Color(0xFF263238),
  ),
  ThemePreset(
    id: 'royal_purple',
    nameAr: '\u0628\u0646\u0641\u0633\u062c\u064a \u0645\u0644\u0643\u064a',
    emoji: '\u{1F7E3}',
    lightPrimary: Color(0xFF6A1B9A),
    lightSecondary: Color(0xFFFFB300),
    lightHeaderRow: Color(0xFFE1BEE7),
    darkPrimary: Color(0xFF8E24AA),
    darkSecondary: Color(0xFFFFB300),
    darkHeaderRow: Color(0xFF4A148C),
  ),
  ThemePreset(
    id: 'sky',
    nameAr: '\u0633\u0645\u0627\u0648\u064a',
    emoji: '\u{1F537}',
    lightPrimary: Color(0xFF0277BD),
    lightSecondary: Color(0xFFFFB300),
    lightHeaderRow: Color(0xFFB3E5FC),
    darkPrimary: Color(0xFF039BE5),
    darkSecondary: Color(0xFFFFB300),
    darkHeaderRow: Color(0xFF01579B),
  ),
];

/// Default theme id - emerald green
const String kDefaultThemeId = 'emerald';

ThemePreset _byId(String id) =>
    kThemePresets.firstWhere((p) => p.id == id);

ThemePreset presetById(String? id) {
  if (id == null) return presetById(kDefaultThemeId);
  return kThemePresets.firstWhere(
    (p) => p.id == id,
    orElse: () => _byId(kDefaultThemeId),
  );
}

ThemePreset makeCustomPreset(Color seed) {
  return ThemePreset(
    id: 'custom',
    nameAr: '\u0645\u062e\u0635\u0635',
    emoji: '\u{1F3A8}',
    lightPrimary: seed,
    lightSecondary: Color.lerp(seed, Colors.black, 0.2)!,
    lightHeaderRow: Color.lerp(seed, Colors.white, 0.7)!,
    darkPrimary: seed,
    darkSecondary: Color.lerp(seed, Colors.white, 0.15)!,
    darkHeaderRow: Color.lerp(seed, Colors.black, 0.5)!,
  );
}