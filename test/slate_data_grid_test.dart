import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

const List<SlateGridColumn> columns = <SlateGridColumn>[
  SlateGridColumn(id: 'name', title: 'Name', width: 200),
  SlateGridColumn(id: 'duration', title: 'Duration', width: 100),
  SlateGridColumn(id: 'start', title: 'Start', width: 120),
];

Widget grid({
  int rowCount = 5,
  List<SlateGridColumn> cols = columns,
  void Function(String, double)? onColumnResized,
  void Function(int)? onRowTap,
  bool Function(int)? isRowSelected,
  double width = 500,
  double height = 300,
}) => SizedBox(
  width: width,
  height: height,
  child: SlateDataGrid(
    columns: cols,
    rowCount: rowCount,
    onColumnResized: onColumnResized,
    onRowTap: onRowTap,
    isRowSelected: isRowSelected,
    rowSemanticLabel: (row) => 'Row $row',
    cellBuilder: (context, row, column) => Text('${column.id}-$row'),
  ),
);

void main() {
  testWidgets('draws a header from the column titles, unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(grid()));
    // Exactly as given: the grid holds no localisations and does not know
    // whether this caller's language upper-cases headings.
    for (final title in <String>['Name', 'Duration', 'Start']) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  testWidgets('asks for a cell per column per visible row', (tester) async {
    await tester.pumpWidget(wrap(grid(rowCount: 3)));
    expect(find.text('name-0'), findsOneWidget);
    expect(find.text('duration-2'), findsOneWidget);
  });

  testWidgets('builds only the rows on screen', (tester) async {
    // Ten thousand rows in a 300-pixel viewport. A grid that builds them all
    // is a grid that has to be rewritten later.
    await tester.pumpWidget(wrap(grid(rowCount: 10000)));

    expect(find.text('name-0'), findsOneWidget);
    expect(find.text('name-9999'), findsNothing);
    // Far fewer than ten thousand rows exist as widgets.
    expect(
      tester.widgetList(find.textContaining('name-')).length,
      lessThan(60),
    );
  });

  testWidgets('dragging a column edge widens it and reports the width', (
    tester,
  ) async {
    final resized = <String, double>{};
    await tester.pumpWidget(
      wrap(grid(onColumnResized: (id, width) => resized[id] = width)),
    );

    final edge = find
        .descendant(
          of: find.byType(SlateDataGrid),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.drag(edge, const Offset(60, 0));
    await tester.pumpAndSettle();

    expect(resized['name'], greaterThan(200));
    // The cells moved with the header rather than drifting away from it.
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('duration-0'),
                  matching: find.byType(SizedBox),
                )
                .first,
          )
          .width,
      100,
    );
  });

  testWidgets('a column will not be dragged below its minimum', (tester) async {
    final resized = <String, double>{};
    await tester.pumpWidget(
      wrap(
        grid(
          cols: const <SlateGridColumn>[
            SlateGridColumn(
              id: 'name',
              title: 'Name',
              width: 120,
              minWidth: 80,
            ),
            SlateGridColumn(id: 'other', title: 'Other'),
          ],
          onColumnResized: (id, width) => resized[id] = width,
        ),
      ),
    );

    final edge = find
        .descendant(
          of: find.byType(SlateDataGrid),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.drag(edge, const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(resized['name'], 80);
  });

  testWidgets('a non-resizable column has no draggable edge', (tester) async {
    // The rows carry gesture detectors of their own, so the absence of a
    // resize affordance is what the cursor says, not what a widget count does.
    final resizeCursor = find.byWidgetPredicate(
      (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeColumn,
    );

    await tester.pumpWidget(wrap(grid()));
    expect(resizeCursor, findsWidgets);

    var reported = false;
    await tester.pumpWidget(
      wrap(
        grid(
          cols: const <SlateGridColumn>[
            SlateGridColumn(
              id: 'fixed',
              title: 'Fixed',
              width: 100,
              resizable: false,
            ),
          ],
          onColumnResized: (_, _) => reported = true,
        ),
      ),
    );

    expect(resizeCursor, findsNothing);
    expect(reported, isFalse);
  });

  testWidgets('reports the row that was tapped', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(wrap(grid(onRowTap: tapped.add)));

    await tester.tap(find.text('name-2'));
    await tester.pump();
    expect(tapped, <int>[2]);
  });

  testWidgets('a selected row draws as selected', (tester) async {
    const theme = SlateThemeData.dark();
    await tester.pumpWidget(wrap(grid(isRowSelected: (row) => row == 1)));

    BoxDecoration decorationFor(String text) =>
        tester
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.text(text),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;

    expect(decorationFor('name-1').color, theme.palette.selected);
    expect(decorationFor('name-0').color, const Color(0x00000000));
  });

  testWidgets('the header scrolls in lockstep with the body', (tester) async {
    final controller = SlateGridController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 250,
          height: 300,
          child: SlateDataGrid(
            columns: columns,
            rowCount: 20,
            controller: controller,
            cellBuilder: (context, row, column) => Text('${column.id}-$row'),
          ),
        ),
      ),
    );

    controller.body.jumpTo(80);
    await tester.pumpAndSettle();

    // A header that drifts away from the columns it names is the single most
    // common way a hand-rolled grid gives itself away.
    expect(controller.header.offset, 80);
  });

  testWidgets('an empty grid still draws its header', (tester) async {
    await tester.pumpWidget(wrap(grid(rowCount: 0)));
    expect(find.text('Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
