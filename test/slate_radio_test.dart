import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateRadioGroup', () {
    Widget build({
      String value = 'right',
      ValueChanged<String>? onChanged,
      bool Function(String)? enabledOf,
      List<String> values = const <String>['right', 'down', 'row', 'column'],
      Axis axis = Axis.vertical,
    }) => wrap(
      SlateRadioGroup<String>(
        value: value,
        values: values,
        labelOf: (String v) => v,
        onChanged: onChanged ?? (String _) {},
        enabledOf: enabledOf,
        axis: axis,
      ),
    );

    testWidgets('every choice is visible at once', (tester) async {
      await tester.pumpWidget(build());

      // The whole reason this exists rather than a SlateSelect: comparing four
      // options means reading four options.
      for (final String label in <String>['right', 'down', 'row', 'column']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('pressing one reports it', (tester) async {
      String? chosen;
      await tester.pumpWidget(build(onChanged: (String v) => chosen = v));

      await tester.tap(find.text('row'));
      await tester.pump();

      expect(chosen, 'row');
    });

    testWidgets('the label is part of the target', (tester) async {
      // A 13px circle is a mean thing to ask anyone to hit, so the text counts
      // as the button too.
      String? chosen;
      await tester.pumpWidget(build(onChanged: (String v) => chosen = v));

      await tester.tap(find.text('column'));
      await tester.pump();

      expect(chosen, 'column');
    });

    testWidgets('exactly one is marked, and it is the value given', (
      tester,
    ) async {
      await tester.pumpWidget(build(value: 'down'));

      // The dot is the inner circle; the ring is the outer. Counting decorated
      // circles finds four rings and one dot.
      final Iterable<Container> circles = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (Container c) =>
                c.decoration is BoxDecoration &&
                (c.decoration! as BoxDecoration).shape == BoxShape.circle,
          );
      final int dots = circles
          .where(
            (Container c) => (c.decoration! as BoxDecoration).border == null,
          )
          .length;
      expect(dots, 1);
    });

    testWidgets('a value not in the list selects nothing rather than throwing', (
      tester,
    ) async {
      // A dialog re-opened on a changed document is the case: the option it was
      // last answered with may be gone.
      await tester.pumpWidget(build(value: 'vanished'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a null handler disables the whole group', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateRadioGroup<String>(
            value: 'right',
            values: const <String>['right', 'down'],
            labelOf: (String v) => v,
            onChanged: null,
          ),
        ),
      );

      await tester.tap(find.text('down'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('one option can be disabled while the rest stay live', (
      tester,
    ) async {
      String? chosen;
      await tester.pumpWidget(
        build(
          onChanged: (String v) => chosen = v,
          enabledOf: (String v) => v != 'down',
        ),
      );

      // Disabled rather than absent: a choice that vanishes changes the shape
      // of the dialog between two openings of it.
      expect(find.text('down'), findsOneWidget);
      await tester.tap(find.text('down'));
      await tester.pump();
      expect(chosen, isNull);

      await tester.tap(find.text('row'));
      await tester.pump();
      expect(chosen, 'row');
    });

    testWidgets('Tab reaches each choice and Enter picks it', (tester) async {
      String? chosen;
      await tester.pumpWidget(
        build(
          values: const <String>['right', 'down'],
          onChanged: (String v) => chosen = v,
        ),
      );

      // Two tabs: the first lands on the one already chosen.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(chosen, 'down');
    });

    testWidgets('a disabled choice is not a tab stop', (tester) async {
      String? chosen;
      await tester.pumpWidget(
        build(
          values: const <String>['right', 'down', 'row'],
          onChanged: (String v) => chosen = v,
          enabledOf: (String v) => v != 'down',
        ),
      );

      // Two tabs would land on 'down' if it were a stop; it is not, so the
      // second reaches 'row'.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(chosen, 'row');
    });

    testWidgets('it lays out in a row when asked', (tester) async {
      await tester.pumpWidget(
        build(values: const <String>['a', 'b'], axis: Axis.horizontal),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });
  });
}
