import 'dart:ui' show Brightness, Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

void main() {
  group('SlatePalette', () {
    test('reports its own brightness', () {
      expect(SlatePalette.dark.isDark, isTrue);
      expect(SlatePalette.light.isDark, isFalse);
      expect(SlatePalette.dark.brightness, Brightness.dark);
      expect(SlatePalette.light.brightness, Brightness.light);
    });

    test('copyWith replaces the accent and leaves every other role alone', () {
      const accent = Color(0xFF3B82F6);
      final recoloured = SlatePalette.dark.copyWith(accent: accent);

      expect(recoloured.accent, accent);
      expect(recoloured.background, SlatePalette.dark.background);
      expect(recoloured.chrome, SlatePalette.dark.chrome);
      expect(recoloured.popover, SlatePalette.dark.popover);
      expect(recoloured.ink, SlatePalette.dark.ink);
      expect(recoloured.field, SlatePalette.dark.field);
      expect(recoloured.danger, SlatePalette.dark.danger);
      expect(recoloured.brightness, SlatePalette.dark.brightness);
    });

    test('copyWith with no arguments changes nothing', () {
      final same = SlatePalette.light.copyWith();
      expect(same.accent, SlatePalette.light.accent);
      expect(same.onAccent, SlatePalette.light.onAccent);
      expect(same.brightness, SlatePalette.light.brightness);
    });

    test('the two palettes differ in every structural role', () {
      // A light palette that shares a surface colour with the dark one is a
      // palette that was half filled in.
      expect(
        SlatePalette.dark.background,
        isNot(SlatePalette.light.background),
      );
      expect(SlatePalette.dark.chrome, isNot(SlatePalette.light.chrome));
      expect(SlatePalette.dark.popover, isNot(SlatePalette.light.popover));
      expect(SlatePalette.dark.ink, isNot(SlatePalette.light.ink));
      expect(SlatePalette.dark.border, isNot(SlatePalette.light.border));
    });

    test('the separator is quieter than the border it sits next to', () {
      // The design leans on this: rules between rows must not read as the
      // structural edge of a popover.
      double luminance(Color c) => c.computeLuminance();
      expect(
        luminance(SlatePalette.dark.separator),
        lessThan(luminance(SlatePalette.dark.border)),
      );
      expect(
        luminance(SlatePalette.light.separator),
        greaterThan(luminance(SlatePalette.light.border)),
      );
    });
  });
}
