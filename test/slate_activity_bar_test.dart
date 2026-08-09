import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

List<SlateActivityItem> items() => <SlateActivityItem>[
  const SlateActivityItem(icon: SlateIcons.list, tooltip: 'Tasks'),
  const SlateActivityItem(icon: SlateIcons.gantt, tooltip: 'Gantt'),
  const SlateActivityItem(
    icon: SlateIcons.warning,
    tooltip: 'Conflicts',
    badge: '3',
  ),
];

Widget bar({
  int selected = 0,
  ValueChanged<int>? onSelected,
  List<SlateActivityItem> footer = const <SlateActivityItem>[],
  ValueChanged<int>? onFooter,
}) => SizedBox(
  height: 400,
  child: SlateActivityBar(
    items: items(),
    selectedIndex: selected,
    onSelected: onSelected ?? (_) {},
    footerItems: footer,
    onFooterSelected: onFooter,
  ),
);

/// The [Semantics] a destination declares.
///
/// Read off the widget rather than the rendered tree: `getSemantics` on a
/// tooltip finder walks up to the nearest node, which is the root, and the
/// assertion then passes or fails for reasons unrelated to the bar.
SemanticsProperties propertiesFor(WidgetTester tester, String label) {
  return tester
      .widget<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == label &&
              w.properties.button == true,
        ),
      )
      .properties;
}

void main() {
  testWidgets('is exactly the width the metrics say', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    expect(
      tester.getSize(find.byType(SlateActivityBar)).width,
      const SlateMetrics().activityBarWidth,
    );
  });

  testWidgets('reports the index that was tapped', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(wrap(bar(onSelected: tapped.add)));

    await tester.tap(find.byTooltip('Gantt'));
    await tester.pump();
    expect(tapped, <int>[1]);
  });

  testWidgets('marks the selected destination with an accent rule', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(bar(selected: 1)));

    expect(propertiesFor(tester, 'Gantt').selected, isTrue);
    expect(propertiesFor(tester, 'Tasks').selected, isFalse);
  });

  testWidgets('every destination carries its name for a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(bar()));

    for (final label in <String>['Tasks', 'Gantt', 'Conflicts']) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
    }
    handle.dispose();
  });

  testWidgets('draws the badge text it was given', (tester) async {
    await tester.pumpWidget(wrap(bar()));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('footer destinations report their own index', (tester) async {
    final footer = <int>[];
    await tester.pumpWidget(
      wrap(
        bar(
          footer: <SlateActivityItem>[
            const SlateActivityItem(
              icon: SlateIcons.settings,
              tooltip: 'Settings',
            ),
          ],
          onFooter: footer.add,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump();
    // Indexed into the footer list, not continuing the main one.
    expect(footer, <int>[0]);
  });

  testWidgets('a negative selection selects nothing', (tester) async {
    await tester.pumpWidget(wrap(bar(selected: -1)));

    for (final label in <String>['Tasks', 'Gantt', 'Conflicts']) {
      expect(propertiesFor(tester, label).selected, isFalse, reason: label);
    }
  });

  testWidgets('a disabled item does not report a selection', (tester) async {
    // It stays in the list rather than disappearing: a rail whose items come
    // and go teaches the user the missing ones do not exist, and shifts the
    // ones that remain out from under the pointer.
    var selected = -1;
    await tester.pumpWidget(
      wrap(
        SlateActivityBar(
          items: const <SlateActivityItem>[
            SlateActivityItem(icon: SlateIcons.eye, tooltip: 'View'),
            SlateActivityItem(
              icon: SlateIcons.pencil,
              tooltip: 'Edit',
              enabled: false,
            ),
          ],
          selectedIndex: 0,
          onSelected: (i) => selected = i,
        ),
      ),
    );

    await tester.tap(find.byType(SlateIcon).at(1));
    expect(selected, -1, reason: 'the disabled item reported anyway');

    await tester.tap(find.byType(SlateIcon).at(0));
    expect(selected, 0);
  });

  testWidgets('a disabled item is still announced, and as disabled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        SlateActivityBar(
          items: const <SlateActivityItem>[
            SlateActivityItem(
              icon: SlateIcons.pencil,
              tooltip: 'Edit',
              enabled: false,
            ),
          ],
          selectedIndex: -1,
          onSelected: (_) {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Edit'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the whole cell is the target, not just the icon', (
    tester,
  ) async {
    // The regression this exists for: the button was a bare SizedBox around a
    // Stack, so with the default deferToChild the only hit-testable thing in
    // it was the icon. The rail read as unresponsive, because clicking a
    // destination anywhere but dead centre did nothing.
    var selected = -1;
    await tester.pumpWidget(
      wrap(
        SlateActivityBar(
          items: const <SlateActivityItem>[
            SlateActivityItem(icon: SlateIcons.eye, tooltip: 'View'),
            SlateActivityItem(icon: SlateIcons.layers, tooltip: 'Pages'),
          ],
          selectedIndex: 0,
          onSelected: (index) => selected = index,
        ),
      ),
    );

    final cell = tester.getRect(find.byType(SlateIcon).at(1));
    final box = tester.getRect(find.byType(SlateActivityBar));
    // A corner of the second cell, well away from its glyph.
    await tester.tapAt(Offset(box.left + 3, cell.center.dy - 14));
    expect(selected, 1);
  });

  testWidgets('a disabled destination ignores a corner tap too', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      wrap(
        SlateActivityBar(
          items: const <SlateActivityItem>[
            SlateActivityItem(icon: SlateIcons.eye, tooltip: 'View'),
            SlateActivityItem(
              icon: SlateIcons.layers,
              tooltip: 'Pages',
              enabled: false,
            ),
          ],
          selectedIndex: 0,
          onSelected: (index) => selected = index,
        ),
      ),
    );

    final cell = tester.getRect(find.byType(SlateIcon).at(1));
    final box = tester.getRect(find.byType(SlateActivityBar));
    await tester.tapAt(Offset(box.left + 3, cell.center.dy - 14));
    expect(selected, -1);
  });
}
