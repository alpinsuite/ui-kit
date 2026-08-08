import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_theme.dart';

/// One document tab.
@immutable
class SlateTab {
  const SlateTab({
    required this.id,
    required this.label,
    this.modified = false,
    this.tooltip,
    this.leading,
  });

  /// Identifies the tab to the caller. The strip never interprets it.
  final String id;

  final String label;

  /// Draws a dot in place of the close button until the pointer is over it —
  /// the convention every editor uses for "this has unsaved changes".
  final bool modified;

  /// Usually the full path, where the label is only the file name.
  final String? tooltip;

  /// A small glyph before the label, for a state the label cannot carry:
  /// locked, read-only, in error.
  ///
  /// Deliberately a glyph rather than a widget. A tab is a dense row with a
  /// fixed height, and letting the caller put arbitrary content in it is how
  /// one tab ends up taller than its neighbours.
  final SlateIconDraw? leading;
}

/// The row of document tabs across the top of the main view.
///
/// Scrolls horizontally when there are more tabs than room. It does not
/// truncate the list or collapse into a menu: a tab that has silently vanished
/// is worse than one the user has to scroll to.
class SlateTabStrip extends StatelessWidget {
  const SlateTabStrip({
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
    this.onClosed,
    this.closeTooltip,
    this.trailing = const <Widget>[],
    super.key,
  });

  final List<SlateTab> tabs;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Omit to make tabs uncloseable — the close affordance disappears with it.
  final ValueChanged<String>? onClosed;

  /// The close button's accessible name. A parameter because the kit ships no
  /// localisations, and a button whose only label is an X is unusable with a
  /// screen reader.
  final String? closeTooltip;

  /// Controls pinned to the trailing edge, after the tabs.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return Container(
      height: theme.metrics.tabHeight,
      decoration: BoxDecoration(
        color: palette.chrome,
        border: Border(bottom: BorderSide(color: palette.separator)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                // A Row inside a horizontal scroll view has an unbounded main
                // axis: it must size to its children and cannot hold a Spacer.
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final tab in tabs)
                    _Tab(
                      tab: tab,
                      selected: tab.id == selectedId,
                      onSelected: () => onSelected(tab.id),
                      onClosed: onClosed == null
                          ? null
                          : () => onClosed!(tab.id),
                      closeTooltip: closeTooltip,
                    ),
                ],
              ),
            ),
          ),
          ...trailing,
        ],
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.tab,
    required this.selected,
    required this.onSelected,
    required this.onClosed,
    required this.closeTooltip,
  });

  final SlateTab tab;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback? onClosed;
  final String? closeTooltip;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hover = false;
  bool _hoverClose = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    final background = widget.selected
        ? palette.background
        : _hover
        ? palette.hover
        : const Color(0x00000000);

    Widget affordance = const SizedBox(width: 16, height: 16);
    if (widget.onClosed != null) {
      // The dot becomes the close button on hover, so a modified document does
      // not need two glyphs competing for the same corner.
      final showClose = _hover || !widget.tab.modified;
      affordance = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoverClose = true),
        onExit: (_) => setState(() => _hoverClose = false),
        child: GestureDetector(
          onTap: widget.onClosed,
          child: Semantics(
            label: widget.closeTooltip,
            button: true,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _hoverClose ? palette.selected : const Color(0x00000000),
                borderRadius: BorderRadius.circular(theme.metrics.radius),
              ),
              child: showClose
                  ? SlateIcon(
                      SlateIcons.close,
                      size: 10,
                      color: _hoverClose ? palette.ink : palette.inkDim,
                    )
                  : Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: palette.inkDim,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onSelected,
        child: Tooltip(
          message: widget.tab.tooltip ?? widget.tab.label,
          child: Semantics(
            label: widget.tab.label,
            button: true,
            selected: widget.selected,
            child: Container(
              height: theme.metrics.tabHeight,
              constraints: const BoxConstraints(maxWidth: 220),
              padding: EdgeInsets.symmetric(horizontal: theme.metrics.pad),
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  right: BorderSide(color: palette.separator),
                  // The selected tab is joined to the view below it by the
                  // accent rule on top, which is what makes the two read as one
                  // surface rather than a card floating over a bar.
                  top: BorderSide(
                    color: widget.selected
                        ? palette.accent
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.tab.leading case final leading?) ...<Widget>[
                    SlateIcon(leading, size: 12, color: palette.inkDim),
                    SizedBox(width: theme.metrics.gap / 2),
                  ],
                  Flexible(
                    child: Text(
                      widget.tab.label,
                      overflow: TextOverflow.ellipsis,
                      style: widget.selected
                          ? theme.textStyle
                          : theme.textStyle.copyWith(color: palette.inkDim),
                    ),
                  ),
                  SizedBox(width: theme.metrics.gap / 2),
                  affordance,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
