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

    group('reads, measured the way WCAG measures', () {
      double contrast(Color a, Color b) {
        final (x, y) = (a.computeLuminance(), b.computeLuminance());
        final (lighter, darker) = x > y ? (x, y) : (y, x);
        return (lighter + 0.05) / (darker + 0.05);
      }

      // Everything text is drawn on, including a hovered row and a chosen one:
      // a message does not stop needing to be read because a row is selected.
      Map<String, Color> surfaces(SlatePalette palette) => <String, Color>{
        'background': palette.background,
        'chrome': palette.chrome,
        'panel': palette.panel,
        'popover': palette.popover,
        'hover': palette.hover,
        'selected': palette.selected,
        'field': palette.field,
      };

      for (final palette in <SlatePalette>[
        SlatePalette.dark,
        SlatePalette.light,
      ]) {
        final name = palette.brightness.name;

        test('every text colour is 4.5:1 on every surface, $name', () {
          // ink, inkDim and danger are the colours text is drawn in. The accent
          // is not one of them, and is held to a glyph's 3:1 below instead.
          final roles = <String, Color>{
            'ink': palette.ink,
            'inkDim': palette.inkDim,
            'danger': palette.danger,
          };
          for (final role in roles.entries) {
            for (final surface in surfaces(palette).entries) {
              expect(
                contrast(role.value, surface.value),
                greaterThanOrEqualTo(4.5),
                reason: '${role.key} on ${surface.key}',
              );
            }
          }
          expect(
            contrast(palette.onAccent, palette.accent),
            greaterThanOrEqualTo(4.5),
            reason: 'a primary button\'s label on its fill',
          );
        });

        test('a glyph is 3:1 wherever the kit draws one, $name', () {
          for (final surface in surfaces(palette).entries) {
            expect(
              contrast(palette.accent, surface.value),
              greaterThanOrEqualTo(3),
              reason: 'the accent on ${surface.key}',
            );
          }
          // The close button's hover: a white cross on the danger fill. The
          // red that reads as text in the dark palette is only just dark
          // enough for this, which is why both are asserted together.
          expect(
            contrast(const Color(0xFFFFFFFF), palette.danger),
            greaterThanOrEqualTo(3),
            reason: 'white on danger',
          );
        });
      }
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
