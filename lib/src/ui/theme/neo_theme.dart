import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'neo_theme.tailor.dart';

@TailorMixin()
class NeoTheme extends ThemeExtension<NeoTheme> with _$NeoThemeTailorMixin {
  const NeoTheme({
    required this.editorBg,
    required this.sidebarBg,
    required this.dividerColor,
    required this.accentColor,
    required this.hoverBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.titleBarBg,
  });

  final Color editorBg;
  final Color sidebarBg;
  final Color dividerColor;
  final Color accentColor;
  final Color hoverBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color titleBarBg;

  static const dark = NeoTheme(
    editorBg: Color(0xFF0D1117),
    sidebarBg: Color(0xFF010409),
    dividerColor: Color(0xFF21262D),
    accentColor: Color(0xFF58A6FF),
    hoverBg: Color(0xFF161B22),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF8B949E),
    titleBarBg: Color(0xFF010409),
  );
}
