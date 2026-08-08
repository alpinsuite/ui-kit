import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

Widget treeRow({
  int depth = 0,
  bool? expanded,
  VoidCallback? onToggle,
  bool selected = false,
  VoidCallback? onTap,
}) => SizedBox(
  width: 300,
  child: SlateTreeRow(
    depth: depth,
    expanded: expanded,
    onToggle: onToggle,
    selected: selected,
    onTap: onTap,
    semanticLabel: 'Excavate',
    child: const Text('Excavate'),
  ),
);

/// Where the row's content starts, which is what "indented" means to the eye.
double contentLeft(WidgetTester tester) =>
    tester.getTopLeft(find.text('Excavate')).dx;

void main() {
  testWidgets('each level shifts the content by one indent', (tester) async {
    await tester.pumpWidget(wrap(treeRow()));
    final atRoot = contentLeft(tester);

    await tester.pumpWidget(wrap(treeRow(depth: 2)));
    expect(contentLeft(tester) - atRoot, 2 * SlateTreeRow.indentExtent);
  });

  testWidgets('a leaf gets no triangle', (tester) async {
    await tester.pumpWidget(wrap(treeRow()));
    expect(find.byType(SlateIcon), findsNothing);
  });

  testWidgets('a leaf still lines up with its expandable siblings', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(treeRow(depth: 1)));
    final leaf = contentLeft(tester);

    await tester.pumpWidget(wrap(treeRow(depth: 1, expanded: false)));
    // The indent is reserved either way; a leaf that shifted left would break
    // the column of names.
    expect(contentLeft(tester), leaf);
  });

  testWidgets('the triangle points down when expanded', (tester) async {
    await tester.pumpWidget(wrap(treeRow(expanded: true)));
    expect(find.byType(SlateIcon), findsOneWidget);
    expect(
      tester.widget<SlateIcon>(find.byType(SlateIcon)).draw,
      SlateIcons.chevronDown,
    );

    await tester.pumpWidget(wrap(treeRow(expanded: false)));
    expect(
      tester.widget<SlateIcon>(find.byType(SlateIcon)).draw,
      SlateIcons.chevronRight,
    );
  });

  testWidgets('the triangle toggles without selecting the row', (tester) async {
    var toggles = 0;
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        treeRow(
          expanded: false,
          onToggle: () => toggles++,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(SlateIcon));
    await tester.pump();

    // Expanding and selecting are different intentions.
    expect(toggles, 1);
    expect(taps, 0);
  });

  testWidgets('tapping the row selects it', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(treeRow(onTap: () => taps++)));

    await tester.tap(find.text('Excavate'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('announces its name, selection and disclosure', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(treeRow(expanded: true, selected: true)));

    final properties = tester
        .widget<Semantics>(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Excavate',
          ),
        )
        .properties;

    expect(properties.selected, isTrue);
    expect(properties.expanded, isTrue);
    handle.dispose();
  });

  testWidgets('is exactly the height the metrics say', (tester) async {
    await tester.pumpWidget(wrap(treeRow()));
    expect(
      tester.getSize(find.byType(SlateTreeRow)).height,
      const SlateMetrics().compactRowHeight,
    );
  });
}
