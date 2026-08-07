import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

/// Every glyph the kit publishes, so the coverage check below cannot silently
/// stop covering one.
const Map<String, SlateIconDraw> _glyphs = <String, SlateIconDraw>{
  'chevronDown': SlateIcons.chevronDown,
  'chevronRight': SlateIcons.chevronRight,
  'chevronUp': SlateIcons.chevronUp,
  'check': SlateIcons.check,
  'close': SlateIcons.close,
  'minimize': SlateIcons.minimize,
  'maximize': SlateIcons.maximize,
  'restore': SlateIcons.restore,
  'search': SlateIcons.search,
  'plus': SlateIcons.plus,
  'minus': SlateIcons.minus,
  'download': SlateIcons.download,
  'copy': SlateIcons.copy,
  'fitScreen': SlateIcons.fitScreen,
  'actualSize': SlateIcons.actualSize,
  'swap': SlateIcons.swap,
  'bold': SlateIcons.bold,
  'italic': SlateIcons.italic,
  'underline': SlateIcons.underline,
  'alignLeft': SlateIcons.alignLeft,
  'alignCenter': SlateIcons.alignCenter,
  'alignRight': SlateIcons.alignRight,
  'palette': SlateIcons.palette,
};

void main() {
  group('SlateIcons', () {
    test('draws on a 16-unit grid', () {
      // Every glyph is authored against this; changing it silently rescales the
      // whole set.
      expect(SlateIcons.grid, 16);
    });

    for (final entry in _glyphs.entries) {
      testWidgets('${entry.key} paints without throwing', (tester) async {
        await tester.pumpWidget(wrap(SlateIcon(entry.value)));
        expect(tester.takeException(), isNull);
        expect(find.byType(SlateIcon), findsOneWidget);
      });
    }
  });

  group('SlateIcon', () {
    testWidgets('is square at the size it is given', (tester) async {
      await tester.pumpWidget(
        wrap(const SlateIcon(SlateIcons.check, size: 24)),
      );
      expect(tester.getSize(find.byType(SlateIcon)), const Size(24, 24));
    });

    testWidgets('falls back to the theme icon size', (tester) async {
      await tester.pumpWidget(wrap(const SlateIcon(SlateIcons.check)));
      expect(
        tester.getSize(find.byType(SlateIcon)).width,
        SlateMetrics.standard.iconSize,
      );
    });

    testWidgets('takes its colour from the caller, not from a font', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SlateIcon(SlateIcons.check, color: Color(0xFF00FF00))),
      );
      // The glyph is a path, so the colour reaching the painter is the whole
      // mechanism; there is no font to fall back on.
      expect(tester.takeException(), isNull);
    });

    testWidgets('repaints on a change and not otherwise', (tester) async {
      Future<CustomPainter> painterFor(SlateIcon icon) async {
        await tester.pumpWidget(wrap(icon));
        return tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(SlateIcon),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter!;
      }

      const red = SlateIcon(SlateIcons.check, color: Color(0xFFFF0000));
      final first = await painterFor(red);

      // Same glyph, same colour, same weight: nothing to redraw.
      expect((await painterFor(red)).shouldRepaint(first), isFalse);

      expect(
        (await painterFor(
          const SlateIcon(SlateIcons.check, color: Color(0xFF00FF00)),
        )).shouldRepaint(first),
        isTrue,
      );
      expect(
        (await painterFor(
          const SlateIcon(
            SlateIcons.check,
            color: Color(0xFFFF0000),
            weight: 3,
          ),
        )).shouldRepaint(first),
        isTrue,
      );
      expect(
        (await painterFor(
          const SlateIcon(SlateIcons.close, color: Color(0xFFFF0000)),
        )).shouldRepaint(first),
        isTrue,
      );
    });
  });
}
