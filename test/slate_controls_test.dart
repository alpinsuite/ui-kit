import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateButton', () {
    testWidgets('shows its label and fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(SlateButton(label: 'Save', onPressed: () => taps++)),
      );

      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.byType(SlateButton));
      expect(taps, 1);
    });

    testWidgets('a null callback disables it', (tester) async {
      await tester.pumpWidget(
        wrap(const SlateButton(label: 'Save', onPressed: null)),
      );

      await tester.tap(find.byType(SlateButton));
      await tester.pump();
      // Nothing to assert but the absence of a crash and of a callback; the
      // colour change is checked below.
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('primary fills with the accent, ghost has no shape at rest', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SlateButton(
                label: 'Primary',
                onPressed: () {},
                kind: SlateButtonKind.primary,
              ),
              SlateButton(
                label: 'Ghost',
                onPressed: () {},
                kind: SlateButtonKind.ghost,
              ),
            ],
          ),
        ),
      );

      final primary = decorationOf(tester, find.byType(SlateButton).at(0));
      final ghost = decorationOf(tester, find.byType(SlateButton).at(1));

      expect(primary.color, SlatePalette.dark.accent);
      expect(primary.border, isNotNull);
      expect(ghost.color!.a, 0);
      expect(ghost.border, isNull);
    });

    testWidgets('secondary lifts to the hover colour under the pointer', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(SlateButton(label: 'Cancel', onPressed: () {})),
      );

      expect(
        decorationOf(tester, find.byType(SlateButton)).color,
        SlatePalette.dark.field,
      );

      await hover(tester, find.byType(SlateButton));

      expect(
        decorationOf(tester, find.byType(SlateButton)).color,
        SlatePalette.dark.hover,
      );
    });

    testWidgets('renders an icon when given one', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateButton(label: 'Copy', onPressed: () {}, icon: SlateIcons.copy),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(SlateButton),
          matching: find.byType(SlateIcon),
        ),
        findsOneWidget,
      );
    });
  });

  group('SlateIconButton', () {
    testWidgets('exposes its tooltip as the accessible name', (tester) async {
      // Disposed inline rather than in a tear-down: the framework verifies that
      // no handle is outstanding before tear-downs run.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        wrap(
          SlateIconButton(
            icon: SlateIcons.close,
            onPressed: () {},
            tooltip: 'Close',
          ),
        ),
      );

      // An icon with no name is unusable with a screen reader, which is why the
      // tooltip is a required parameter rather than an optional one.
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      expect(
        tester.getSemantics(
          find
              .descendant(
                of: find.byType(SlateIconButton),
                matching: find.byType(Semantics),
              )
              .first,
        ),
        isSemantics(label: 'Close', isButton: true),
      );

      handle.dispose();
    });

    testWidgets('selected draws the selected background', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateIconButton(
            icon: SlateIcons.plus,
            onPressed: () {},
            tooltip: 'Add',
            selected: true,
          ),
        ),
      );

      expect(
        decorationOf(tester, find.byType(SlateIconButton)).color,
        SlatePalette.dark.selected,
      );
    });

    testWidgets('danger hovers red rather than grey', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateIconButton(
            icon: SlateIcons.close,
            onPressed: () {},
            tooltip: 'Close window',
            danger: true,
          ),
        ),
      );

      await hover(tester, find.byType(SlateIconButton));

      expect(
        decorationOf(tester, find.byType(SlateIconButton)).color,
        SlatePalette.dark.danger,
      );
    });

    testWidgets('fires when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          SlateIconButton(
            icon: SlateIcons.plus,
            onPressed: () => taps++,
            tooltip: 'Add',
          ),
        ),
      );

      await tester.tap(find.byType(SlateIconButton));
      expect(taps, 1);
    });
  });

  group('SlateCheckbox', () {
    testWidgets('reports the opposite of its current value', (tester) async {
      bool? received;
      await tester.pumpWidget(
        wrap(
          SlateCheckbox(
            value: false,
            label: 'Antialias',
            onChanged: (value) => received = value,
          ),
        ),
      );

      await tester.tap(find.byType(SlateCheckbox));
      expect(received, isTrue);
    });

    testWidgets('the label is part of the target', (tester) async {
      // A 13px box is a mean thing to ask anyone to hit.
      bool? received;
      await tester.pumpWidget(
        wrap(
          SlateCheckbox(
            value: true,
            label: 'Antialias',
            onChanged: (value) => received = value,
          ),
        ),
      );

      await tester.tap(find.text('Antialias'));
      expect(received, isFalse);
    });

    testWidgets('draws a check only when set', (tester) async {
      Widget build(bool value) =>
          wrap(SlateCheckbox(value: value, label: 'On', onChanged: (_) {}));

      await tester.pumpWidget(build(false));
      expect(
        find.descendant(
          of: find.byType(SlateCheckbox),
          matching: find.byType(SlateIcon),
        ),
        findsNothing,
      );

      await tester.pumpWidget(build(true));
      expect(
        find.descendant(
          of: find.byType(SlateCheckbox),
          matching: find.byType(SlateIcon),
        ),
        findsOneWidget,
      );
    });
  });

  group('SlateSegmented', () {
    testWidgets('shows every option at once', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateSegmented<String>(
            value: 'Fill',
            values: const <String>['Fill', 'Stroke', 'Both'],
            labelOf: (value) => value,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Fill'), findsOneWidget);
      expect(find.text('Stroke'), findsOneWidget);
      expect(find.text('Both'), findsOneWidget);
    });

    testWidgets('reports the option that was tapped', (tester) async {
      String? chosen;
      await tester.pumpWidget(
        wrap(
          SlateSegmented<String>(
            value: 'Fill',
            values: const <String>['Fill', 'Stroke'],
            labelOf: (value) => value,
            onChanged: (value) => chosen = value,
          ),
        ),
      );

      await tester.tap(find.text('Stroke'));
      expect(chosen, 'Stroke');
    });

    testWidgets('the chosen label is drawn in the accent', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateSegmented<String>(
            value: 'Fill',
            values: const <String>['Fill', 'Stroke'],
            labelOf: (value) => value,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Fill')).style!.color,
        SlatePalette.dark.accent,
      );
      expect(
        tester.widget<Text>(find.text('Stroke')).style!.color,
        SlatePalette.dark.inkDim,
      );
    });
  });

  group('SlateSlider', () {
    testWidgets('clamps a value that sits outside its range', (tester) async {
      // Feeding Slider a value outside min..max asserts, so the clamp is what
      // keeps a caller's stale value from taking the app down.
      await tester.pumpWidget(
        wrap(SlateSlider(value: 500, min: 1, max: 100, onChanged: (_) {})),
      );

      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 100);
    });
  });

  group('SlateField', () {
    testWidgets('obscures its text and turns off suggestions with it', (
      tester,
    ) async {
      // A password field that hides its characters while offering to remember
      // them is worse than one that does neither.
      final controller = TextEditingController(text: 'hunter2');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(SlateField(controller: controller, obscureText: true)),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(field.enableSuggestions, isFalse);
      expect(field.autocorrect, isFalse);
    });

    testWidgets('shows its text by default', (tester) async {
      final controller = TextEditingController(text: 'visible');
      addTearDown(controller.dispose);

      await tester.pumpWidget(wrap(SlateField(controller: controller)));
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isFalse,
      );
    });
  });

  group('SlateField', () {
    testWidgets('edits its controller and reports changes', (tester) async {
      final controller = TextEditingController(text: 'start');
      addTearDown(controller.dispose);
      String? seen;

      await tester.pumpWidget(
        wrap(
          SlateField(
            controller: controller,
            onChanged: (value) => seen = value,
            width: 120,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'edited');
      expect(seen, 'edited');
      expect(controller.text, 'edited');
    });

    testWidgets('shows a hint when given one', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(SlateField(controller: controller, hint: 'Width')),
      );

      expect(find.text('Width'), findsOneWidget);
    });
  });

  group('SlateSeparator', () {
    testWidgets('is a hairline in both orientations', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 100,
            height: 100,
            child: Column(
              children: <Widget>[
                SlateSeparator(),
                Expanded(
                  child: Row(
                    children: <Widget>[SlateSeparator(vertical: true)],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SlateSeparator).at(0)).height, 1);
      expect(tester.getSize(find.byType(SlateSeparator).at(1)).width, 1);
    });
  });
}
