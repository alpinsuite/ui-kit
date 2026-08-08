import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_theme.dart';

/// A row in an outline: indent, a disclosure triangle, and the states.
///
/// The triangle appears only where there is something to disclose. A leaf still
/// gets the indent, so the names down a level line up with each other rather
/// than shifting by the width of a control that is not there.
class SlateTreeRow extends StatefulWidget {
  const SlateTreeRow({
    required this.depth,
    required this.child,
    this.expanded,
    this.onToggle,
    this.selected = false,
    this.onTap,
    this.indentGuides = true,
    this.height,
    this.semanticLabel,
    super.key,
  });

  /// Zero for a top-level row.
  final int depth;

  /// Null marks a leaf: no triangle, and no space wasted pretending there
  /// might be one later.
  final bool? expanded;

  final VoidCallback? onToggle;

  final bool selected;
  final VoidCallback? onTap;

  /// Hairlines down the levels above this row. They are what stops a deep
  /// outline from becoming a column of text with no visible parentage.
  final bool indentGuides;

  final double? height;

  /// What a screen reader announces. The caller assembles it, because the row
  /// does not know which of its cells is the name.
  final String? semanticLabel;

  final Widget child;

  /// How far one level of nesting shifts a row.
  static const double indentExtent = 14;

  @override
  State<SlateTreeRow> createState() => _SlateTreeRowState();
}

class _SlateTreeRowState extends State<SlateTreeRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final height = widget.height ?? theme.metrics.compactRowHeight;
    final expanded = widget.expanded;

    Widget row = Container(
      height: height,
      color: widget.selected
          ? palette.selected
          : _hover
          ? palette.hover
          : const Color(0x00000000),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: SlateTreeRow.indentExtent * widget.depth + 18,
            height: height,
            child: Stack(
              children: <Widget>[
                if (widget.indentGuides)
                  for (var level = 0; level < widget.depth; level++)
                    Positioned(
                      left: SlateTreeRow.indentExtent * level + 8,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 1, color: palette.separator),
                    ),
                if (expanded != null)
                  Positioned(
                    left: SlateTreeRow.indentExtent * widget.depth + 2,
                    top: 0,
                    bottom: 0,
                    child: _Disclosure(
                      expanded: expanded,
                      onToggle: widget.onToggle,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );

    if (widget.onTap != null) {
      row = GestureDetector(onTap: widget.onTap, child: row);
    }

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        label: widget.semanticLabel,
        selected: widget.selected,
        expanded: expanded,
        child: row,
      ),
    );
  }
}

class _Disclosure extends StatefulWidget {
  const _Disclosure({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback? onToggle;

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.slateColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // Opaque so the triangle takes the tap rather than the row underneath
        // it: expanding and selecting are different intentions.
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: SizedBox(
          width: 14,
          child: Center(
            child: SlateIcon(
              widget.expanded
                  ? SlateIcons.chevronDown
                  : SlateIcons.chevronRight,
              size: 11,
              color: _hover ? palette.ink : palette.inkDim,
            ),
          ),
        ),
      ),
    );
  }
}
