import 'package:flutter/material.dart';

import 'slate_theme.dart';

/// Makes a control reachable by keyboard, and shows where the keyboard is.
///
/// Every control in this kit was a bare `GestureDetector`: clickable, and
/// invisible to `Tab`. A desktop widget kit whose buttons cannot be reached
/// without a mouse is not finished, and it is the kind of gap that is invisible
/// to anyone testing with one.
///
/// The ring only appears for **keyboard** focus. Flutter's focus-highlight mode
/// tracks how the user last interacted, so clicking a button does not leave a
/// ring behind it — which is the thing that makes rings look like noise and
/// gets them removed again.
///
/// A disabled control is not a tab stop. Landing on something that cannot be
/// activated is a dead end the reader has to tab out of, and it says nothing
/// that the greyed-out drawing has not already said.
class SlateFocusable extends StatefulWidget {
  const SlateFocusable({
    super.key,
    required this.child,
    required this.onPressed,
    this.focusNode,
    this.borderRadius,
    this.autofocus = false,
  });

  final Widget child;

  /// Null means disabled, matching every control in this kit.
  final VoidCallback? onPressed;

  final FocusNode? focusNode;

  /// Matched to the control's own corners, or the ring sits proud of it.
  final BorderRadius? borderRadius;

  final bool autofocus;

  @override
  State<SlateFocusable> createState() => _SlateFocusableState();
}

class _SlateFocusableState extends State<SlateFocusable> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (bool v) {
        if (v != _focused) setState(() => _focused = v);
      },
      actions: <Type, Action<Intent>>{
        // Enter and Space both, because both are what a focused control is
        // expected to answer and which one a person reaches for depends on
        // what they learned first.
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent _) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      // An overlay rather than a box around the child. A `Container` with a
      // border insets its child by the border's width, so wrapping every
      // control in one would make all of them two pixels taller than
      // `SlateMetrics` says — permanently, not only while focused. Drawn
      // inside the child's own bounds, the ring costs no space at all.
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_focused)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: Border.all(
                      color: context.slate.palette.accent,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The radius a focus ring should use for a control of this theme.
BorderRadius slateFocusRadius(BuildContext context) =>
    BorderRadius.circular(context.slate.metrics.radius + 1);
