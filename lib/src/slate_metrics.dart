import 'package:flutter/foundation.dart';

/// Sizes and spacing.
///
/// Every control carries an explicit height. Left to their intrinsic sizes,
/// controls inherit the ambient line height and grow to fill whatever row they
/// are in — which is what makes an interface look inflated even when the type
/// is the right size.
@immutable
class SlateMetrics {
  const SlateMetrics({
    this.radius = 4,
    this.popoverRadius = 6,
    this.rowHeight = 24,
    this.compactRowHeight = 21,
    this.controlHeight = 20,
    this.fieldHeight = 24,
    this.buttonHeight = 24,
    this.barHeight = 30,
    this.windowBarHeight = 36,
    this.activityBarWidth = 48,
    this.tabHeight = 32,
    this.splitterHitExtent = 7,
    this.scrollbarThickness = 11,
    this.fontSize = 13,
    this.smallFontSize = 12,
    this.iconSize = 15,
    this.gap = 8,
    this.pad = 10,
  });

  /// Controls and hover shapes.
  final double radius;

  /// Menus, dropdowns and dialogs, which sit above everything and read better
  /// slightly rounder.
  final double popoverRadius;

  /// A menu row: a command with a shortcut needs the room.
  final double rowHeight;

  /// A row in a value list, which carries less and can be tighter.
  final double compactRowHeight;

  /// Inline controls living inside a bar.
  final double controlHeight;

  /// A text field's height.
  ///
  /// Twenty-four rather than twenty-two: WCAG 2.2's pointer-target criterion
  /// (2.5.8, level AA) is 24×24, and a field is a target — you click it to put
  /// a cursor in it. Two points is not a visible difference and it is the
  /// difference between meeting that criterion and not.
  final double fieldHeight;

  /// A text button's height.
  ///
  /// Twenty-four, for the reason [fieldHeight] is, and it had been missed:
  /// twenty-three is a point under WCAG 2.2's 24×24, and a button is nothing
  /// but a target. Found by an application's accessibility audit the first
  /// time a row of short text buttons was on screen.
  final double buttonHeight;

  /// Tool options and status rows.
  final double barHeight;

  /// The merged title and menu row.
  final double windowBarHeight;

  /// The icon rail down the side of the window.
  final double activityBarWidth;

  /// A document tab. Taller than a bar row: it carries a label and a close
  /// button, and it is a target the user aims at rather than reads.
  final double tabHeight;

  /// How wide a split divider is to the *pointer*.
  ///
  /// The divider is drawn as a hairline, because a visible bar between two
  /// panes is noise. A hairline is also impossible to hit, so the grab area is
  /// this much wider and invisible — the usual gap between what a control looks
  /// like and what it is.
  final double splitterHitExtent;

  /// How wide a scrollbar is.
  ///
  /// Both a visual width and a pointer target, and the pointer wins: a
  /// scrollbar thin enough to look right in a dense build is one nobody can
  /// grab. Eleven is the narrowest that still catches a mouse reliably.
  final double scrollbarThickness;

  final double fontSize;
  final double smallFontSize;
  final double iconSize;

  /// Space between adjacent controls.
  final double gap;

  /// Padding inside a bar or popover.
  final double pad;

  static const SlateMetrics standard = SlateMetrics();

  /// Everything scaled, for a denser or roomier build of the same design.
  SlateMetrics scaled(double factor) {
    return SlateMetrics(
      radius: radius,
      popoverRadius: popoverRadius,
      rowHeight: rowHeight * factor,
      compactRowHeight: compactRowHeight * factor,
      controlHeight: controlHeight * factor,
      fieldHeight: fieldHeight * factor,
      buttonHeight: buttonHeight * factor,
      barHeight: barHeight * factor,
      windowBarHeight: windowBarHeight * factor,
      activityBarWidth: activityBarWidth * factor,
      tabHeight: tabHeight * factor,
      // Deliberately not scaled: these are pointer targets, and a pointer does
      // not get smaller because the interface is dense.
      splitterHitExtent: splitterHitExtent,
      scrollbarThickness: scrollbarThickness,
      fontSize: fontSize * factor,
      smallFontSize: smallFontSize * factor,
      iconSize: iconSize * factor,
      gap: gap * factor,
      pad: pad * factor,
    );
  }
}
