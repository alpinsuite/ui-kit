import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateFocusable', () {
    testWidgets('Tab reaches a button, and Enter presses it', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(SlateButton(label: 'Save', onPressed: () => taps++)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('Space presses it too', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(SlateButton(label: 'Save', onPressed: () => taps++)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('a disabled control is not a tab stop', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SlateButton(label: 'Disabled', onPressed: null),
              SlateButton(label: 'Enabled', onPressed: () => taps++),
            ],
          ),
        ),
      );

      // One Tab, not two: landing on something that cannot be activated is a
      // dead end the reader has to tab out of.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('the ring costs no space', (tester) async {
      const theme = SlateThemeData.dark();
      await tester.pumpWidget(
        wrap(
          SlateButton(label: 'Save', onPressed: () {}),
          theme: theme,
        ),
      );
      // Measured against the metric, not against itself unfocused. Focused
      // and unfocused agree under every implementation tried here, including
      // one that made the button permanently two pixels taller than
      // `SlateMetrics` says — the comparison that catches that is against the
      // number, and rule 4 is the reason it matters.
      final expected = theme.metrics.buttonHeight;
      expect(tester.getSize(find.byType(SlateButton)).height, expected);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(SlateButton)).height, expected);
    });

    testWidgets('a stretched control still fills the width it was given', (
      tester,
    ) async {
      // **The regression this exists for.** A `Stack` loosens the constraints
      // it hands its children, so wrapping every control in one made each of
      // them shrink to its natural size inside whatever width its parent had
      // stretched it to. Nothing looked broken in the kit's own tests, where a
      // control is pumped on its own and its natural size *is* its width — it
      // only showed in an application, as a select in a dialog row that had
      // stopped opening, because the click landed in the inert gap beside the
      // control rather than on it.
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 400,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SlateButton(label: 'Save', onPressed: () {}),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SlateButton)).width, 400);

      // And the press still lands at the centre of that width, which is the
      // half of it a size assertion alone would miss.
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 400,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SlateButton(
                    label: 'Save',
                    onPressed: () => pressed = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(SlateButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('an icon button is reachable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          SlateIconButton(
            icon: SlateIcons.close,
            tooltip: 'Close',
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });

  group('the rest of the controls', () {
    /// Tab once, then Enter. Every control in the kit should answer this.
    Future<void> tabAndPress(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
    }

    testWidgets('a tick box ticks', (tester) async {
      var value = false;
      await tester.pumpWidget(
        wrap(
          SlateCheckbox(
            value: value,
            label: 'Wrap lines',
            onChanged: (bool v) => value = v,
          ),
        ),
      );

      await tabAndPress(tester);
      expect(value, isTrue);
    });

    testWidgets('a segment selects', (tester) async {
      var picked = '';
      await tester.pumpWidget(
        wrap(
          SlateSegmented<String>(
            value: 'left',
            values: const <String>['left', 'right'],
            labelOf: (String v) => v,
            onChanged: (String v) => picked = v,
          ),
        ),
      );

      // Two tabs: each segment is its own stop, so the first Tab lands on the
      // one already selected.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tabAndPress(tester);
      expect(picked, 'right');
    });

    testWidgets('a select opens', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateSelect<String>(
            value: 'Round',
            values: const <String>['Round', 'Square'],
            labelOf: (String v) => v,
            onChanged: (String _) {},
          ),
        ),
      );
      expect(find.text('Square'), findsNothing);

      await tabAndPress(tester);

      // The panel is a `MenuAnchor`, whose own rows Flutter already traverses.
      // Reaching the trigger is the part that was missing.
      expect(find.text('Square'), findsOneWidget);
    });

    testWidgets('a tab selects', (tester) async {
      var selected = '';
      await tester.pumpWidget(
        wrap(
          SlateTabStrip(
            tabs: const <SlateTab>[
              SlateTab(id: 'a', label: 'one.pdf'),
              SlateTab(id: 'b', label: 'two.pdf'),
            ],
            selectedId: 'a',
            onSelected: (String id) => selected = id,
          ),
        ),
      );

      // The second, not the first: reaching a tab that is already selected
      // would prove nothing about whether the keyboard moved at all.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tabAndPress(tester);
      expect(selected, 'b');
    });

    testWidgets('a status item fires, and a plain one is skipped', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        wrap(
          SlateStatusBar(
            leading: const <Widget>[SlateStatusItem(label: '128 rows')],
            trailing: <Widget>[
              SlateStatusItem(label: '3 problems', onPressed: () => pressed++),
            ],
          ),
        ),
      );

      // "128 rows" says something; it does not do anything, and a tab stop on
      // it would be a stop with nothing behind it.
      await tabAndPress(tester);
      expect(pressed, 1);
    });
  });

  group('SlateActivityBar', () {
    testWidgets('every destination is a tab stop', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            height: 400,
            child: SlateActivityBar(
              items: const <SlateActivityItem>[
                SlateActivityItem(icon: SlateIcons.envelope, tooltip: 'Mail'),
                SlateActivityItem(icon: SlateIcons.calendar, tooltip: 'Diary'),
              ],
              selectedIndex: 0,
              onSelected: (int i) => selected = i,
            ),
          ),
        ),
      );

      // Two tabs to reach the second: a rail is a handful of destinations and
      // the whole top level of the window, so each one is worth a stop.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, 1);
    });
  });

  group('SlateTreeRow', () {
    testWidgets('is not a tab stop unless asked', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SlateTreeRow(
                depth: 0,
                onTap: () => taps++,
                child: const Text('Inbox'),
              ),
              SlateButton(label: 'After', onPressed: () => taps += 100),
            ],
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // The button, not the row: four hundred rows would otherwise be four
      // hundred stops between the tree and anything after it.
      expect(taps, 100);
    });

    testWidgets('the nominated row is', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SlateTreeRow(
                depth: 0,
                focusable: true,
                onTap: () => taps++,
                child: const Text('Inbox'),
              ),
              SlateButton(label: 'After', onPressed: () => taps += 100),
            ],
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });
}
