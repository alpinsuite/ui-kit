import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'slate_icons.dart';
import 'slate_menu.dart';
import 'slate_theme.dart';

/// One row of a context menu.
///
/// A value rather than a widget, unlike the menu bar's items. A context menu
/// closes itself before it runs anything — a popup that lingers over the thing
/// it just acted on hides the result — and that is only possible if the menu
/// owns the callback rather than being handed an opaque child.
@immutable
class SlateContextMenuItem {
  const SlateContextMenuItem({
    required this.label,
    this.onPressed,
    this.icon,
    this.shortcut,
  }) : isSeparator = false;

  const SlateContextMenuItem.separator()
    : label = '',
      onPressed = null,
      icon = null,
      shortcut = null,
      isSeparator = true;

  /// Displayed as given. The kit holds no localisations.
  final String label;

  /// Null disables the row; it stays visible, because a command that vanishes
  /// teaches the user it does not exist.
  final VoidCallback? onPressed;

  final SlateIconDraw? icon;
  final String? shortcut;

  final bool isSeparator;
}

/// Shows a context menu at a point on screen.
///
/// Flipped back inside the window when it would otherwise run off the bottom or
/// the right — a menu opened near an edge that spills off it is a menu whose
/// last item cannot be reached, and the last item is often the destructive one.
///
/// Returns when the menu closes, whether by a choice, a click outside or
/// Escape.
Future<void> showSlateContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required List<SlateContextMenuItem> items,
  double width = 200,
}) {
  final overlay = Overlay.of(context);
  final theme = SlateTheme.of(context);
  final completer = Completer<void>();

  late OverlayEntry entry;
  var closed = false;
  void close() {
    if (closed) return;
    closed = true;
    entry.remove();
    completer.complete();
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final size = MediaQuery.sizeOf(overlayContext);
      final height = _heightOf(items, theme);
      final left = globalPosition.dx + width > size.width
          ? (size.width - width - 4).clamp(0.0, size.width)
          : globalPosition.dx;
      final top = globalPosition.dy + height > size.height
          ? (size.height - height - 4).clamp(0.0, size.height)
          : globalPosition.dy;

      return Stack(
        children: <Widget>[
          // The barrier. Opaque so the click that dismisses the menu does not
          // also land on whatever is underneath it.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              onSecondaryTap: close,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: width,
            child: _Panel(
              theme: theme,
              items: items,
              onChosen: (item) {
                close();
                item.onPressed?.call();
              },
              onDismiss: close,
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);
  return completer.future;
}

double _heightOf(List<SlateContextMenuItem> items, SlateThemeData theme) {
  var height = theme.metrics.radius * 2;
  for (final item in items) {
    height += item.isSeparator ? 5 : theme.metrics.rowHeight;
  }
  return height;
}

class _Panel extends StatefulWidget {
  const _Panel({
    required this.theme,
    required this.items,
    required this.onChosen,
    required this.onDismiss,
  });

  final SlateThemeData theme;
  final List<SlateContextMenuItem> items;
  final ValueChanged<SlateContextMenuItem> onChosen;
  final VoidCallback onDismiss;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  final FocusNode _focus = FocusNode(debugLabel: 'context menu');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return SlateTheme(
      data: theme,
      child: Focus(
        focusNode: _focus,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onDismiss();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          type: MaterialType.transparency,
          child: DecoratedBox(
            decoration: theme.popoverDecoration,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: theme.metrics.radius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final item in widget.items)
                    if (item.isSeparator)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          height: 1,
                          color: theme.palette.separator,
                        ),
                      )
                    else
                      SlateMenuItem(
                        label: item.label,
                        shortcut: item.shortcut,
                        // Closing first is the point: the menu must not still
                        // be covering the row it is about to change.
                        onPressed: item.onPressed == null
                            ? null
                            : () => widget.onChosen(item),
                        closesMenu: false,
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
