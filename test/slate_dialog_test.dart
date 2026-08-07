import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateDialog', () {
    testWidgets('shows its title, body and actions', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateDialog(
            title: 'Resize Image',
            content: const Text('Body'),
            actions: <Widget>[
              SlateButton(label: 'Cancel', onPressed: () {}),
              SlateButton(
                label: 'Resize',
                onPressed: () {},
                kind: SlateButtonKind.primary,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Resize Image'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Resize'), findsOneWidget);
    });

    testWidgets('draws itself as a popover, not a Material card', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SlateDialog(
            title: 'Title',
            content: SizedBox(),
            actions: <Widget>[],
          ),
        ),
      );

      // The shape, border and shadow are a menu's, so the two do not read as
      // coming from different applications.
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.elevation, 0);
      expect(dialog.backgroundColor!.a, 0);

      final decoration = decorationOf(tester, find.byType(SlateDialog));
      expect(decoration.color, SlatePalette.dark.popover);
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('separates title and actions with hairlines', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateDialog(
            title: 'Title',
            content: const Text('Body'),
            actions: <Widget>[SlateButton(label: 'OK', onPressed: () {})],
          ),
        ),
      );

      expect(find.byType(SlateSeparator), findsNWidgets(2));
    });

    testWidgets('honours its width', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SlateDialog(
            title: 'Title',
            content: SizedBox(),
            actions: <Widget>[],
            width: 420,
          ),
        ),
      );

      // The Dialog wrapper fills the screen and centres its child, so the width
      // to measure is the panel's, not the widget's.
      expect(
        tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(SlateDialog),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .width,
        420,
      );
    });

    testWidgets('works through showDialog, which is how it is used', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => SlateButton(
              label: 'Open',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => SlateDialog(
                  title: 'Confirm',
                  content: const Text('Discard changes?'),
                  actions: <Widget>[
                    SlateButton(
                      label: 'Discard',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
    });
  });

  group('SlateLabeledField', () {
    testWidgets('puts the name above the field rather than in its border', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SlateLabeledField(
            label: 'Width',
            child: SlateField(controller: controller, width: 120),
          ),
        ),
      );

      expect(find.text('Width'), findsOneWidget);
      // A floating label animates, overlaps the outline and costs vertical
      // space a compact dialog does not have.
      expect(
        tester.getTopLeft(find.text('Width')).dy,
        lessThan(tester.getTopLeft(find.byType(SlateField)).dy),
      );
    });
  });
}
