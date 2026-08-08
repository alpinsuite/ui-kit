import 'package:flutter/material.dart';

import 'slate_theme.dart';

/// One column of a [SlateDataGrid].
@immutable
class SlateGridColumn {
  const SlateGridColumn({
    required this.id,
    required this.title,
    this.width = 120,
    this.minWidth = 44,
    this.alignment = Alignment.centerLeft,
    this.resizable = true,
  });

  /// Identifies the column to the caller. The grid never interprets it.
  final String id;

  /// Displayed as given — the grid holds no localisations.
  final String title;

  final double width;
  final double minWidth;
  final Alignment alignment;
  final bool resizable;

  SlateGridColumn copyWith({double? width}) => SlateGridColumn(
    id: id,
    title: title,
    width: width ?? this.width,
    minWidth: minWidth,
    alignment: alignment,
    resizable: resizable,
  );
}

/// Keeps the header and the body scrolling together.
///
/// Two scroll views cannot share one controller, so this drives both from one
/// offset. Without it the header drifts away from the columns it names, which
/// is the single most common way a hand-rolled grid gives itself away.
class SlateGridController extends ChangeNotifier {
  final ScrollController header = ScrollController();
  final ScrollController body = ScrollController();

  bool _syncing = false;

  SlateGridController() {
    header.addListener(() => _mirror(header, body));
    body.addListener(() => _mirror(body, header));
  }

  void _mirror(ScrollController from, ScrollController to) {
    if (_syncing || !to.hasClients || !from.hasClients) return;
    if (to.offset == from.offset) return;
    _syncing = true;
    to.jumpTo(from.offset.clamp(0.0, to.position.maxScrollExtent));
    _syncing = false;
  }

  @override
  void dispose() {
    header.dispose();
    body.dispose();
    super.dispose();
  }
}

/// A dense grid with a fixed header, resizable columns and virtualised rows.
///
/// It holds no data. It is told how many rows there are and asked for a cell,
/// which is what keeps it from knowing whether it is showing tasks, pages or
/// resources — and what lets a caller back it with a list, a map or a query.
///
/// Rows are virtualised from the first version rather than as a later
/// optimisation. A grid that builds every row is a grid that has to be
/// rewritten the first time somebody opens a real document, and by then three
/// other things depend on the way it was written.
class SlateDataGrid extends StatefulWidget {
  const SlateDataGrid({
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
    this.controller,
    this.rowHeight,
    this.onColumnResized,
    this.onRowTap,
    this.isRowSelected,
    this.rowSemanticLabel,
    super.key,
  });

  final List<SlateGridColumn> columns;
  final int rowCount;

  /// Builds the contents of one cell. Called only for rows on screen.
  final Widget Function(BuildContext context, int row, SlateGridColumn column)
  cellBuilder;

  /// Supply one to keep the scroll position across rebuilds, or to drive it.
  final SlateGridController? controller;

  final double? rowHeight;

  /// Fires while an edge is dragged, so a caller that persists column widths
  /// can debounce rather than being handed one value at the end.
  final void Function(String columnId, double width)? onColumnResized;

  final void Function(int row)? onRowTap;
  final bool Function(int row)? isRowSelected;

  /// What a screen reader announces for a row. The grid cannot know which cell
  /// carries the name.
  final String Function(int row)? rowSemanticLabel;

  @override
  State<SlateDataGrid> createState() => _SlateDataGridState();
}

class _SlateDataGridState extends State<SlateDataGrid> {
  late List<SlateGridColumn> _columns = List<SlateGridColumn>.of(
    widget.columns,
  );
  SlateGridController? _own;

  SlateGridController get _controller =>
      widget.controller ?? (_own ??= SlateGridController());

  @override
  void didUpdateWidget(SlateDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A caller that changes the column set replaces the widths too; one that
    // only rebuilds keeps whatever the user dragged them to.
    if (widget.columns.length != oldWidget.columns.length ||
        !_sameIds(widget.columns, oldWidget.columns)) {
      _columns = List<SlateGridColumn>.of(widget.columns);
    }
  }

  static bool _sameIds(List<SlateGridColumn> a, List<SlateGridColumn> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  double get _totalWidth =>
      _columns.fold<double>(0, (sum, column) => sum + column.width);

  void _resize(int index, double delta) {
    final column = _columns[index];
    final width = (column.width + delta).clamp(column.minWidth, 2000.0);
    if (width == column.width) return;
    setState(() => _columns[index] = column.copyWith(width: width));
    widget.onColumnResized?.call(column.id, width);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final rowHeight = widget.rowHeight ?? theme.metrics.compactRowHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: theme.metrics.rowHeight,
          child: SingleChildScrollView(
            controller: _controller.header,
            scrollDirection: Axis.horizontal,
            // The header must not scroll on its own; it follows the body.
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: _totalWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < _columns.length; i++)
                    _HeaderCell(
                      column: _columns[i],
                      onResize: _columns[i].resizable
                          ? (delta) => _resize(i, delta)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ),
        Container(height: 1, color: palette.border),
        Expanded(
          child: SingleChildScrollView(
            controller: _controller.body,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _totalWidth,
              child: ListView.builder(
                itemCount: widget.rowCount,
                itemExtent: rowHeight,
                itemBuilder: (context, row) => _GridRow(
                  columns: _columns,
                  row: row,
                  height: rowHeight,
                  cellBuilder: widget.cellBuilder,
                  selected: widget.isRowSelected?.call(row) ?? false,
                  onTap: widget.onRowTap == null
                      ? null
                      : () => widget.onRowTap!(row),
                  semanticLabel: widget.rowSemanticLabel?.call(row),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.column, required this.onResize});

  final SlateGridColumn column;
  final ValueChanged<double>? onResize;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return SizedBox(
      width: column.width,
      child: Stack(
        children: <Widget>[
          Container(
            color: palette.panel,
            padding: EdgeInsets.symmetric(horizontal: theme.metrics.pad / 2),
            alignment: column.alignment,
            child: Text(
              column.title,
              style: theme.sectionStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: onResize == null
                ? Container(width: 1, color: palette.separator)
                : _ColumnEdge(onResize: onResize!),
          ),
        ],
      ),
    );
  }
}

class _ColumnEdge extends StatefulWidget {
  const _ColumnEdge({required this.onResize});

  final ValueChanged<double> onResize;

  @override
  State<_ColumnEdge> createState() => _ColumnEdgeState();
}

class _ColumnEdgeState extends State<_ColumnEdge> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.slateColors;
    final hit = context.slateMetrics.splitterHitExtent;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _active = true),
      onExit: (_) => setState(() => _active = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => widget.onResize(details.delta.dx),
        child: SizedBox(
          // Drawn as a hairline, grabbed as a strip: the same bargain the split
          // divider makes, for the same reason.
          width: hit,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 1,
              color: _active ? palette.accent : palette.separator,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridRow extends StatefulWidget {
  const _GridRow({
    required this.columns,
    required this.row,
    required this.height,
    required this.cellBuilder,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
  });

  final List<SlateGridColumn> columns;
  final int row;
  final double height;
  final Widget Function(BuildContext, int, SlateGridColumn) cellBuilder;
  final bool selected;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<_GridRow> createState() => _GridRowState();
}

class _GridRowState extends State<_GridRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Semantics(
          label: widget.semanticLabel,
          selected: widget.selected,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.selected
                  ? palette.selected
                  : _hover
                  ? palette.hover
                  : const Color(0x00000000),
              border: Border(bottom: BorderSide(color: palette.separator)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final column in widget.columns)
                  SizedBox(
                    width: column.width,
                    height: widget.height,
                    child: Align(
                      alignment: column.alignment,
                      child: widget.cellBuilder(context, widget.row, column),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
