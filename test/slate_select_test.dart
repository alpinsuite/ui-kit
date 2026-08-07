import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateSelect', () {
    Widget build({
      required ValueChanged<String> onChanged,
      String value = 'Round',
      double minWidth = 0,
    }) {
      return wrap(
        SlateSelect<String>(
          value: value,
          values: const <String>['Round', 'Square', 'Butt'],
          labelOf: (option) => option,
          onChanged: onChanged,
          minWidth: minWidth,
        ),
      );
    }

    testWidgets('reads as its value until it is opened', (tester) async {
      await tester.pumpWidget(build(onChanged: (_) {}));

      expect(find.text('Round'), findsOneWidget);
      expect(find.text('Square'), findsNothing);
    });

    testWidgets('has no box at rest and grows one on hover', (tester) async {
      // The whole point of the control: a bordered, filled box is a heavy shape
      // to put next to a label in a dense options row.
      await tester.pumpWidget(build(onChanged: (_) {}));

      final atRest = decorationOf(tester, find.byType(SlateSelect<String>));
      expect(atRest.color!.a, 0);
      expect(atRest.border, isNull);

      await hover(tester, find.byType(SlateSelect<String>));

      expect(
        decorationOf(tester, find.byType(SlateSelect<String>)).color,
        SlatePalette.dark.hover,
      );
    });

    testWidgets('lists its values when opened', (tester) async {
      await tester.pumpWidget(build(onChanged: (_) {}));

      await tester.tap(find.byType(SlateSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Square'), findsOneWidget);
      expect(find.text('Butt'), findsOneWidget);
      // The current value appears both in the trigger and in the list.
      expect(find.text('Round'), findsNWidgets(2));
    });

    testWidgets('reports the chosen value and closes', (tester) async {
      String? chosen;
      await tester.pumpWidget(build(onChanged: (value) => chosen = value));

      await tester.tap(find.byType(SlateSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Square'));
      await tester.pumpAndSettle();

      expect(chosen, 'Square');
      expect(find.text('Butt'), findsNothing);
    });

    testWidgets('ticks the current value in the list', (tester) async {
      await tester.pumpWidget(build(onChanged: (_) {}));

      await tester.tap(find.byType(SlateSelect<String>));
      await tester.pumpAndSettle();

      Finder rowFor(Finder label) =>
          find.ancestor(of: label, matching: find.byType(Container)).first;

      // The tick is on the current value's row and nowhere else. `.last` picks
      // the list row rather than the trigger, which shows the same text.
      expect(
        find.descendant(
          of: rowFor(find.text('Round').last),
          matching: find.byType(SlateIcon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowFor(find.text('Square')),
          matching: find.byType(SlateIcon),
        ),
        findsNothing,
      );
    });

    testWidgets('minWidth stops it jumping about as its value changes', (
      tester,
    ) async {
      await tester.pumpWidget(build(onChanged: (_) {}, minWidth: 140));

      expect(
        tester.getSize(find.byType(SlateSelect<String>)).width,
        greaterThanOrEqualTo(140),
      );
    });

    testWidgets('works with a non-string value type', (tester) async {
      int? chosen;
      await tester.pumpWidget(
        wrap(
          SlateSelect<int>(
            value: 1,
            values: const <int>[1, 2, 4],
            labelOf: (option) => '${option}px',
            onChanged: (value) => chosen = value,
          ),
        ),
      );

      await tester.tap(find.byType(SlateSelect<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4px'));
      await tester.pumpAndSettle();

      expect(chosen, 4);
    });
  });
}
