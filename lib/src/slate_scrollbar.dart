import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'slate_palette.dart';
import 'slate_theme.dart';

/// A scrollbar driven by an offset rather than by a [ScrollController].
///
/// **Offset-driven on purpose.** Flutter's own `Scrollbar` needs a
/// [ScrollPosition], which means the thing being scrolled has to be a
/// [Scrollable] — and some viewports are not one. A grid whose two axes are
/// independent, whose wheel scroll is quantised, and part of whose content is
/// pinned in place while the rest moves has no single [ScrollPosition] to offer.
/// This takes three numbers and reports a fourth.
///
/// For the ordinary case — a real [Scrollable] — use
/// [SlateScrollbar.forController], which keeps itself in step with the
/// controller and needs nothing else.
///
/// Like the rest of the kit it is quiet at rest: the thumb is dim, the track is
/// invisible, and both firm up when the pointer arrives.
class SlateScrollbar extends StatefulWidget {
  const SlateScrollbar({
    required this.axis,
    required this.offset,
    required this.viewportExtent,
    required this.contentExtent,
    required this.onOffsetChanged,
    this.thickness,
    this.minThumbExtent = 24,
    super.key,
  }) : controller = null;

  /// Drives itself from [controller], for a viewport that really is a
  /// [Scrollable].
  const SlateScrollbar.forController({
    required this.axis,
    required this.controller,
    this.thickness,
    this.minThumbExtent = 24,
    super.key,
  }) : offset = 0,
       viewportExtent = 0,
       contentExtent = 0,
       onOffsetChanged = _ignore;

  final Axis axis;

  /// How far the viewport is scrolled, in the same units as the two extents.
  final double offset;

  /// How much of the content is visible.
  final double viewportExtent;

  /// How much there is in total.
  final double contentExtent;

  /// Fires continuously during a drag. The caller owns the offset and is free
  /// to clamp it; the scrollbar redraws from whatever comes back.
  final ValueChanged<double> onOffsetChanged;

  /// Defaults to [SlateMetrics.scrollbarThickness].
  final double? thickness;

  /// However little content is visible, the thumb never shrinks past this —
  /// below about this size it stops being something a pointer can catch.
  final double minThumbExtent;

  /// Null in the offset-driven form, which is the one this widget exists for.
  final ScrollController? controller;

  static void _ignore(double _) {}

  @override
  State<SlateScrollbar> createState() => _SlateScrollbarState();
}

class _SlateScrollbarState extends State<SlateScrollbar> {
  bool _hovered = false;
  bool _dragging = false;

  /// Where in the thumb the drag started, so that grabbing it near one end does
  /// not jump it to centre on the pointer.
  double _grabWithinThumb = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SlateScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  double get _offset {
    final ScrollController? controller = widget.controller;
    if (controller == null) return widget.offset;
    return controller.hasClients ? controller.offset : 0;
  }

  double get _viewportExtent {
    final ScrollController? controller = widget.controller;
    if (controller == null) return widget.viewportExtent;
    if (!controller.hasClients) return 0;
    return controller.position.viewportDimension;
  }

  double get _contentExtent {
    final ScrollController? controller = widget.controller;
    if (controller == null) return widget.contentExtent;
    if (!controller.hasClients) return 0;
    final ScrollPosition position = controller.position;
    return position.maxScrollExtent + position.viewportDimension;
  }

  void _report(double value) {
    final ScrollController? controller = widget.controller;
    if (controller != null) {
      if (controller.hasClients) controller.jumpTo(value);
      return;
    }
    widget.onOffsetChanged(value);
  }

  /// The thumb, as a start and an extent along the track.
  ({double start, double extent})? _thumb(double trackExtent) {
    final double content = _contentExtent;
    final double viewport = _viewportExtent;
    if (content <= 0 || viewport <= 0 || content <= viewport) return null;

    final double raw = trackExtent * viewport / content;
    final double extent = raw < widget.minThumbExtent
        ? widget.minThumbExtent
        : raw;
    final double maxOffset = content - viewport;
    if (maxOffset <= 0) return null;
    // The thumb travels the track *less its own length*, which is why this
    // cannot be derived from the offset ratio alone once the minimum has kicked
    // in — get it wrong and the thumb runs off the end of a long document.
    final double travel = trackExtent - extent;
    final double fraction = (_offset / maxOffset).clamp(0.0, 1.0);
    return (start: travel * fraction, extent: extent);
  }

  void _scrollToThumbStart(
    double start,
    double trackExtent,
    double thumbExtent,
  ) {
    final double travel = trackExtent - thumbExtent;
    if (travel <= 0) return;
    final double maxOffset = _contentExtent - _viewportExtent;
    _report((start / travel).clamp(0.0, 1.0) * maxOffset);
  }

  @override
  Widget build(BuildContext context) {
    final SlatePalette palette = context.slateColors;
    final double thickness =
        widget.thickness ?? context.slateMetrics.scrollbarThickness;
    final bool horizontal = widget.axis == Axis.horizontal;
    final bool lit = _hovered || _dragging;

    // Its own thickness across the axis, per kit rule 4. Without it the widget
    // takes whatever the parent offers, which in the usual arrangement — laid
    // over a viewport inside a Stack, positioned on three edges — is unbounded,
    // and the assertion that follows names this file rather than the caller.
    return SizedBox(
      width: horizontal ? null : thickness,
      height: horizontal ? thickness : null,
      child: MouseRegion(
        onEnter: (PointerEnterEvent _) => setState(() => _hovered = true),
        onExit: (PointerExitEvent _) => setState(() => _hovered = false),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double trackExtent = horizontal
                ? constraints.maxWidth
                : constraints.maxHeight;
            final ({double extent, double start})? thumb = _thumb(trackExtent);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // A scrollbar is a pointer affordance. The scrollable it belongs
              // to already exposes scroll actions, so announcing this as an
              // unlabelled tappable thing adds a stop on the reading order that
              // does nothing and can be described as nothing.
              excludeFromSemantics: true,
              onTapDown: (TapDownDetails details) {
                if (thumb == null) return;
                final double at = horizontal
                    ? details.localPosition.dx
                    : details.localPosition.dy;
                if (at >= thumb.start && at <= thumb.start + thumb.extent) {
                  return;
                }
                // A click on the empty track pages towards the pointer rather
                // than jumping to it, which is what every desktop scrollbar the
                // user has ever used does.
                final double page = _viewportExtent * 0.9;
                _report(
                  (_offset + (at < thumb.start ? -page : page)).clamp(
                    0.0,
                    _contentExtent - _viewportExtent,
                  ),
                );
              },
              onPanStart: (DragStartDetails details) {
                if (thumb == null) return;
                final double at = horizontal
                    ? details.localPosition.dx
                    : details.localPosition.dy;
                setState(() {
                  _dragging = true;
                  _grabWithinThumb =
                      at >= thumb.start && at <= thumb.start + thumb.extent
                      ? at - thumb.start
                      : thumb.extent / 2;
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (thumb == null) return;
                final double at = horizontal
                    ? details.localPosition.dx
                    : details.localPosition.dy;
                _scrollToThumbStart(
                  at - _grabWithinThumb,
                  trackExtent,
                  thumb.extent,
                );
              },
              onPanEnd: (DragEndDetails _) => setState(() => _dragging = false),
              onPanCancel: () => setState(() => _dragging = false),
              child: Container(
                color: lit ? palette.panel : const Color(0x00000000),
                child: thumb == null
                    ? const SizedBox.expand()
                    : Stack(
                        children: <Widget>[
                          Positioned(
                            left: horizontal ? thumb.start : 2,
                            top: horizontal ? 2 : thumb.start,
                            width: horizontal ? thumb.extent : thickness - 4,
                            height: horizontal ? thickness - 4 : thumb.extent,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _dragging
                                    ? palette.accent
                                    : lit
                                    ? palette.ink
                                    : palette.inkDim,
                                borderRadius: BorderRadius.circular(
                                  (thickness - 4) / 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
