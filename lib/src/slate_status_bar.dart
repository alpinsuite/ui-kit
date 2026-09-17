import 'package:flutter/material.dart';

import 'slate_focus.dart';
import 'slate_icons.dart';
import 'slate_theme.dart';

/// One segment of a [SlateStatusBar].
///
/// Clickable when [onPressed] is given, which is what makes a status bar useful
/// rather than decorative: a count of problems that jumps to the problems is
/// worth having, a count that just sits there is not.
class SlateStatusItem extends StatefulWidget {
  const SlateStatusItem({
    required this.label,
    this.icon,
    this.onPressed,
    this.tooltip,
    this.emphasis = false,
    super.key,
  });

  final String label;
  final SlateIconDraw? icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Marks the one number that matters — overdue work, unresolved problems — with
  /// the accent on its icon and full ink on its label.
  ///
  /// Not the accent on the label. In the light palette that is 4.20:1 on the
  /// bar and 3.91 under the pointer, under the 4.5 a label this size needs; an
  /// icon needs 3:1, so the icon carries the colour and the label stays
  /// readable — the choice the chosen segment of a `SlateSegmented` made.
  final bool emphasis;

  @override
  State<SlateStatusItem> createState() => _SlateStatusItemState();
}

class _SlateStatusItemState extends State<SlateStatusItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final interactive = widget.onPressed != null;
    final glyph = widget.emphasis ? palette.accent : palette.inkDim;
    final ink = widget.emphasis ? palette.ink : palette.inkDim;

    Widget content = Container(
      height: theme.metrics.barHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.metrics.pad * 0.8),
      alignment: Alignment.center,
      color: (_hover && interactive) ? palette.hover : const Color(0x00000000),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.icon != null) ...<Widget>[
            SlateIcon(
              widget.icon!,
              size: theme.metrics.smallFontSize,
              color: glyph,
            ),
            SizedBox(width: theme.metrics.gap / 2),
          ],
          Text(widget.label, style: theme.dimTextStyle.copyWith(color: ink)),
        ],
      ),
    );

    if (!interactive) {
      return Semantics(label: widget.tooltip ?? widget.label, child: content);
    }

    content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: SlateFocusable(
        onPressed: widget.onPressed,
        borderRadius: BorderRadius.circular(context.slate.metrics.radius),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Semantics(
            label: widget.tooltip ?? widget.label,
            button: true,
            child: content,
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    return tooltip == null
        ? content
        : Tooltip(message: tooltip, child: content);
  }
}

/// The bar across the bottom of the window.
///
/// [leading] is read-outs — a page number, a word count, a language — and
/// [trailing] is controls. They are treated differently when the window is too
/// narrow for both, because they are worth different amounts: **the controls
/// keep their size and the read-outs give way**, scrolling sideways inside
/// whatever room is left.
///
/// A `Row` of both was what stood here, and it painted the overflow stripe the
/// moment an application added one item too many — which an application will,
/// because a status bar is where everything ends up. A stripe is not a design
/// decision anybody made.
class SlateStatusBar extends StatelessWidget {
  const SlateStatusBar({
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    super.key,
  });

  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return Container(
      height: theme.metrics.barHeight,
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.separator)),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            // Loose, so a bar with room to spare lays its read-outs out at
            // their natural size and nothing moves.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // A status bar is not a place anybody expects to drag, so the
              // strip scrolls only when a pointer wheel or a trackpad asks.
              child: Row(mainAxisSize: MainAxisSize.min, children: leading),
            ),
          ),
          const Spacer(),
          ...trailing,
        ],
      ),
    );
  }
}
