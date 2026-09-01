import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_menu.dart';
import 'slate_theme.dart';

/// The swatches a colour popover offers when the caller does not supply its
/// own.
///
/// Six hues across five tints, plus a greyscale row — the arrangement every
/// office application has settled on, because it is the smallest grid in which
/// people can find "a slightly darker blue" without thinking about numbers.
abstract final class SlateSwatches {
  static const List<Color> greys = <Color>[
    Color(0xFF000000),
    Color(0xFF404040),
    Color(0xFF7F7F7F),
    Color(0xFFBFBFBF),
    Color(0xFFE7E7E7),
    Color(0xFFFFFFFF),
  ];

  /// The base hue of each column.
  static const List<Color> hues = <Color>[
    Color(0xFFC00000),
    Color(0xFFED7D31),
    Color(0xFFFFC000),
    Color(0xFF70AD47),
    Color(0xFF4472C4),
    Color(0xFF7030A0),
  ];

  /// [hues], each lightened then darkened — five rows, mid tone in the middle.
  ///
  /// Computed rather than listed so a change to a hue cannot leave its own
  /// tints behind, pointing at a colour that is no longer in the grid.
  static List<List<Color>> get tints => <List<Color>>[
    for (final factor in <double>[0.6, 0.3, 0, -0.25, -0.5])
      <Color>[for (final hue in hues) _shift(hue, factor)],
  ];

  /// Towards white for a positive [amount], towards black for a negative one.
  static Color _shift(Color color, double amount) {
    if (amount == 0) return color;
    double channel(double from) =>
        amount > 0 ? from + (1 - from) * amount : from * (1 + amount);
    return Color.from(
      alpha: color.a,
      red: channel(color.r),
      green: channel(color.g),
      blue: channel(color.b),
    );
  }
}

/// A grid of colours, shown in a popover.
///
/// The kit knows nothing about what the colour is *for*: every label is a
/// parameter, and "no colour" means whatever the caller says it means —
/// automatic ink to a text tool, no fill to a shape tool.
class SlateColorPopover extends StatelessWidget {
  const SlateColorPopover({
    required this.onPicked,
    this.value,
    this.noColorLabel,
    this.onNoColor,
    this.recents = const <Color>[],
    this.recentsLabel,
    this.swatches,
    super.key,
  });

  /// The colour currently in force, ringed in the grid. Null shows no ring.
  final Color? value;

  final ValueChanged<Color> onPicked;

  /// Shown as a row above the grid when both this and [onNoColor] are given.
  final String? noColorLabel;
  final VoidCallback? onNoColor;

  /// Most recently used first. Nothing is shown when this is empty — a
  /// permanently empty "Recent" heading is a heading that teaches nothing.
  final List<Color> recents;
  final String? recentsLabel;

  /// Overrides the default grid entirely. Rows of equal length.
  final List<List<Color>>? swatches;

  static const double _cell = 18;
  static const double _spacing = 3;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final grid =
        swatches ?? <List<Color>>[SlateSwatches.greys, ...SlateSwatches.tints];

    return Padding(
      padding: EdgeInsets.all(theme.metrics.pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (noColorLabel != null && onNoColor != null) ...<Widget>[
            _NoColorRow(label: noColorLabel!, onPressed: onNoColor!),
            SizedBox(height: theme.metrics.gap),
          ],
          for (final row in grid) ...<Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final color in row)
                  Padding(
                    padding: const EdgeInsets.all(_spacing / 2),
                    child: _Swatch(
                      color: color,
                      selected: value == color,
                      onPressed: () => onPicked(color),
                    ),
                  ),
              ],
            ),
          ],
          if (recents.isNotEmpty) ...<Widget>[
            SizedBox(height: theme.metrics.gap),
            if (recentsLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: _spacing / 2),
                child: Text(recentsLabel!, style: theme.dimTextStyle),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final color in recents.take(grid.first.length))
                  Padding(
                    padding: const EdgeInsets.all(_spacing / 2),
                    child: _Swatch(
                      color: color,
                      selected: value == color,
                      onPressed: () => onPicked(color),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatefulWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.slateColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: SlateColorPopover._cell,
          height: SlateColorPopover._cell,
          decoration: BoxDecoration(
            color: widget.color,
            // A ring rather than a check mark: a tick drawn over a swatch has
            // to be light on dark and dark on light, and picking which is a
            // guess that is wrong for the middle of every column.
            border: Border.all(
              color: widget.selected
                  ? palette.accent
                  : _hovered
                  ? palette.ink
                  : palette.border,
              width: widget.selected || _hovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _NoColorRow extends StatelessWidget {
  const _NoColorRow({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          height: theme.metrics.compactRowHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(width: 2),
              SlateIcon(SlateIcons.close, size: 12),
              SizedBox(width: theme.metrics.gap),
              Text(label, style: theme.textStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// A toolbar button that shows a colour and opens a [SlateColorPopover].
///
/// The glyph sits above a band of the current colour, the arrangement every
/// text-colour button uses: pressing the button applies what the band shows,
/// and the chevron beside it is what opens the grid. That is the difference
/// between one click to repeat a colour and two clicks every time.
class SlateColorButton extends StatefulWidget {
  const SlateColorButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
    required this.onPicked,
    this.noColorLabel,
    this.onNoColor,
    this.recents = const <Color>[],
    this.recentsLabel,
    this.swatches,
    super.key,
  });

  final SlateIconDraw icon;
  final String tooltip;

  /// The colour the band shows, and what [onPressed] is expected to apply.
  /// Null draws the band in the border colour — nothing applied yet.
  final Color? color;

  final VoidCallback onPressed;
  final ValueChanged<Color> onPicked;

  final String? noColorLabel;
  final VoidCallback? onNoColor;
  final List<Color> recents;
  final String? recentsLabel;
  final List<List<Color>>? swatches;

  @override
  State<SlateColorButton> createState() => _SlateColorButtonState();
}

class _SlateColorButtonState extends State<SlateColorButton> {
  final MenuController _controller = MenuController();

  /// Which half the pointer is over.
  ///
  /// **One flag for both halves lit them together**, which makes a split button
  /// look like one wide button and leaves the second target to be found by
  /// accident. [SlateSplitButton] is the same shape and lights only the half
  /// under the pointer; two split buttons side by side on a toolbar behaving
  /// differently reads as a bug in one of them.
  bool _onSwatch = false;
  bool _onChevron = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final metrics = theme.metrics;

    return SlateMenuScope(
      controller: _controller,
      parent: null,
      child: MenuAnchor(
        controller: _controller,
        style: slateMenuStyle(theme),
        menuChildren: <Widget>[
          SlateColorPopover(
            value: widget.color,
            noColorLabel: widget.noColorLabel,
            onNoColor: widget.onNoColor == null
                ? null
                : () {
                    _controller.close();
                    widget.onNoColor!();
                  },
            recents: widget.recents,
            recentsLabel: widget.recentsLabel,
            swatches: widget.swatches,
            onPicked: (color) {
              _controller.close();
              widget.onPicked(color);
            },
          ),
        ],
        builder: (context, controller, _) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: widget.tooltip,
            child: SizedBox(
              height: metrics.controlHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MouseRegion(
                    onEnter: (_) => setState(() => _onSwatch = true),
                    onExit: (_) => setState(() => _onSwatch = false),
                    child: GestureDetector(
                      onTap: widget.onPressed,
                      child: Container(
                        color: _onSwatch
                            ? theme.palette.chrome
                            : const Color(0x00000000),
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SlateIcon(widget.icon, size: metrics.iconSize),
                            const SizedBox(height: 1),
                            Container(
                              width: metrics.iconSize,
                              height: 3,
                              color: widget.color ?? theme.palette.border,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _onChevron = true),
                    onExit: (_) => setState(() => _onChevron = false),
                    child: GestureDetector(
                      onTap: () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                      child: Container(
                        color: _onChevron || controller.isOpen
                            ? theme.palette.chrome
                            : const Color(0x00000000),
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SlateIcon(SlateIcons.chevronDown, size: 10),
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
