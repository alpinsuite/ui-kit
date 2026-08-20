import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

const double trackExtent = 400;

/// `tester.dragFrom` swallows this much reaching the recognizer's threshold
/// before any of the movement reaches the widget.
const double slop = kDragSlopDefault;

/// What a drag of [by] pixels should report, given the thumb travels the track
/// less its own length.
double expectedOffset(double by, {double thumbExtent = trackExtent / 5}) =>
    400 * (by - slop) / (trackExtent - thumbExtent);

Widget bar({
  required double offset,
  required ValueChanged<double> onOffsetChanged,
  double viewportExtent = 100,
  double contentExtent = 500,
  double minThumbExtent = 24,
  Axis axis = Axis.vertical,
}) => SizedBox(
  width: axis == Axis.vertical ? 11 : trackExtent,
  height: axis == Axis.vertical ? trackExtent : 11,
  child: SlateScrollbar(
    axis: axis,
    offset: offset,
    viewportExtent: viewportExtent,
    contentExtent: contentExtent,
    onOffsetChanged: onOffsetChanged,
    minThumbExtent: minThumbExtent,
  ),
);

/// The thumb is the only `DecoratedBox` the widget draws.
Rect thumbRect(WidgetTester tester) =>
    tester.getRect(find.byType(DecoratedBox).first);

void main() {
  testWidgets('the thumb is sized by the visible fraction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(bar(offset: 0, onOffsetChanged: (double _) {})),
    );

    // A fifth of the content is visible, so the thumb is a fifth of the track.
    expect(thumbRect(tester).height, closeTo(trackExtent / 5, 0.5));
  });

  testWidgets('the thumb reaches the end of the track at maximum offset', (
    WidgetTester tester,
  ) async {
    // The trap this guards: the thumb travels the track *less its own length*.
    // Deriving its position from the offset ratio alone runs it off the end.
    await tester.pumpWidget(
      wrap(bar(offset: 400, onOffsetChanged: (double _) {})),
    );

    final Rect thumb = thumbRect(tester);
    final Rect track = tester.getRect(find.byType(SlateScrollbar));
    expect(thumb.bottom, closeTo(track.bottom, 0.5));
  });

  testWidgets('a very long document still leaves a grabbable thumb', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        bar(offset: 0, contentExtent: 1000000, onOffsetChanged: (double _) {}),
      ),
    );

    expect(thumbRect(tester).height, 24);
  });

  testWidgets('it draws nothing when everything fits', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        bar(
          offset: 0,
          viewportExtent: 500,
          contentExtent: 400,
          onOffsetChanged: (double _) {},
        ),
      ),
    );

    expect(find.byType(DecoratedBox), findsNothing);
  });

  testWidgets('dragging the thumb reports a proportional offset', (
    WidgetTester tester,
  ) async {
    double reported = 0;
    await tester.pumpWidget(
      wrap(bar(offset: 0, onOffsetChanged: (double value) => reported = value)),
    );

    final Rect thumb = thumbRect(tester);
    await tester.dragFrom(thumb.center, const Offset(0, 80));
    await tester.pump();

    expect(reported, closeTo(expectedOffset(80), 1));
  });

  testWidgets('grabbing the thumb near its end does not recentre it', (
    WidgetTester tester,
  ) async {
    double reported = -1;
    await tester.pumpWidget(
      wrap(bar(offset: 0, onOffsetChanged: (double value) => reported = value)),
    );

    // Press near the thumb's top edge and release without moving: the offset
    // must not change. A scrollbar that jumps on mouse-down loses the user's
    // place every time they reach for it.
    final Rect thumb = thumbRect(tester);
    await tester.dragFrom(thumb.topCenter + const Offset(0, 2), Offset.zero);
    await tester.pump();

    expect(reported, anyOf(-1, closeTo(0, 1)));
  });

  testWidgets('clicking the empty track pages rather than jumping', (
    WidgetTester tester,
  ) async {
    double reported = -1;
    await tester.pumpWidget(
      wrap(bar(offset: 0, onOffsetChanged: (double value) => reported = value)),
    );

    final Rect track = tester.getRect(find.byType(SlateScrollbar));
    await tester.tapAt(Offset(track.center.dx, track.bottom - 10));
    await tester.pump();

    // One viewport-ish, not all the way to where the pointer landed.
    expect(reported, closeTo(90, 1));
  });

  testWidgets('the thumb firms up when the pointer arrives', (
    WidgetTester tester,
  ) async {
    const SlateThemeData theme = SlateThemeData.dark();
    await tester.pumpWidget(
      wrap(bar(offset: 0, onOffsetChanged: (double _) {}), theme: theme),
    );

    BoxDecoration decoration() =>
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;

    expect(decoration().color, theme.palette.inkDim);
    await hover(tester, find.byType(SlateScrollbar));
    expect(decoration().color, theme.palette.ink);
  });

  testWidgets('a horizontal bar works the same way on its own axis', (
    WidgetTester tester,
  ) async {
    double reported = 0;
    await tester.pumpWidget(
      wrap(
        bar(
          offset: 0,
          axis: Axis.horizontal,
          onOffsetChanged: (double value) => reported = value,
        ),
      ),
    );

    expect(thumbRect(tester).width, closeTo(trackExtent / 5, 0.5));
    await tester.dragFrom(thumbRect(tester).center, const Offset(80, 0));
    await tester.pump();
    expect(reported, closeTo(expectedOffset(80), 1));
  });

  testWidgets('carries its own thickness across the axis', (tester) async {
    // The arrangement it exists for is laid over a viewport inside a Stack,
    // positioned on three edges — which leaves the fourth unbounded. A widget
    // that took whatever the parent offered would assert there, naming this
    // file rather than the caller.
    await tester.pumpWidget(
      wrap(
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              const Positioned.fill(child: SizedBox()),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: SlateScrollbar(
                  axis: Axis.vertical,
                  offset: 0,
                  viewportExtent: 100,
                  contentExtent: 400,
                  onOffsetChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(SlateScrollbar)).width,
      SlateMetrics.standard.scrollbarThickness,
    );
  });
}
