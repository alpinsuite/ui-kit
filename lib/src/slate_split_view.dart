import 'package:flutter/widgets.dart';

import 'slate_theme.dart';

/// Two panes and a divider the user can drag.
///
/// The divider is drawn as a hairline and grabbed as a wider invisible strip —
/// a visible bar between two panes is noise, and a one-pixel target is not a
/// target. See [SlateMetrics.splitterHitExtent].
///
/// The split position is reported as a fraction rather than a pixel width, so a
/// persisted layout survives the window being resized. Pass [fraction] to drive
/// it from outside; leave it null to let the widget hold its own.
class SlateSplitView extends StatefulWidget {
  const SlateSplitView({
    required this.start,
    required this.end,
    this.axis = Axis.horizontal,
    this.initialFraction = 0.28,
    this.fraction,
    this.onFractionChanged,
    this.minStartExtent = 140,
    this.minEndExtent = 240,
    super.key,
  });

  /// Left pane, or top when [axis] is vertical.
  final Widget start;

  /// Right pane, or bottom.
  final Widget end;

  final Axis axis;

  /// Where the divider sits when uncontrolled.
  ///
  /// A fraction of the space the *panes* share — the whole, less the divider —
  /// so that the two minimum extents are honoured exactly.
  final double initialFraction;

  /// Drives the divider from outside. When set, the widget stops holding its
  /// own position and [onFractionChanged] is the only way it moves.
  final double? fraction;

  /// Fires continuously during a drag, so a caller that persists the layout can
  /// debounce rather than being handed one value at the end.
  final ValueChanged<double>? onFractionChanged;

  /// Neither pane can be dragged below these. Expressed in pixels because a
  /// pane's minimum is set by what is inside it — a tree needs a readable
  /// width, and that width does not change with the window.
  final double minStartExtent;
  final double minEndExtent;

  @override
  State<SlateSplitView> createState() => _SlateSplitViewState();
}

class _SlateSplitViewState extends State<SlateSplitView> {
  late double _fraction = widget.initialFraction;
  bool _hover = false;
  bool _dragging = false;

  double get _effective => widget.fraction ?? _fraction;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final horizontal = widget.axis == Axis.horizontal;
    final hit = theme.metrics.splitterHitExtent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = horizontal ? constraints.maxWidth : constraints.maxHeight;

        // The divider occupies space too. Measuring the fraction against the
        // whole would let the far pane be squeezed below its minimum by exactly
        // the divider's width — close enough to right to survive review and
        // wrong enough to clip a control at the edge of the pane.
        final available = (total - hit).clamp(0.0, total);

        // A window narrow enough that both minimums cannot be met has to give
        // somewhere; the first pane yields, because the second is the one the
        // user came to look at.
        final maxStart = (available - widget.minEndExtent).clamp(
          0.0,
          available,
        );
        final minStart = widget.minStartExtent.clamp(0.0, maxStart);
        final startExtent = (_effective * available).clamp(minStart, maxStart);

        void applyDelta(double delta) {
          if (available <= 0) return;
          final next = ((startExtent + delta) / available).clamp(
            minStart / available,
            maxStart / available,
          );
          if (widget.fraction == null) setState(() => _fraction = next);
          widget.onFractionChanged?.call(next);
        }

        final divider = MouseRegion(
          cursor: horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: horizontal
                ? (_) => setState(() => _dragging = true)
                : null,
            onHorizontalDragEnd: horizontal
                ? (_) => setState(() => _dragging = false)
                : null,
            onHorizontalDragUpdate: horizontal
                ? (details) => applyDelta(details.delta.dx)
                : null,
            onVerticalDragStart: horizontal
                ? null
                : (_) => setState(() => _dragging = true),
            onVerticalDragEnd: horizontal
                ? null
                : (_) => setState(() => _dragging = false),
            onVerticalDragUpdate: horizontal
                ? null
                : (details) => applyDelta(details.delta.dy),
            child: SizedBox(
              width: horizontal ? hit : null,
              height: horizontal ? null : hit,
              child: Center(
                child: Container(
                  width: horizontal ? 1 : null,
                  height: horizontal ? null : 1,
                  color: (_hover || _dragging)
                      ? palette.accent
                      : palette.separator,
                ),
              ),
            ),
          ),
        );

        final panes = <Widget>[
          SizedBox(
            width: horizontal ? startExtent : null,
            height: horizontal ? null : startExtent,
            child: widget.start,
          ),
          divider,
          Expanded(child: widget.end),
        ];

        return horizontal ? Row(children: panes) : Column(children: panes);
      },
    );
  }
}
