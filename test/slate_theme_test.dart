import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

void main() {
  group('SlateThemeData', () {
    test('the named constructors pick the matching palette', () {
      expect(const SlateThemeData.dark().palette, SlatePalette.dark);
      expect(const SlateThemeData.light().palette, SlatePalette.light);
    });

    test('the named constructors accept custom metrics', () {
      final metrics = SlateMetrics.standard.scaled(1.25);
      final theme = SlateThemeData.dark(metrics: metrics);
      expect(theme.metrics.rowHeight, metrics.rowHeight);
    });

    test('text styles take their colour and size from the theme', () {
      const theme = SlateThemeData.dark();
      expect(theme.textStyle.color, theme.palette.ink);
      expect(theme.textStyle.fontSize, theme.metrics.fontSize);
      expect(theme.dimTextStyle.color, theme.palette.inkDim);
      expect(theme.dimTextStyle.fontSize, theme.metrics.smallFontSize);
    });

    test('the title style differs by weight, not size', () {
      // Keeping one type scale is what stops a dense interface sprouting a
      // second one.
      const theme = SlateThemeData.dark();
      expect(theme.titleStyle.fontSize, theme.textStyle.fontSize);
      expect(theme.titleStyle.fontWeight, FontWeight.w600);
    });

    test('chrome text is not given the ambient reading line height', () {
      const theme = SlateThemeData.dark();
      expect(theme.textStyle.height, 1.3);
    });

    test('the popover decoration carries the border and the shadow', () {
      const theme = SlateThemeData.dark();
      final decoration = theme.popoverDecoration;
      expect(decoration.color, theme.palette.popover);
      expect(decoration.boxShadow, isNotEmpty);
      expect(decoration.boxShadow!.first.color, theme.palette.shadow);
    });

    group('toMaterialTheme', () {
      test('maps the palette onto the colour scheme', () {
        const theme = SlateThemeData.dark();
        final material = theme.toMaterialTheme();

        expect(material.colorScheme.primary, theme.palette.accent);
        expect(material.colorScheme.onPrimary, theme.palette.onAccent);
        expect(material.colorScheme.surface, theme.palette.background);
        expect(material.colorScheme.error, theme.palette.danger);
        expect(material.scaffoldBackgroundColor, theme.palette.background);
      });

      test('carries the brightness through', () {
        expect(
          const SlateThemeData.dark().toMaterialTheme().colorScheme.brightness,
          Brightness.dark,
        );
        expect(
          const SlateThemeData.light().toMaterialTheme().colorScheme.brightness,
          Brightness.light,
        );
      });

      test('every text style arrives with a colour', () {
        // ThemeData normally merges geometry and colour by brightness. Skipping
        // that merge leaves the whole text theme colourless, which is invisible
        // until something renders on an unexpected background.
        for (final theme in <SlateThemeData>[
          const SlateThemeData.dark(),
          const SlateThemeData.light(),
        ]) {
          final text = theme.toMaterialTheme().textTheme;
          expect(text.bodyMedium?.color, isNotNull);
          expect(text.titleMedium?.color, isNotNull);
          expect(text.labelSmall?.color, isNotNull);
        }
      });

      test('text selection is drawn in the accent', () {
        const theme = SlateThemeData.light();
        final selection = theme.toMaterialTheme().textSelectionTheme;
        expect(selection.cursorColor, theme.palette.accent);
        expect(selection.selectionHandleColor, theme.palette.accent);
      });
    });
  });

  group('SlateTheme', () {
    testWidgets('hands the data to the widgets below it', (tester) async {
      const theme = SlateThemeData.light();
      late SlateThemeData seen;

      await tester.pumpWidget(
        SlateTheme(
          data: theme,
          child: Builder(
            builder: (context) {
              seen = context.slate;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seen.palette, SlatePalette.light);
    });

    testWidgets('falls back to the dark palette rather than throwing', (
      tester,
    ) async {
      late SlateThemeData seen;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            seen = SlateTheme.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(seen.palette, SlatePalette.dark);
    });

    testWidgets('the context extensions read the same theme', (tester) async {
      const theme = SlateThemeData.light();
      late SlatePalette palette;
      late SlateMetrics metrics;

      await tester.pumpWidget(
        SlateTheme(
          data: theme,
          child: Builder(
            builder: (context) {
              palette = context.slateColors;
              metrics = context.slateMetrics;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(palette, SlatePalette.light);
      expect(metrics.rowHeight, SlateMetrics.standard.rowHeight);
    });

    testWidgets('a changed theme rebuilds its dependents', (tester) async {
      Widget build(SlateThemeData data) => SlateTheme(
        data: data,
        child: Builder(
          builder: (context) =>
              ColoredBox(color: context.slateColors.background),
        ),
      );

      await tester.pumpWidget(build(const SlateThemeData.dark()));
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        SlatePalette.dark.background,
      );

      await tester.pumpWidget(build(const SlateThemeData.light()));
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        SlatePalette.light.background,
      );
    });
  });
}
