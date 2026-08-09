import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_theme.dart';

/// One destination on a [SlateActivityBar].
///
/// Carries no notion of what it switches to — the bar reports an index and the
/// application decides what that means.
@immutable
class SlateActivityItem {
  const SlateActivityItem({
    required this.icon,
    required this.tooltip,
    this.badge,
    this.enabled = true,
  });

  final SlateIconDraw icon;

  /// Required, not optional. An icon rail with no names is unusable with a
  /// screen reader and close to unusable without one — an unlabelled glyph is a
  /// guess every time until the user has learned all of them.
  final String tooltip;

  /// A short count or marker drawn over the icon: unread, unresolved, failing.
  /// A string rather than an int so the caller owns the formatting, including
  /// what "more than ninety-nine" looks like in their language.
  final String? badge;

  /// Whether the destination can be reached yet.
  ///
  /// A disabled item is drawn dimmed and stays in place rather than being
  /// dropped from the list. A rail whose items come and go teaches the user
  /// that the missing ones do not exist, and moves the ones that remain out
  /// from under the pointer they had already aimed at.
  final bool enabled;
}

/// The vertical icon rail down the side of the window.
///
/// The pattern editors converged on: a handful of top-level destinations, each
/// a glyph, with the current one marked by an accent rule down its leading
/// edge. Secondary items — settings, about — sit at the bottom, separated by
/// the space between rather than by a line.
class SlateActivityBar extends StatelessWidget {
  const SlateActivityBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.footerItems = const <SlateActivityItem>[],
    this.onFooterSelected,
    super.key,
  });

  final List<SlateActivityItem> items;

  /// Index into [items]. Negative selects nothing, which is what a footer
  /// destination being active looks like.
  final int selectedIndex;

  final ValueChanged<int> onSelected;

  /// Pinned to the bottom. Indexed separately because they are a different
  /// list, not a continuation of the first one.
  final List<SlateActivityItem> footerItems;
  final ValueChanged<int>? onFooterSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return Container(
      width: theme.metrics.activityBarWidth,
      decoration: BoxDecoration(
        color: palette.chrome,
        border: Border(right: BorderSide(color: palette.separator)),
      ),
      child: Column(
        children: <Widget>[
          // Scrolls rather than overflowing. A window short enough to run out
          // of rail is unusual but not impossible — a laptop in a split
          // workspace reaches it — and a rail that overflows drops its last
          // destinations off the bottom with no way to reach them.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < items.length; i++)
                    _ActivityButton(
                      item: items[i],
                      selected: i == selectedIndex,
                      onPressed: () => onSelected(i),
                    ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < footerItems.length; i++)
            _ActivityButton(
              item: footerItems[i],
              selected: false,
              onPressed: () => onFooterSelected?.call(i),
            ),
        ],
      ),
    );
  }
}

class _ActivityButton extends StatefulWidget {
  const _ActivityButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final SlateActivityItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_ActivityButton> createState() => _ActivityButtonState();
}

class _ActivityButtonState extends State<_ActivityButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final width = theme.metrics.activityBarWidth;

    return Tooltip(
      message: widget.item.tooltip,
      child: MouseRegion(
        cursor: widget.item.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.item.enabled ? widget.onPressed : null,
          child: Semantics(
            label: widget.item.tooltip,
            button: true,
            selected: widget.selected,
            enabled: widget.item.enabled,
            child: SizedBox(
              width: width,
              height: width,
              child: Stack(
                children: <Widget>[
                  if (widget.selected)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: palette.accent),
                    ),
                  Center(
                    child: SlateIcon(
                      widget.item.icon,
                      size: theme.metrics.iconSize + 3,
                      color: !widget.item.enabled
                          ? palette.inkDim.withValues(alpha: 0.4)
                          : widget.selected || _hover
                          ? palette.ink
                          : palette.inkDim,
                    ),
                  ),
                  if (widget.item.badge != null)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: _Badge(text: widget.item.badge!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return Container(
      constraints: const BoxConstraints(minWidth: 14),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: theme.palette.accent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textStyle.copyWith(
          color: theme.palette.onAccent,
          fontSize: 10,
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
