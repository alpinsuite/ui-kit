import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateSplitButton', () {
    Widget build({
      VoidCallback? onPressed,
      List<Widget>? menuChildren,
      String tooltip = 'Paste',
      String? menuTooltip,
    }) => wrap(
      SlateSplitButton(
        icon: SlateIcons.paste,
        tooltip: tooltip,
        menuTooltip: menuTooltip,
        onPressed: onPressed,
        menuChildren:
            menuChildren ??
            <Widget>[
              SlateButton(label: 'Values', onPressed: () {}),
              SlateButton(label: 'Formats', onPressed: () {}),
            ],
      ),
    );

    testWidgets('the action half presses without opening the list', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(build(onPressed: () => taps++));

      await tester.tap(find.byType(SlateIcon).first);
      await tester.pumpAndSettle();

      expect(taps, 1);
      // The whole point of a split button: the common case costs one click and
      // never shows the list.
      expect(find.text('Values'), findsNothing);
    });

    testWidgets('the chevron opens the list without firing the action', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(build(onPressed: () => taps++));

      await tester.tap(find.byType(SlateIcon).last);
      await tester.pumpAndSettle();

      expect(taps, 0);
      expect(find.text('Values'), findsOneWidget);
      expect(find.text('Formats'), findsOneWidget);
    });

    testWidgets('a disabled action still opens its list', (tester) async {
      // A paste button with an empty clipboard has nothing to paste and still
      // has alternatives worth reading, so the halves disable separately.
      await tester.pumpWidget(build(onPressed: null));

      await tester.tap(find.byType(SlateIcon).last);
      await tester.pumpAndSettle();

      expect(find.text('Values'), findsOneWidget);
    });

    testWidgets('an empty list draws no chevron at all', (tester) async {
      await tester.pumpWidget(build(onPressed: () {}));
      expect(find.byType(SlateIcon), findsNWidgets(2));

      var taps = 0;
      await tester.pumpWidget(
        build(onPressed: () => taps++, menuChildren: const <Widget>[]),
      );

      // The action's glyph and nothing else: a chevron with nothing behind it
      // is a claim about what is there, and disabling it is not enough --
      // `border` on `chrome` reads as a rendering fault, and `inkDim` looks
      // live.
      expect(find.byType(SlateIcon), findsOneWidget);

      // And it still works as a plain button, which is what it now is.
      await tester.tap(find.byType(SlateIcon));
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tab reaches both halves', (tester) async {
      var taps = 0;
      await tester.pumpWidget(build(onPressed: () => taps++));

      // First stop is the action.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);

      // Second is the chevron, and it opens rather than pressing again.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('Values'), findsOneWidget);
    });

    testWidgets('stretched, it still fills its width and presses at centre', (
      tester,
    ) async {
      // The regression `SlateFocusable` shipped once: a `Stack` loosens its
      // children's constraints, so a wrapped control shrinks inside the box its
      // parent gave it and the gap beside it swallows clicks. Pressed at the
      // centre, not merely measured -- a size assertion alone passed while the
      // hit region was dead.
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 300,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SlateSplitButton(
                    icon: SlateIcons.paste,
                    tooltip: 'Paste',
                    onPressed: () => taps++,
                    menuChildren: <Widget>[
                      SlateButton(label: 'Values', onPressed: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SlateIcon).first);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('the chevron falls back to the action tooltip', (tester) async {
      await tester.pumpWidget(build(onPressed: () {}, tooltip: 'Paste'));

      // Both halves say something. A tooltip that says nothing is worse than
      // one that repeats.
      expect(find.byType(Tooltip), findsNWidgets(2));
      for (final Tooltip tip in tester.widgetList<Tooltip>(
        find.byType(Tooltip),
      )) {
        expect(tip.message, 'Paste');
      }
    });

    testWidgets('a menu tooltip is used when one is given', (tester) async {
      await tester.pumpWidget(
        build(onPressed: () {}, tooltip: 'Paste', menuTooltip: 'Paste Special'),
      );

      final List<String?> messages = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((Tooltip t) => t.message)
          .toList();
      expect(messages, containsAll(<String>['Paste', 'Paste Special']));
    });
  });
}
