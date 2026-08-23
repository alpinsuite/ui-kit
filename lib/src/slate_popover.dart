import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'slate_theme.dart';

/// An anchored overlay holding arbitrary content.
///
/// The kit has [showSlateContextMenu] for a list of items and nothing general:
/// a colour grid, a filter panel, a date picker are all "a small surface
/// attached to a control", and each one written by hand is another place the
/// shadow, the dismiss behaviour and the screen-edge flip are slightly
/// different.
///
/// # It flips rather than clamping
///
/// A popover that would run off the bottom is drawn *above* its anchor, not
/// squashed against the edge — a panel jammed into the last twenty pixels of
/// the screen is unusable, and a person on a laptop meets it constantly because
/// the control they clicked was near the bottom.
///
/// # Dismissed by anything
///
/// A tap outside, Escape, or the caller. A popover that could only be closed by
/// clicking its own small button is one people trap themselves in.
Future<T?> showSlatePopover<T>({
  required BuildContext context,
  required Rect anchor,
  required Widget Function(BuildContext context, void Function(T?) close)
  builder,
  double width = 240,
  double maxHeight = 320,
}) {
  final OverlayState overlay = Overlay.of(context);
  final SlateThemeData theme = SlateTheme.of(context);
  final Completer<T?> completer = Completer<T?>();

  late OverlayEntry entry;
  bool closed = false;
  void close(T? result) {
    if (closed) return;
    closed = true;
    entry.remove();
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      final Size screen = MediaQuery.sizeOf(overlayContext);
      // Below the anchor when there is room, above it when there is not.
      final double below = screen.height - anchor.bottom;
      final bool flip = below < maxHeight && anchor.top > below;
      final double top = flip
          ? (anchor.top - maxHeight).clamp(0.0, screen.height)
          : anchor.bottom;
      // Left-aligned with the anchor, pulled in when that would overflow.
      final double left =
          (anchor.left + width > screen.width
                  ? screen.width - width - 4
                  : anchor.left)
              .clamp(0.0, screen.width);

      return Stack(
        children: <Widget>[
          // The dismiss layer, over everything and under the panel.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => close(null),
              child: const SizedBox.shrink(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: width,
            child: Focus(
              autofocus: true,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  close(null);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Material(
                color: const Color(0x00000000),
                child: Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: theme.popoverDecoration,
                  clipBehavior: Clip.antiAlias,
                  child: builder(overlayContext, close),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);
  return completer.future;
}
