import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  testWidgets('is exactly the height the metrics say', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[SlateStatusItem(label: 'Ready')],
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(SlateStatusBar)).height,
      const SlateMetrics().barHeight,
    );
  });

  testWidgets('an emphasised segment has an accent icon and an ink label', (
    tester,
  ) async {
    const theme = SlateThemeData.light();
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[
              SlateStatusItem(
                label: '3 overdue',
                icon: SlateIcons.warning,
                emphasis: true,
              ),
              SlateStatusItem(label: 'Ready', icon: SlateIcons.check),
            ],
          ),
        ),
        theme: theme,
      ),
    );

    Color labelOf(String text) =>
        tester.widget<Text>(find.text(text)).style!.color!;
    // The segment's own row: the nearest one. The bar's rows hold every icon.
    Color iconOf(String text) => tester
        .widget<SlateIcon>(
          find.descendant(
            of: find
                .ancestor(of: find.text(text), matching: find.byType(Row))
                .first,
            matching: find.byType(SlateIcon),
          ),
        )
        .color!;

    expect(labelOf('3 overdue'), theme.palette.ink);
    expect(iconOf('3 overdue'), theme.palette.accent);
    expect(labelOf('Ready'), theme.palette.inkDim);
    expect(iconOf('Ready'), theme.palette.inkDim);
    // Asserted by colour rather than by `textContrastGuideline`, which passed
    // the accent label at 4.20:1 as readily as the ink one: the numbers are in
    // slate_palette_test.dart, where they are measured rather than sampled.
  });

  testWidgets('leading segments sit left and trailing sit right', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[SlateStatusItem(label: 'Left')],
            trailing: <Widget>[SlateStatusItem(label: 'Right')],
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.text('Left')).dx,
      lessThan(tester.getCenter(find.text('Right')).dx),
    );
  });

  testWidgets('a segment with a handler is tappable', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[
              SlateStatusItem(
                label: '3 conflicts',
                onPressed: () => taps++,
                tooltip: 'Show conflicts',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('3 conflicts'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('a segment without a handler is not a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[SlateStatusItem(label: 'Ready')],
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Ready')),
      isNot(isSemantics(isButton: true)),
    );
    handle.dispose();
  });

  testWidgets('read-outs give way before controls do', (tester) async {
    // A status bar is where everything ends up, so one item too many must not
    // paint the overflow stripe. The read-outs are what give way: the controls
    // are the half you still have to be able to press.
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 200,
          child: SlateStatusBar(
            leading: <Widget>[
              for (var i = 0; i < 8; i++)
                SlateStatusItem(label: 'a read-out $i'),
            ],
            trailing: <Widget>[SlateButton(label: 'zoom', onPressed: () {})],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull, reason: 'it overflowed');
    expect(find.text('zoom'), findsOneWidget);
  });
}
