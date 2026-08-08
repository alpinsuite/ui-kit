import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

const List<SlateTab> threeTabs = <SlateTab>[
  SlateTab(id: 'a', label: 'Alpha', tooltip: '/plans/alpha.fluid'),
  SlateTab(id: 'b', label: 'Beta', modified: true),
  SlateTab(id: 'c', label: 'Gamma'),
];

Widget strip({
  String? selected = 'a',
  ValueChanged<String>? onSelected,
  ValueChanged<String>? onClosed,
  List<SlateTab> tabs = threeTabs,
}) => SizedBox(
  width: 700,
  child: SlateTabStrip(
    tabs: tabs,
    selectedId: selected,
    onSelected: onSelected ?? (_) {},
    onClosed: onClosed,
    closeTooltip: 'Close',
  ),
);

/// The [Semantics] a tab declares, read off the widget rather than the rendered
/// tree — `getSemantics` on a `Text` finder returns the label's node, which
/// carries no selection state.
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
  testWidgets('shows every tab label', (tester) async {
    await tester.pumpWidget(wrap(strip()));
    for (final label in <String>['Alpha', 'Beta', 'Gamma']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('is exactly the height the metrics say', (tester) async {
    await tester.pumpWidget(wrap(strip()));
    expect(
      tester.getSize(find.byType(SlateTabStrip)).height,
      const SlateMetrics().tabHeight,
    );
  });

  testWidgets('reports the id that was tapped, not the index', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(wrap(strip(onSelected: chosen.add)));

    await tester.tap(find.text('Gamma'));
    await tester.pump();
    expect(chosen, <String>['c']);
  });

  testWidgets('reports the id that was closed', (tester) async {
    final closed = <String>[];
    await tester.pumpWidget(wrap(strip(onClosed: closed.add)));

    final closeButton = find.descendant(
      of: find
          .ancestor(
            of: find.text('Gamma'),
            matching: find.byType(GestureDetector),
          )
          .last,
      matching: find.bySemanticsLabel('Close'),
    );
    await tester.tap(closeButton.first, warnIfMissed: false);
    await tester.pump();
    expect(closed, <String>['c']);
  });

  testWidgets('without onClosed there is no close affordance', (tester) async {
    await tester.pumpWidget(wrap(strip()));
    expect(find.bySemanticsLabel('Close'), findsNothing);
  });

  testWidgets('the selected tab reads as selected', (tester) async {
    await tester.pumpWidget(wrap(strip(selected: 'b')));

    expect(propertiesFor(tester, 'Beta').selected, isTrue);
    expect(propertiesFor(tester, 'Alpha').selected, isFalse);
  });

  testWidgets('selecting nothing leaves every tab unselected', (tester) async {
    await tester.pumpWidget(wrap(strip(selected: null)));

    for (final label in <String>['Alpha', 'Beta', 'Gamma']) {
      expect(propertiesFor(tester, label).selected, isFalse, reason: label);
    }
  });

  testWidgets('a long label truncates rather than overflowing', (tester) async {
    await tester.pumpWidget(
      wrap(
        strip(
          tabs: const <SlateTab>[
            SlateTab(
              id: 'long',
              label: 'A project name far longer than any tab has room for',
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SlateTabStrip)).width, 700);
  });

  testWidgets('more tabs than fit scroll rather than disappear', (
    tester,
  ) async {
    final many = <SlateTab>[
      for (var i = 0; i < 24; i++) SlateTab(id: '$i', label: 'Document $i'),
    ];
    await tester.pumpWidget(wrap(strip(tabs: many, selected: '0')));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('draws a leading glyph when a tab carries one', (tester) async {
    await tester.pumpWidget(
      wrap(
        SlateTabStrip(
          tabs: const <SlateTab>[
            SlateTab(id: 'a', label: 'plain.pdf'),
            SlateTab(id: 'b', label: 'locked.pdf', leading: SlateIcons.lock),
          ],
          selectedId: 'a',
          onSelected: (_) {},
        ),
      ),
    );
    // One glyph, on the tab that asked for it.
    expect(find.byType(SlateIcon), findsOneWidget);
  });

  testWidgets('a leading glyph does not change the tab height', (tester) async {
    // A tab is a dense row with a fixed height; one taller than its
    // neighbours is the whole reason this takes a glyph and not a widget.
    await tester.pumpWidget(
      wrap(
        SlateTabStrip(
          tabs: const <SlateTab>[
            SlateTab(id: 'a', label: 'plain.pdf'),
            SlateTab(id: 'b', label: 'locked.pdf', leading: SlateIcons.lock),
          ],
          selectedId: 'a',
          onSelected: (_) {},
        ),
      ),
    );
    final heights = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.constraints?.maxHeight)
        .whereType<double>()
        .toSet();
    expect(heights.length, lessThanOrEqualTo(1));
  });
}
