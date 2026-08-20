import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateSwatches', () {
    test('every tint row has one entry per hue', () {
      for (final row in SlateSwatches.tints) {
        expect(row, hasLength(SlateSwatches.hues.length));
      }
    });

    test('the middle row is the hues themselves, untouched', () {
      // The grid has to contain the base colours exactly, or picking "red"
      // from it gives something that is nearly red and never matches again.
      final mid = SlateSwatches.tints[SlateSwatches.tints.length ~/ 2];
      expect(mid, equals(SlateSwatches.hues));
    });

    test('rows run light to dark', () {
      double lightness(Color c) => c.r + c.g + c.b;
      final column = SlateSwatches.tints.map((row) => row[0]).toList();
      for (var i = 1; i < column.length; i++) {
        expect(
          lightness(column[i]),
          lessThan(lightness(column[i - 1])),
          reason: 'row $i is not darker than row ${i - 1}',
        );
      }
    });

    test('lightening keeps a colour inside the channel range', () {
      for (final row in SlateSwatches.tints) {
        for (final color in row) {
          expect(color.r, inInclusiveRange(0, 1));
          expect(color.g, inInclusiveRange(0, 1));
          expect(color.b, inInclusiveRange(0, 1));
        }
      }
    });
  });

  group('SlateColorPopover', () {
    testWidgets('picking a swatch reports that colour', (tester) async {
      Color? picked;
      await tester.pumpWidget(
        wrap(SlateColorPopover(onPicked: (color) => picked = color)),
      );

      // The first swatch of the greyscale row.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(picked, SlateSwatches.greys.first);
    });

    testWidgets('the no-colour row appears only when it can do something', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(SlateColorPopover(onPicked: (_) {})));
      expect(find.text('Automatic'), findsNothing);

      await tester.pumpWidget(
        wrap(
          SlateColorPopover(
            onPicked: (_) {},
            noColorLabel: 'Automatic',
            onNoColor: () {},
          ),
        ),
      );
      expect(find.text('Automatic'), findsOneWidget);
    });

    testWidgets('an empty recents list shows no heading', (tester) async {
      // A permanently empty "Recent" heading is a heading that teaches nothing.
      await tester.pumpWidget(
        wrap(SlateColorPopover(onPicked: (_) {}, recentsLabel: 'Recent')),
      );
      expect(find.text('Recent'), findsNothing);

      await tester.pumpWidget(
        wrap(
          SlateColorPopover(
            onPicked: (_) {},
            recentsLabel: 'Recent',
            recents: const <Color>[Color(0xFFFF0000)],
          ),
        ),
      );
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('a caller can replace the grid entirely', (tester) async {
      Color? picked;
      await tester.pumpWidget(
        wrap(
          SlateColorPopover(
            onPicked: (color) => picked = color,
            swatches: const <List<Color>>[
              <Color>[Color(0xFF112233), Color(0xFF445566)],
            ],
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(picked, const Color(0xFF112233));
    });
  });

  group('SlateColorButton', () {
    testWidgets('the swatch applies, the chevron opens', (tester) async {
      // The two halves are the whole point: one click to repeat a colour,
      // two only when a different one is wanted.
      var applied = 0;
      await tester.pumpWidget(
        wrap(
          SlateColorButton(
            icon: SlateIcons.fontColor,
            tooltip: 'Font colour',
            color: const Color(0xFFFF0000),
            onPressed: () => applied++,
            onPicked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(SlateIcon).first);
      await tester.pumpAndSettle();
      expect(applied, 1);
      expect(find.byType(SlateColorPopover), findsNothing);

      await tester.tap(find.byType(SlateIcon).last);
      await tester.pumpAndSettle();
      expect(find.byType(SlateColorPopover), findsOneWidget);
      expect(applied, 1, reason: 'opening the grid is not applying a colour');
    });

    testWidgets('picking from the grid closes it and reports', (tester) async {
      Color? picked;
      await tester.pumpWidget(
        wrap(
          SlateColorButton(
            icon: SlateIcons.highlight,
            tooltip: 'Highlight',
            color: null,
            onPressed: () {},
            onPicked: (color) => picked = color,
          ),
        ),
      );

      await tester.tap(find.byType(SlateIcon).last);
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(SlateColorPopover),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await tester.pumpAndSettle();

      expect(picked, SlateSwatches.greys.first);
      expect(find.byType(SlateColorPopover), findsNothing);
    });

    testWidgets('carries an explicit height', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateColorButton(
            icon: SlateIcons.fontColor,
            tooltip: 'Font colour',
            color: null,
            onPressed: () {},
            onPicked: (_) {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(SlateColorButton)).height,
        SlateMetrics.standard.controlHeight,
      );
    });
  });
}
