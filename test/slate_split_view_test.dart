import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

const Key startKey = Key('start');
const Key endKey = Key('end');

Widget split({
  double initialFraction = 0.25,
  double? fraction,
  ValueChanged<double>? onFractionChanged,
  double minStartExtent = 100,
  double minEndExtent = 200,
  Axis axis = Axis.horizontal,
  double width = 800,
  double height = 400,
}) => SizedBox(
  width: width,
  height: height,
  child: SlateSplitView(
    axis: axis,
    initialFraction: initialFraction,
    fraction: fraction,
    onFractionChanged: onFractionChanged,
    minStartExtent: minStartExtent,
    minEndExtent: minEndExtent,
    start: const ColoredBox(color: Color(0xFF111111), key: startKey),
    end: const ColoredBox(color: Color(0xFF222222), key: endKey),
  ),
);

/// The panes share the width less the divider, so every expectation below is
/// measured against this rather than against the raw 800.
const double hit = 7; // SlateMetrics.splitterHitExtent
const double available = 800 - hit;

/// `tester.drag` swallows this much reaching the recognizer's threshold before
/// any of the movement reaches the widget.
const double slop = kDragSlopDefault;

Finder dividerOf() => find.descendant(
  of: find.byType(SlateSplitView),
  matching: find.byType(GestureDetector),
);

void main() {
  testWidgets('splits at the initial fraction of the shared space', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(split(initialFraction: 0.25)));
    expect(tester.getSize(find.byKey(startKey)).width, 0.25 * available);
  });

  testWidgets('dragging the divider moves the split', (tester) async {
    await tester.pumpWidget(wrap(split(initialFraction: 0.25)));

    await tester.drag(dividerOf(), const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(startKey)).width,
      closeTo(0.25 * available + 120 - slop, 0.01),
    );
  });

  testWidgets('will not drag a pane below its minimum', (tester) async {
    await tester.pumpWidget(
      wrap(split(initialFraction: 0.25, minStartExtent: 150)),
    );

    await tester.drag(dividerOf(), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(startKey)).width, 150);
  });

  testWidgets('will not drag the far pane below its minimum', (tester) async {
    await tester.pumpWidget(
      wrap(split(initialFraction: 0.25, minEndExtent: 250)),
    );

    await tester.drag(dividerOf(), const Offset(900, 0));
    await tester.pumpAndSettle();

    // The far pane keeps its 250 *and* the divider keeps its width — the whole
    // point of measuring the fraction against the shared space.
    expect(tester.getSize(find.byKey(startKey)).width, available - 250);
    expect(tester.getSize(find.byKey(endKey)).width, 250);
  });

  testWidgets('reports the fraction during the drag, not only at the end', (
    tester,
  ) async {
    final reported = <double>[];
    await tester.pumpWidget(
      wrap(split(initialFraction: 0.25, onFractionChanged: reported.add)),
    );

    final gesture = await tester.startGesture(tester.getCenter(dividerOf()));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    // A caller that persists the layout wants to debounce, which needs more
    // than one value.
    expect(reported.length, greaterThan(1));
    // A hand-driven gesture reports every pixel; only `tester.drag` swallows a
    // slop, which is why this expectation has none.
    expect(reported.last, closeTo((0.25 * available + 80) / available, 0.01));
  });

  testWidgets('a controlled fraction ignores the drag until told otherwise', (
    tester,
  ) async {
    final reported = <double>[];
    await tester.pumpWidget(
      wrap(split(fraction: 0.25, onFractionChanged: reported.add)),
    );

    await tester.drag(dividerOf(), const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(reported, isNotEmpty);
    // The widget did not move itself: the owner of the value decides.
    expect(tester.getSize(find.byKey(startKey)).width, 0.25 * available);
  });

  testWidgets('splits vertically when asked to', (tester) async {
    await tester.pumpWidget(
      wrap(
        split(
          axis: Axis.vertical,
          initialFraction: 0.25,
          minStartExtent: 50,
          minEndExtent: 50,
        ),
      ),
    );
    expect(tester.getSize(find.byKey(startKey)).height, 0.25 * (400 - hit));
  });

  testWidgets('a window too small for both minimums yields the first pane', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        split(
          width: 300,
          initialFraction: 0.5,
          minStartExtent: 200,
          minEndExtent: 250,
        ),
      ),
    );
    // The second pane is the one the user came to look at, so the first gives.
    expect(tester.getSize(find.byKey(startKey)).width, lessThan(200));
  });
}
