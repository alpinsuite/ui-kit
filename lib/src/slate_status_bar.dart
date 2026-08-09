import 'package:flutter/material.dart';

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

  /// Draws in the accent colour. For the one number that matters — overdue
  /// work, unresolved problems.
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
    final colour = widget.emphasis ? palette.accent : palette.inkDim;

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
              color: colour,
            ),
            SizedBox(width: theme.metrics.gap / 2),
          ],
          Text(widget.label, style: theme.dimTextStyle.copyWith(color: colour)),
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: Semantics(
          label: widget.tooltip ?? widget.label,
          button: true,
          child: content,
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
      child: Row(children: <Widget>[...leading, const Spacer(), ...trailing]),
    );
  }
}
