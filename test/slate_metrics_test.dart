import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

void main() {
  group('SlateMetrics', () {
    test('the standard metrics are the default constructor', () {
      const custom = SlateMetrics();
      expect(SlateMetrics.standard.rowHeight, custom.rowHeight);
      expect(SlateMetrics.standard.fontSize, custom.fontSize);
      expect(SlateMetrics.standard.iconSize, custom.iconSize);
    });

    test('scaled() multiplies every size', () {
      final big = SlateMetrics.standard.scaled(2);
      expect(big.rowHeight, SlateMetrics.standard.rowHeight * 2);
      expect(big.compactRowHeight, SlateMetrics.standard.compactRowHeight * 2);
      expect(big.controlHeight, SlateMetrics.standard.controlHeight * 2);
      expect(big.fieldHeight, SlateMetrics.standard.fieldHeight * 2);
      expect(big.buttonHeight, SlateMetrics.standard.buttonHeight * 2);
      expect(big.barHeight, SlateMetrics.standard.barHeight * 2);
      expect(big.windowBarHeight, SlateMetrics.standard.windowBarHeight * 2);
      expect(big.fontSize, SlateMetrics.standard.fontSize * 2);
      expect(big.smallFontSize, SlateMetrics.standard.smallFontSize * 2);
      expect(big.iconSize, SlateMetrics.standard.iconSize * 2);
      expect(big.gap, SlateMetrics.standard.gap * 2);
      expect(big.pad, SlateMetrics.standard.pad * 2);
    });

    test('scaled() leaves the corner radii alone', () {
      // A corner radius is a constant of the visual language, not a size.
      // Scaling it turns a denser build into a differently-shaped one.
      final big = SlateMetrics.standard.scaled(2);
      expect(big.radius, SlateMetrics.standard.radius);
      expect(big.popoverRadius, SlateMetrics.standard.popoverRadius);
    });

    test('scaled(1) is a no-op', () {
      final same = SlateMetrics.standard.scaled(1);
      expect(same.rowHeight, SlateMetrics.standard.rowHeight);
      expect(same.pad, SlateMetrics.standard.pad);
    });

    test('a menu row is taller than a value row', () {
      // A command carries a shortcut; a value does not, and paying for the
      // shortcut's height in a value list is what makes dropdowns loose.
      expect(
        SlateMetrics.standard.rowHeight,
        greaterThan(SlateMetrics.standard.compactRowHeight),
      );
    });

    test('small type is smaller than body type', () {
      expect(
        SlateMetrics.standard.smallFontSize,
        lessThan(SlateMetrics.standard.fontSize),
      );
    });
  });
}
