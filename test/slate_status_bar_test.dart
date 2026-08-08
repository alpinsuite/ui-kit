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

  testWidgets('emphasis draws in the accent colour', (tester) async {
    const theme = SlateThemeData.dark();
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 600,
          child: SlateStatusBar(
            leading: <Widget>[
              SlateStatusItem(label: 'Quiet'),
              SlateStatusItem(label: 'Loud', emphasis: true),
            ],
          ),
        ),
      ),
    );

    Color colourOf(String text) =>
        tester.widget<Text>(find.text(text)).style!.color!;

    expect(colourOf('Loud'), theme.palette.accent);
    expect(colourOf('Quiet'), theme.palette.inkDim);
  });
}
