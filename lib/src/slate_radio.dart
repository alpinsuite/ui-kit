import 'package:flutter/material.dart';

import 'slate_focus.dart';
import 'slate_palette.dart';
import 'slate_theme.dart';

/// A group of mutually exclusive choices, all of them visible at once.
///
/// **The whole point is that none of them is hidden.** A `SlateSelect` shows
/// one option and puts the rest behind a click, which is right for a long list
/// where the current value is the interesting part — a font, a number format.
/// It is wrong for a small set of alternatives somebody is being asked to
/// *choose between*, because comparing four options means reading four options,
/// and a dropdown makes that a click and a memory test.
///
/// Excel's Insert Cells is the shape this exists for: four choices, all short,
/// and the decision is which one rather than what the current one is.
///
/// **A group rather than a widget per button**, so that exclusivity is
/// structural. Radio buttons that each carry their own `selected` flag are a
/// set of booleans someone has to keep consistent, and the bug is always two of
/// them true at once.
class SlateRadioGroup<T> extends StatelessWidget {
  const SlateRadioGroup({
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.enabledOf,
    this.axis = Axis.vertical,
    super.key,
  });

  /// The chosen one. It does not have to be in [values] — a value that has gone
  /// away leaves nothing selected rather than throwing, which is what a dialog
  /// re-opened on a changed document wants.
  final T value;

  final List<T> values;
  final String Function(T value) labelOf;

  /// Null disables the whole group, as everywhere in this kit.
  final ValueChanged<T>? onChanged;

  /// Which individual options can be chosen. Null means all of them.
  ///
  /// **Disabled rather than absent**, because a choice that vanishes changes
  /// the shape of the dialog between two openings of it and leaves the reader
  /// wondering whether they misremembered. Excel's Insert Cells does hide the
  /// option that would split a merge — the caller can still do that by leaving
  /// it out of [values] — but the default should be the one that keeps the
  /// interface still.
  final bool Function(T value)? enabledOf;

  /// Vertical by default: a column of choices reads as a set, and a row of them
  /// reads as a toolbar.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final SlateThemeData theme = context.slate;
    final List<Widget> buttons = <Widget>[
      for (final T option in values)
        _SlateRadio<T>(
          label: labelOf(option),
          selected: option == value,
          onPressed: onChanged == null || !(enabledOf?.call(option) ?? true)
              ? null
              : () => onChanged!(option),
        ),
    ];

    return axis == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: buttons,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < buttons.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: theme.metrics.gap * 2),
                buttons[i],
              ],
            ],
          );
  }
}

/// One button in a [SlateRadioGroup]. Not public: a radio button on its own is
/// the thing this widget exists to prevent.
class _SlateRadio<T> extends StatefulWidget {
  const _SlateRadio({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  State<_SlateRadio<T>> createState() => _SlateRadioState<T>();
}

class _SlateRadioState<T> extends State<_SlateRadio<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final SlateThemeData theme = context.slate;
    final SlatePalette palette = theme.palette;
    final bool enabled = widget.onPressed != null;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = enabled),
      onExit: (_) => setState(() => _hover = false),
      child: SlateFocusable(
        onPressed: widget.onPressed,
        borderRadius: BorderRadius.circular(theme.metrics.radius),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // The label is part of the target, as it is for a tick box: a 13px
          // circle is a mean thing to ask anyone to hit.
          onTap: widget.onPressed,
          child: Semantics(
            checked: widget.selected,
            label: widget.label,
            inMutuallyExclusiveGroup: true,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: theme.metrics.gap / 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // A ring and a dot rather than a filled disc. A radio button
                  // filled solid like a tick box is one a reader has to look
                  // twice at to tell from one; the hole in the middle is the
                  // whole of what says "one of these".
                  Container(
                    width: 13,
                    height: 13,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.field,
                      border: Border.all(
                        color: !enabled
                            ? palette.fieldBorder
                            : widget.selected
                            ? palette.accent
                            : _hover
                            ? palette.inkDim
                            : palette.fieldBorder,
                      ),
                    ),
                    child: widget.selected
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enabled ? palette.accent : palette.inkDim,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textStyle.copyWith(
                        fontSize: theme.metrics.smallFontSize,
                        color: enabled ? null : palette.inkDim,
                      ),
                    ),
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
