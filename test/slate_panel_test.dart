import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

Widget panel({List<Widget> actions = const <Widget>[]}) => SizedBox(
  width: 260,
  height: 400,
  child: SlateSidePanel(
    title: 'OUTLINE',
    actions: actions,
    child: const ColoredBox(color: Color(0xFF101010), key: Key('body')),
  ),
);

void main() {
  testWidgets('shows the title it was given, unchanged', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    // The kit does not upper-case, translate or otherwise edit the caller's
    // string: it does not know what language it is in.
    expect(find.text('OUTLINE'), findsOneWidget);
  });

  testWidgets('the header is one bar tall and the body takes the rest', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(panel()));

    final bodyHeight = tester.getSize(find.byKey(const Key('body'))).height;
    // 400, less the header and the hairline under it.
    expect(bodyHeight, 400 - const SlateMetrics().barHeight - 1);
  });

  testWidgets('header actions are placed at the trailing edge', (tester) async {
    await tester.pumpWidget(
      wrap(
        panel(
          actions: <Widget>[
            SlateIconButton(
              icon: SlateIcons.filter,
              onPressed: () {},
              tooltip: 'Filter',
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getCenter(find.byTooltip('Filter')).dx,
      greaterThan(tester.getCenter(find.text('OUTLINE')).dx),
    );
  });

  testWidgets('a long title truncates rather than overflowing', (tester) async {
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 120,
          height: 300,
          child: SlateSidePanel(
            title: 'A panel heading considerably wider than the panel itself',
            child: Container(),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
