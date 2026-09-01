import 'package:flutter/material.dart';

import 'slate_focus.dart';
import 'slate_icons.dart';
import 'slate_menu.dart';
import 'slate_metrics.dart';
import 'slate_theme.dart';

/// A button with a default action and a list of alternatives behind a chevron.
///
/// **Two targets, not one**, and that is the whole point: pressing the icon
/// does the thing the reader almost always wants, and the chevron beside it
/// offers the rest. Paste and Paste Special are one gesture and one
/// afterthought, not two equal choices, and a toolbar that spends two buttons
/// on them says otherwise.
///
/// The kit knows nothing about what is in the list. [menuChildren] is whatever
/// the caller wants to put there — the same contract [MenuAnchor] has, so a
/// caller can hand it rows built out of this kit or anything else.
///
/// **Only the half under the pointer lights.** Lighting both together makes a
/// split button look like one wide button, and a reader then discovers the
/// second target by accident. This is the one visible difference from
/// `SlateColorButton`, which is otherwise the same shape — and that one was
/// brought into line rather than left to differ, because the two sit side by
/// side on a real toolbar and two split buttons that behave differently read as
/// a bug in one of them.
class SlateSplitButton extends StatefulWidget {
  const SlateSplitButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.menuChildren,
    this.menuTooltip,
    this.selected = false,
    super.key,
  });

  final SlateIconDraw icon;

  /// On the action half. The chevron gets [menuTooltip], or this one when none
  /// is given — a tooltip that says nothing is worse than one that repeats.
  final String tooltip;
  final String? menuTooltip;

  /// The default action. Null disables *that half only*: a paste button with an
  /// empty clipboard still has alternatives worth opening.
  final VoidCallback? onPressed;

  /// The rows behind the chevron. An empty list disables the chevron.
  final List<Widget> menuChildren;

  /// Drawn pressed, for a default action that is a toggle.
  final bool selected;

  @override
  State<SlateSplitButton> createState() => _SlateSplitButtonState();
}

class _SlateSplitButtonState extends State<SlateSplitButton> {
  final MenuController _controller = MenuController();

  /// The chevron's own focus node, handed to the anchor as well.
  ///
  /// A `MenuAnchor` closes when focus lands outside it, and a focusable trigger
  /// puts a focus node exactly there — so opening the list from the keyboard
  /// would shut it again on the way in. `childFocusNode` is what tells the
  /// anchor this node is part of the menu.
  final FocusNode _chevron = FocusNode(debugLabel: 'SlateSplitButton');

  /// Which half the pointer is over, or null.
  bool _onAction = false;
  bool _onChevron = false;

  @override
  void dispose() {
    _chevron.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SlateThemeData theme = context.slate;
    final SlateMetrics metrics = theme.metrics;
    final bool hasMenu = widget.menuChildren.isNotEmpty;

    Widget half({
      required Widget child,
      required bool lit,
      required VoidCallback? onPressed,
      required String message,
      required EdgeInsets padding,
      FocusNode? focusNode,
      required ValueChanged<bool> onHover,
    }) => MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: Tooltip(
        message: message,
        child: SlateFocusable(
          focusNode: focusNode,
          onPressed: onPressed,
          borderRadius: BorderRadius.circular(metrics.radius),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Container(
              height: metrics.controlHeight,
              alignment: Alignment.center,
              padding: padding,
              decoration: BoxDecoration(
                color: lit ? theme.palette.hover : const Color(0x00000000),
                borderRadius: BorderRadius.circular(metrics.radius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    return SlateMenuScope(
      controller: _controller,
      parent: null,
      child: MenuAnchor(
        controller: _controller,
        childFocusNode: _chevron,
        style: slateMenuStyle(theme),
        alignmentOffset: const Offset(0, 4),
        menuChildren: widget.menuChildren,
        builder: (BuildContext context, MenuController controller, Widget? _) =>
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // **The two halves hug, and the pair keeps its distance from
                // whatever is next.** With symmetric padding the chevron sat as
                // far from its own icon as from the following button, so on a
                // dense toolbar it read as though it might belong to either --
                // seen in a render of cells' bar, where a paste chevron looked
                // like it could be the Format Painter's. Asymmetric padding
                // makes the gap inside the button roughly a fifth of the gap
                // between buttons, which is what says "these two are one
                // control".
                half(
                  message: widget.tooltip,
                  lit: _onAction || widget.selected,
                  onPressed: widget.onPressed,
                  padding: const EdgeInsets.only(left: 3, right: 1),
                  onHover: (bool over) => setState(() => _onAction = over),
                  child: SlateIcon(
                    widget.icon,
                    size: metrics.iconSize,
                    color: widget.onPressed == null
                        ? theme.palette.inkDim
                        : theme.palette.ink,
                  ),
                ),
                // **No list, no chevron.** A disabled chevron is a promise of
                // more that there is no more behind, and the two honest ways to
                // draw one are both wrong here: in `inkDim` it looks live, and
                // in `border` it is all but invisible against `chrome`, which
                // reads as a rendering fault rather than as a disabled control.
                // The button simply degrades to a plain icon button, which is
                // what it is when it has nothing to offer.
                //
                // This is the one place the kit's usual rule — disabled rather
                // than absent, because a command that vanishes teaches the
                // reader it does not exist — does not apply: a chevron is not a
                // command, it is a claim about what is behind it.
                if (hasMenu)
                  half(
                    message: widget.menuTooltip ?? widget.tooltip,
                    lit: _onChevron || controller.isOpen,
                    focusNode: _chevron,
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    padding: const EdgeInsets.only(left: 0, right: 4),
                    onHover: (bool over) => setState(() => _onChevron = over),
                    child: SlateIcon(
                      SlateIcons.chevronDown,
                      size: 10,
                      color: theme.palette.inkDim,
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}
