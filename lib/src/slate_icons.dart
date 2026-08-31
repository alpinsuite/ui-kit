import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'slate_theme.dart';

/// Draws one icon into a 16x16 box. [stroke] is pre-configured; a glyph that
/// wants a fill sets `style` on its own copy.
typedef SlateIconDraw = void Function(Canvas canvas, Paint stroke);

/// A thin, uniform icon set drawn as paths rather than shipped as a font.
///
/// Every glyph lives on the same 16-unit grid with the same stroke weight, so
/// the set stays coherent as it grows, scales without a second asset, and takes
/// its colour from the caller. That uniformity is most of what makes an editor
/// interface feel like one piece of software.
abstract final class SlateIcons {
  /// The grid every glyph is drawn on.
  static const double grid = 16;

  static void chevronDown(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(4.5, 6.5)
        ..lineTo(8, 10)
        ..lineTo(11.5, 6.5),
      stroke,
    );
  }

  static void chevronRight(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(6.5, 4.5)
        ..lineTo(10, 8)
        ..lineTo(6.5, 11.5),
      stroke,
    );
  }

  static void chevronUp(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(4.5, 9.5)
        ..lineTo(8, 6)
        ..lineTo(11.5, 9.5),
      stroke,
    );
  }

  static void check(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(3.5, 8.5)
        ..lineTo(6.5, 11.5)
        ..lineTo(12.5, 4.5),
      stroke,
    );
  }

  static void close(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(4, 4), const Offset(12, 12), stroke)
      ..drawLine(const Offset(12, 4), const Offset(4, 12), stroke);
  }

  static void minimize(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(3.5, 8), const Offset(12.5, 8), stroke);
  }

  static void maximize(Canvas canvas, Paint stroke) {
    canvas.drawRect(const Rect.fromLTWH(4, 4, 8, 8), stroke);
  }

  static void restore(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(3.5, 5.5, 7, 7), stroke)
      ..drawPath(
        Path()
          ..moveTo(5.8, 5.5)
          ..lineTo(5.8, 3.5)
          ..lineTo(12.5, 3.5)
          ..lineTo(12.5, 10.2)
          ..lineTo(10.5, 10.2),
        stroke,
      );
  }

  static void search(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(7, 7), 4, stroke)
      ..drawLine(const Offset(10, 10), const Offset(13.5, 13.5), stroke);
  }

  static void plus(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(8, 3.5), const Offset(8, 12.5), stroke)
      ..drawLine(const Offset(3.5, 8), const Offset(12.5, 8), stroke);
  }

  static void minus(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(3.5, 8), const Offset(12.5, 8), stroke);
  }

  /// An arrow out of a tray: something local is going somewhere else.
  ///
  /// The mirror of [download] — same tray, arrow reversed — because the pair is
  /// only legible as a pair. An upload drawn with a different tray reads as a
  /// different kind of action.
  static void upload(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(8, 10)
          ..lineTo(8, 2.5)
          ..moveTo(4.5, 6)
          ..lineTo(8, 2.5)
          ..lineTo(11.5, 6),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(3, 11.5)
          ..lineTo(3, 13.5)
          ..lineTo(13, 13.5)
          ..lineTo(13, 11.5),
        stroke,
      );
  }

  /// An arrow into a tray: something newer is available.
  static void download(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(8, 2.5)
          ..lineTo(8, 10)
          ..moveTo(4.5, 6.5)
          ..lineTo(8, 10)
          ..lineTo(11.5, 6.5),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(3, 11.5)
          ..lineTo(3, 13.5)
          ..lineTo(13, 13.5)
          ..lineTo(13, 11.5),
        stroke,
      );
  }

  static void copy(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(5.5, 5.5, 7, 7), stroke)
      ..drawPath(
        Path()
          ..moveTo(10.5, 3.5)
          ..lineTo(3.5, 3.5)
          ..lineTo(3.5, 10.5),
        stroke,
      );
  }

  /// Fit the image to the window: a frame with arrows pointing outward.
  static void fitScreen(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3, 6)
          ..lineTo(3, 3)
          ..lineTo(6, 3),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(10, 3)
          ..lineTo(13, 3)
          ..lineTo(13, 6),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(13, 10)
          ..lineTo(13, 13)
          ..lineTo(10, 13),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(6, 13)
          ..lineTo(3, 13)
          ..lineTo(3, 10),
        stroke,
      );
  }

  /// Actual size: a frame with a 1:1 mark inside.
  static void actualSize(Canvas canvas, Paint stroke) {
    canvas.drawRect(const Rect.fromLTWH(2.5, 3.5, 11, 9), stroke);
    canvas.drawLine(const Offset(6.5, 6.5), const Offset(6.5, 9.5), stroke);
    canvas.drawLine(const Offset(9.5, 6.5), const Offset(9.5, 9.5), stroke);
  }

  /// Swap two things: two arrows head to tail.
  static void swap(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(3, 6), const Offset(12, 6), stroke)
      ..drawPath(
        Path()
          ..moveTo(10, 4)
          ..lineTo(12.5, 6)
          ..lineTo(10, 8),
        stroke,
      )
      ..drawLine(const Offset(13, 10), const Offset(4, 10), stroke)
      ..drawPath(
        Path()
          ..moveTo(6, 8)
          ..lineTo(3.5, 10)
          ..lineTo(6, 12),
        stroke,
      );
  }

  // Text formatting. Letterforms rather than abstractions, because that is what
  // every editor uses and recognition beats novelty for a control this common.

  static void bold(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(5, 3.5)
        ..lineTo(9, 3.5)
        ..cubicTo(11.7, 3.5, 11.7, 8, 9, 8)
        ..lineTo(5, 8)
        ..lineTo(5, 3.5)
        ..moveTo(5, 8)
        ..lineTo(9.6, 8)
        ..cubicTo(12.5, 8, 12.5, 12.5, 9.6, 12.5)
        ..lineTo(5, 12.5)
        ..lineTo(5, 8),
      stroke,
    );
  }

  static void italic(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(6.5, 3.5), const Offset(12.5, 3.5), stroke)
      ..drawLine(const Offset(3.5, 12.5), const Offset(9.5, 12.5), stroke)
      ..drawLine(const Offset(9.5, 3.5), const Offset(6.5, 12.5), stroke);
  }

  static void underline(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(4.5, 3)
          ..lineTo(4.5, 7.5)
          ..cubicTo(4.5, 12.4, 11.5, 12.4, 11.5, 7.5)
          ..lineTo(11.5, 3),
        stroke,
      )
      ..drawLine(const Offset(3.5, 13.2), const Offset(12.5, 13.2), stroke);
  }

  static void alignLeft(Canvas canvas, Paint stroke) =>
      _alignRows(canvas, stroke, -1);

  static void alignCenter(Canvas canvas, Paint stroke) =>
      _alignRows(canvas, stroke, 0);

  static void alignRight(Canvas canvas, Paint stroke) =>
      _alignRows(canvas, stroke, 1);

  /// Four lines of "text", every other one short. [side] is -1 for left, 0 for
  /// centred, 1 for right — which is the only thing that differs between the
  /// three glyphs.
  static void _alignRows(Canvas canvas, Paint stroke, int side) {
    const full = 10.0;
    const short = 6.5;
    for (var row = 0; row < 4; row++) {
      final width = row.isEven ? full : short;
      final left = switch (side) {
        -1 => 3.0,
        0 => 3.0 + (full - width) / 2,
        _ => 3.0 + (full - width),
      };
      final y = 4.0 + row * 2.7;
      canvas.drawLine(Offset(left, y), Offset(left + width, y), stroke);
    }
  }

  static void palette(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..addArc(
          const Rect.fromLTWH(2.5, 2.5, 11, 11),
          -math.pi / 2,
          math.pi * 1.6,
        )
        ..lineTo(9.5, 11)
        ..lineTo(11.5, 13),
      stroke,
    );
    final dot = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(6, 6), 1, dot);
    canvas.drawCircle(const Offset(9.6, 5.4), 1, dot);
  }

  // Navigation.

  static void chevronLeft(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(9.5, 4.5)
        ..lineTo(6, 8)
        ..lineTo(9.5, 11.5),
      stroke,
    );
  }

  static void arrowLeft(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(13, 8), const Offset(3, 8), stroke)
      ..drawPath(
        Path()
          ..moveTo(7, 4)
          ..lineTo(3, 8)
          ..lineTo(7, 12),
        stroke,
      );
  }

  static void arrowRight(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(3, 8), const Offset(13, 8), stroke)
      ..drawPath(
        Path()
          ..moveTo(9, 4)
          ..lineTo(13, 8)
          ..lineTo(9, 12),
        stroke,
      );
  }

  /// An arrow doubling back on itself.
  static void undo(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(6, 4.5)
          ..lineTo(2.8, 7.5)
          ..lineTo(6, 10.5),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(2.8, 7.5)
          ..lineTo(9.3, 7.5)
          ..cubicTo(12.8, 7.5, 12.8, 13, 8.8, 13),
        stroke,
      );
  }

  static void redo(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(10, 4.5)
          ..lineTo(13.2, 7.5)
          ..lineTo(10, 10.5),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(13.2, 7.5)
          ..lineTo(6.7, 7.5)
          ..cubicTo(3.2, 7.5, 3.2, 13, 7.2, 13),
        stroke,
      );
  }

  // Zoom. The magnifier is [search]'s, so the three read as one family.

  static void zoomIn(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(7, 7), 4, stroke)
      ..drawLine(const Offset(10, 10), const Offset(13.5, 13.5), stroke)
      ..drawLine(const Offset(4.9, 7), const Offset(9.1, 7), stroke)
      ..drawLine(const Offset(7, 4.9), const Offset(7, 9.1), stroke);
  }

  static void zoomOut(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(7, 7), 4, stroke)
      ..drawLine(const Offset(10, 10), const Offset(13.5, 13.5), stroke)
      ..drawLine(const Offset(4.9, 7), const Offset(9.1, 7), stroke);
  }

  // Panels and layout.

  /// A frame with a rule near one edge: a collapsible side panel.
  static void sidebar(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(2.5, 3.5, 11, 9), stroke)
      ..drawLine(const Offset(6.5, 3.5), const Offset(6.5, 12.5), stroke);
  }

  /// Four tiles: a thumbnail grid. Not `grid`, which is the 16-unit
  /// authoring grid every glyph is drawn against.
  static void tiles(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(2.5, 2.5, 5, 5), stroke)
      ..drawRect(const Rect.fromLTWH(8.5, 2.5, 5, 5), stroke)
      ..drawRect(const Rect.fromLTWH(2.5, 8.5, 5, 5), stroke)
      ..drawRect(const Rect.fromLTWH(8.5, 8.5, 5, 5), stroke);
  }

  /// Bulleted rows: an outline or a list of items.
  static void list(Canvas canvas, Paint stroke) {
    final dot = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;
    for (final y in const <double>[4.5, 8, 11.5]) {
      canvas
        ..drawCircle(Offset(3.6, y), 0.9, dot)
        ..drawLine(Offset(6.4, y), Offset(13, y), stroke);
    }
  }

  // Page operations.

  static void rotateRight(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()..addArc(
          const Rect.fromLTWH(3, 3, 10, 10),
          -math.pi * 0.35,
          math.pi * 1.7,
        ),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(9.9, 2.4)
          ..lineTo(13.3, 4.4)
          ..lineTo(10.2, 6.7),
        stroke,
      );
  }

  static void rotateLeft(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()..addArc(
          const Rect.fromLTWH(3, 3, 10, 10),
          math.pi * 1.35,
          -math.pi * 1.7,
        ),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(6.1, 2.4)
          ..lineTo(2.7, 4.4)
          ..lineTo(5.8, 6.7),
        stroke,
      );
  }

  static void trash(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(2.5, 4.5), const Offset(13.5, 4.5), stroke)
      ..drawPath(
        Path()
          ..moveTo(6, 4.5)
          ..lineTo(6, 2.8)
          ..lineTo(10, 2.8)
          ..lineTo(10, 4.5),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(4.1, 4.5)
          ..lineTo(4.9, 13.2)
          ..lineTo(11.1, 13.2)
          ..lineTo(11.9, 4.5),
        stroke,
      )
      ..drawLine(const Offset(6.7, 6.9), const Offset(6.9, 11.1), stroke)
      ..drawLine(const Offset(9.3, 6.9), const Offset(9.1, 11.1), stroke);
  }

  /// A sheet with a folded corner.
  static void file(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3.5, 2.5)
          ..lineTo(9.5, 2.5)
          ..lineTo(12.5, 5.5)
          ..lineTo(12.5, 13.5)
          ..lineTo(3.5, 13.5)
          ..close(),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(9.5, 2.5)
          ..lineTo(9.5, 5.5)
          ..lineTo(12.5, 5.5),
        stroke,
      );
  }

  static void folder(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(2.5, 12.5)
        ..lineTo(2.5, 3.5)
        ..lineTo(6.4, 3.5)
        ..lineTo(7.9, 5.5)
        ..lineTo(13.5, 5.5)
        ..lineTo(13.5, 12.5)
        ..close(),
      stroke,
    );
  }

  /// A diskette. Deliberately not the arrow-into-a-tray of [download], which
  /// already means "something newer is available" in this set.
  static void save(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3, 12.8)
          ..lineTo(3, 3.2)
          ..lineTo(10.6, 3.2)
          ..lineTo(13, 5.6)
          ..lineTo(13, 12.8)
          ..close(),
        stroke,
      )
      ..drawRect(const Rect.fromLTWH(5.6, 3.2, 4.6, 3.1), stroke)
      ..drawRect(const Rect.fromLTWH(5.2, 9, 5.6, 3.8), stroke);
  }

  static void print(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(4.5, 6.2)
          ..lineTo(4.5, 2.5)
          ..lineTo(11.5, 2.5)
          ..lineTo(11.5, 6.2),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(4.5, 11.2)
          ..lineTo(2.5, 11.2)
          ..lineTo(2.5, 6.2)
          ..lineTo(13.5, 6.2)
          ..lineTo(13.5, 11.2)
          ..lineTo(11.5, 11.2),
        stroke,
      )
      ..drawRect(const Rect.fromLTWH(4.5, 9.4, 7, 4.1), stroke);
  }

  // State.

  static void lock(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(3.5, 7.2, 9, 6.3), stroke)
      ..drawPath(
        Path()
          ..moveTo(5.6, 7.2)
          ..lineTo(5.6, 5.6)
          ..arcToPoint(
            const Offset(10.4, 5.6),
            radius: const Radius.circular(2.4),
          )
          ..lineTo(10.4, 7.2),
        stroke,
      );
  }

  static void info(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(8, 8), 5.5, stroke)
      ..drawLine(const Offset(8, 7.2), const Offset(8, 11.2), stroke)
      ..drawCircle(
        const Offset(8, 4.9),
        0.85,
        Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill,
      );
  }

  // Editing.

  static void pencil(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(2.8, 13.2)
          ..lineTo(3.9, 9.9)
          ..lineTo(10.6, 3.2)
          ..lineTo(12.8, 5.4)
          ..lineTo(6.1, 12.1)
          ..close(),
        stroke,
      )
      ..drawLine(const Offset(9.5, 4.3), const Offset(11.7, 6.5), stroke);
  }

  /// Stacked sheets seen at an angle: combining several things into one.
  static void layers(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(8, 2)
          ..lineTo(13.5, 5)
          ..lineTo(8, 8)
          ..lineTo(2.5, 5)
          ..close(),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(2.5, 8)
          ..lineTo(8, 11)
          ..lineTo(13.5, 8),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(2.5, 11)
          ..lineTo(8, 14)
          ..lineTo(13.5, 11),
        stroke,
      );
  }

  static void eye(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(1.8, 8)
          ..quadraticBezierTo(8, 2.6, 14.2, 8)
          ..quadraticBezierTo(8, 13.4, 1.8, 8)
          ..close(),
        stroke,
      )
      ..drawCircle(const Offset(8, 8), 2.2, stroke);
  }

  /// A written mark over a rule.
  static void signature(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3, 10.8)
          ..cubicTo(4.5, 3.2, 6.6, 2.4, 6.9, 5.6)
          ..cubicTo(7.2, 9, 4.8, 11.2, 6.4, 10.2)
          ..cubicTo(8.2, 9.1, 9.6, 6.6, 12.8, 6.6),
        stroke,
      )
      ..drawLine(const Offset(2.5, 13.2), const Offset(13.5, 13.2), stroke);
  }

  /// An I-beam: the text selection tool.
  static void textCursor(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(8, 3.5), const Offset(8, 12.5), stroke)
      ..drawLine(const Offset(6, 3.5), const Offset(10, 3.5), stroke)
      ..drawLine(const Offset(6, 12.5), const Offset(10, 12.5), stroke);
  }

  // Planning and scheduling. A tool that shows work over time needs a vocabulary
  // for it, and these are the nouns: a calendar, bars on a timeline, a
  // milestone, a person to do the work, a baseline to compare against.

  /// A month grid: the working-time editor.
  static void calendar(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTRB(2.5, 3.5, 13.5, 13.5), stroke)
      ..drawLine(const Offset(2.5, 6.5), const Offset(13.5, 6.5), stroke)
      ..drawLine(const Offset(5.5, 2), const Offset(5.5, 5), stroke)
      ..drawLine(const Offset(10.5, 2), const Offset(10.5, 5), stroke);
  }

  /// Bars staggered across a timeline.
  static void envelope(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTRB(2.5, 4, 13.5, 12), stroke)
      // The flap stops just inside the top edge rather than on it, so the two
      // strokes do not double up into a thick line at this size.
      ..drawPath(
        Path()
          ..moveTo(2.5, 4.6)
          ..lineTo(8, 8.6)
          ..lineTo(13.5, 4.6),
        stroke,
      );
  }

  static void person(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(8, 5.6), 2.4, stroke)
      ..drawPath(
        Path()
          ..moveTo(3.2, 13.5)
          ..cubicTo(3.2, 10.6, 5.3, 9.6, 8, 9.6)
          ..cubicTo(10.7, 9.6, 12.8, 10.6, 12.8, 13.5),
        stroke,
      );
  }

  static void reply(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(6.5, 3.5)
          ..lineTo(2.5, 7)
          ..lineTo(6.5, 10.5),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(2.5, 7)
          ..lineTo(9, 7)
          ..cubicTo(12.2, 7, 13.5, 9.2, 13.5, 13),
        stroke,
      );
  }

  static void send(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(14, 2.5)
          ..lineTo(2, 7.2)
          ..lineTo(7, 9)
          ..lineTo(8.8, 14)
          ..close(),
        stroke,
      )
      // The fold: what separates a paper plane from a triangle.
      ..drawLine(const Offset(7, 9), const Offset(14, 2.5), stroke);
  }

  static void flag(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(4, 2.5), const Offset(4, 13.5), stroke)
      ..drawPath(
        Path()
          ..moveTo(4, 3.5)
          ..lineTo(12.5, 3.5)
          ..lineTo(10.4, 6.5)
          ..lineTo(12.5, 9.5)
          ..lineTo(4, 9.5),
        stroke,
      );
  }

  static void gantt(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(3, 4.5), const Offset(10, 4.5), stroke)
      ..drawLine(const Offset(6, 8), const Offset(13, 8), stroke)
      ..drawLine(const Offset(3, 11.5), const Offset(9, 11.5), stroke);
  }

  /// The diamond a zero-duration task is drawn as.
  static void milestone(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(8, 2.8)
        ..lineTo(13.2, 8)
        ..lineTo(8, 13.2)
        ..lineTo(2.8, 8)
        ..close(),
      stroke,
    );
  }

  /// A person: the work resource.
  static void resource(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(8, 5.8), 2.6, stroke)
      ..drawPath(
        Path()
          ..moveTo(2.8, 13.4)
          ..quadraticBezierTo(8, 9.2, 13.2, 13.4),
        stroke,
      );
  }

  /// Two offset bars: the plan against the baseline it is measured from.
  static void baseline(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTWH(2.5, 3.8, 9, 3.4), stroke)
      ..drawRect(const Rect.fromLTWH(5, 8.8, 9, 3.4), stroke);
  }

  /// A triangle and a bang: something in the plan does not add up.
  static void warning(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(8, 2.6)
          ..lineTo(14.2, 13.4)
          ..lineTo(1.8, 13.4)
          ..close(),
        stroke,
      )
      ..drawLine(const Offset(8, 6.6), const Offset(8, 9.8), stroke)
      ..drawLine(const Offset(8, 11.4), const Offset(8, 11.7), stroke);
  }

  /// A sheet with a chart on it.
  static void report(Canvas canvas, Paint stroke) {
    canvas
      ..drawRect(const Rect.fromLTRB(3, 2.5, 13, 13.5), stroke)
      ..drawLine(const Offset(5.5, 10.8), const Offset(5.5, 8), stroke)
      ..drawLine(const Offset(8, 10.8), const Offset(8, 5.6), stroke)
      ..drawLine(const Offset(10.5, 10.8), const Offset(10.5, 7), stroke);
  }

  /// A cog: preferences.
  static void settings(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(8, 8), 2.4, stroke);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      canvas.drawLine(
        Offset(8 + dx * 4.1, 8 + dy * 4.1),
        Offset(8 + dx * 5.9, 8 + dy * 5.9),
        stroke,
      );
    }
  }

  /// Two chain links: the dependency between two tasks.
  static void link(Canvas canvas, Paint stroke) {
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.2, 6, 7.2, 4),
          const Radius.circular(2),
        ),
        stroke,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(6.6, 6, 7.2, 4),
          const Radius.circular(2),
        ),
        stroke,
      );
  }

  /// A paperclip: attaching something to what is being written.
  ///
  /// Drawn as one open stroke rather than a closed shape — the gap at the
  /// bottom left is what reads as a clip rather than a bent tube, and it is the
  /// first thing to go when a paperclip is drawn too small to keep it.
  static void paperclip(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(14.09, 7.77)
        ..lineTo(7.97, 13.89)
        ..arcToPoint(const Offset(2.31, 8.23), radius: const Radius.circular(4))
        ..lineTo(8.43, 2.11)
        ..arcToPoint(
          const Offset(12.21, 5.88),
          radius: const Radius.circular(2.67),
        )
        ..lineTo(6.07, 12.01)
        ..arcToPoint(
          const Offset(4.19, 10.12),
          radius: const Radius.circular(1.33),
        )
        ..lineTo(9.85, 4.47),
      stroke,
    );
  }

  /// A funnel: narrowing a list to what matters.
  static void filter(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(2.5, 3.2)
        ..lineTo(13.5, 3.2)
        ..lineTo(9.2, 8.4)
        ..lineTo(9.2, 13.2)
        ..lineTo(6.8, 11.8)
        ..lineTo(6.8, 8.4)
        ..close(),
      stroke,
    );
  }

  /// Push a row one level deeper in an outline.
  static void indentIncrease(Canvas canvas, Paint stroke) {
    _indent(canvas, stroke, pointingRight: true);
  }

  /// Pull a row one level out of an outline.
  static void indentDecrease(Canvas canvas, Paint stroke) {
    _indent(canvas, stroke, pointingRight: false);
  }

  static void _indent(
    Canvas canvas,
    Paint stroke, {
    required bool pointingRight,
  }) {
    canvas
      ..drawLine(const Offset(2.5, 3.5), const Offset(13.5, 3.5), stroke)
      ..drawLine(const Offset(7, 8), const Offset(13.5, 8), stroke)
      ..drawLine(const Offset(2.5, 12.5), const Offset(13.5, 12.5), stroke)
      ..drawPath(
        pointingRight
            ? (Path()
                ..moveTo(2.5, 5.8)
                ..lineTo(4.9, 8)
                ..lineTo(2.5, 10.2))
            : (Path()
                ..moveTo(4.9, 5.8)
                ..lineTo(2.5, 8)
                ..lineTo(4.9, 10.2)),
        stroke,
      );
  }

  /// The longest path through a network, drawn as nodes on a run.
  static void criticalPath(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(4.2, 11.6), const Offset(7.6, 7.6), stroke)
      ..drawLine(const Offset(8.4, 6.8), const Offset(11.6, 4.4), stroke)
      ..drawCircle(const Offset(3.2, 12.5), 1.3, stroke)
      ..drawCircle(const Offset(8, 7.2), 1.3, stroke)
      ..drawCircle(const Offset(12.6, 3.6), 1.3, stroke);
  }

  // Media transport.

  /// Filled rather than stroked, and so is [pause].
  ///
  /// A transport control is read at a glance, often at the edge of vision while
  /// something else holds the attention, and a hairline triangle does not
  /// survive that. These two are the only glyphs in the set that carry weight
  /// on purpose.
  ///
  /// The triangle sits slightly right of the box's centre because a shape that
  /// points reads as centred when its area is, not when its bounds are.
  static void play(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(5.2, 3.4)
        ..lineTo(12.8, 8)
        ..lineTo(5.2, 12.6)
        ..close(),
      Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  static void pause(Canvas canvas, Paint stroke) {
    final fill = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas
      ..drawRRect(
        RRect.fromLTRBR(4.6, 3.6, 6.9, 12.4, const Radius.circular(0.6)),
        fill,
      )
      ..drawRRect(
        RRect.fromLTRBR(9.1, 3.6, 11.4, 12.4, const Radius.circular(0.6)),
        fill,
      );
  }

  /// A speaker with two waves. Pairs with [volumeOff].
  static void volume(Canvas canvas, Paint stroke) {
    _speaker(canvas, stroke);
    canvas
      ..drawArc(
        Rect.fromCircle(center: const Offset(8.4, 8), radius: 2.6),
        -math.pi / 3,
        2 * math.pi / 3,
        false,
        stroke,
      )
      ..drawArc(
        Rect.fromCircle(center: const Offset(8.4, 8), radius: 4.6),
        -math.pi / 3,
        2 * math.pi / 3,
        false,
        stroke,
      );
  }

  /// A speaker with the waves struck through — muted.
  ///
  /// A cross rather than a single slash: at 16 pixels a slash reads as one more
  /// wave, which is the opposite of the meaning.
  static void volumeOff(Canvas canvas, Paint stroke) {
    _speaker(canvas, stroke);
    canvas
      ..drawLine(const Offset(10.2, 6.2), const Offset(13.6, 9.8), stroke)
      ..drawLine(const Offset(13.6, 6.2), const Offset(10.2, 9.8), stroke);
  }

  /// The cone shared by [volume] and [volumeOff], so the two cannot drift.
  static void _speaker(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(3, 6.2)
        ..lineTo(5.2, 6.2)
        ..lineTo(8, 3.4)
        ..lineTo(8, 12.6)
        ..lineTo(5.2, 9.8)
        ..lineTo(3, 9.8)
        ..close(),
      stroke,
    );
  }

  // --- word processing ------------------------------------------------------

  /// An S with a rule through it. The rule carries the meaning, so it runs the
  /// full width while the letter stays narrow.
  static void strikethrough(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(10.8, 5.1)
          ..cubicTo(10.2, 3.6, 5.6, 3.2, 5.6, 6)
          ..cubicTo(5.6, 7.2, 7, 7.6, 8, 8)
          ..moveTo(8, 8)
          ..cubicTo(9.6, 8.5, 10.6, 9, 10.6, 10.2)
          ..cubicTo(10.6, 12.8, 6, 12.6, 5.2, 11.1),
        stroke,
      )
      ..drawLine(const Offset(2.8, 8), const Offset(13.2, 8), stroke);
  }

  /// Three numbered rows.
  ///
  /// The numerals are paths rather than type: a font at this size would not
  /// match the set's weight, and it would be the one glyph that changed shape
  /// when the ambient text style did. Each is kept inside a band 3 units tall
  /// centred on its own row — drawn any larger they touch, and three touching
  /// numerals read as one squiggle.
  static void numberedList(Canvas canvas, Paint stroke) {
    const rows = <double>[3.3, 8, 12.7];
    for (final y in rows) {
      canvas.drawLine(Offset(7.2, y), Offset(13.4, y), stroke);
    }

    // 1
    canvas
      ..drawLine(
        Offset(3.8, rows[0] - 1.25),
        Offset(3.8, rows[0] + 1.25),
        stroke,
      )
      ..drawLine(
        Offset(2.9, rows[0] - 0.7),
        Offset(3.8, rows[0] - 1.25),
        stroke,
      )
      // 2
      ..drawPath(
        Path()
          ..moveTo(2.7, rows[1] - 0.7)
          ..cubicTo(
            3.1,
            rows[1] - 1.75,
            5.1,
            rows[1] - 1.05,
            4.4,
            rows[1] - 0.1,
          )
          ..lineTo(2.7, rows[1] + 1.25)
          ..lineTo(4.9, rows[1] + 1.25),
        stroke,
      )
      // 3
      ..drawPath(
        Path()
          ..moveTo(2.8, rows[2] - 1.25)
          ..lineTo(4.9, rows[2] - 1.25)
          ..lineTo(3.7, rows[2] - 0.1)
          ..cubicTo(5.2, rows[2] - 0.1, 5, rows[2] + 1.45, 3.5, rows[2] + 1.2)
          ..cubicTo(
            3.2,
            rows[2] + 1.15,
            2.95,
            rows[2] + 1.05,
            2.8,
            rows[2] + 0.8,
          ),
        stroke,
      );
  }

  /// An outline: two top-level rows with an indented pair between them.
  static void multilevelList(Canvas canvas, Paint stroke) {
    final dot = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;
    const rows = <(double, double)>[
      (3.4, 3.4),
      (6.4, 6.5),
      (6.4, 9.5),
      (3.4, 12.6),
    ];
    for (final (left, y) in rows) {
      canvas
        ..drawCircle(Offset(left, y), 0.85, dot)
        ..drawLine(Offset(left + 2.4, y), Offset(13.2, y), stroke);
    }
  }

  /// Four full-width rows. Every line reaching both margins is what justified
  /// text looks like, and it is the only thing separating this from
  /// [alignLeft].
  static void alignJustify(Canvas canvas, Paint stroke) {
    for (var row = 0; row < 4; row++) {
      final y = 4.0 + row * 2.7;
      canvas.drawLine(Offset(3, y), Offset(13, y), stroke);
    }
  }

  /// A grid with a divided header row, because a plain grid at this size reads
  /// as a window.
  static void table(Canvas canvas, Paint stroke) {
    canvas
      ..drawRRect(
        RRect.fromLTRBR(2.5, 3, 13.5, 13, const Radius.circular(1)),
        stroke,
      )
      ..drawLine(const Offset(2.5, 6.3), const Offset(13.5, 6.3), stroke)
      ..drawLine(const Offset(2.5, 9.7), const Offset(13.5, 9.7), stroke)
      ..drawLine(const Offset(8, 6.3), const Offset(8, 13), stroke);
  }

  /// A frame with a horizon and a sun: the shape everyone reads as a picture.
  static void image(Canvas canvas, Paint stroke) {
    final fill = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;
    canvas
      ..drawRRect(
        RRect.fromLTRBR(2.5, 3.5, 13.5, 12.5, const Radius.circular(1)),
        stroke,
      )
      ..drawCircle(const Offset(6, 6.6), 1.1, fill)
      ..drawPath(
        Path()
          ..moveTo(2.5, 11)
          ..lineTo(6.2, 8.4)
          ..lineTo(9, 10.3)
          ..lineTo(11.2, 8.6)
          ..lineTo(13.5, 10.4),
        stroke,
      );
  }

  /// Text, air, a dashed rule, air, then text.
  ///
  /// The air matters: with the rows evenly spaced the dashed line reads as one
  /// more row of text rather than as the break between two pages.
  static void pageBreak(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(3, 2.3), const Offset(13, 2.3), stroke)
      ..drawLine(const Offset(3, 4.5), const Offset(10, 4.5), stroke)
      ..drawLine(const Offset(3, 11.5), const Offset(13, 11.5), stroke)
      ..drawLine(const Offset(3, 13.7), const Offset(10, 13.7), stroke);
    for (final x in const <double>[2.4, 6.6, 10.8]) {
      canvas.drawLine(Offset(x, 8), Offset(x + 2.8, 8), stroke);
    }
  }

  /// An A over a bar. The bar is where the current colour goes, so a caller can
  /// paint a swatch beneath the glyph rather than recolouring the letter.
  static void fontColor(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3.6, 10.2)
          ..lineTo(7.4, 2.8)
          ..lineTo(11.2, 10.2),
        stroke,
      )
      ..drawLine(const Offset(5.1, 7.4), const Offset(9.7, 7.4), stroke)
      ..drawLine(const Offset(3, 13.2), const Offset(13, 13.2), stroke);
  }

  /// An A with a cross beside it: strip what was applied and leave the letter.
  ///
  /// A cross rather than an eraser — a rubber drawn at sixteen pixels is an
  /// indistinct blob, and the cross is already this set's mark for "not this".
  static void clearFormat(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(1.8, 11.4)
          ..lineTo(5.4, 3.4)
          ..lineTo(9, 11.4),
        stroke,
      )
      ..drawLine(const Offset(3.2, 8.4), const Offset(7.6, 8.4), stroke)
      ..drawLine(const Offset(10.2, 8.2), const Offset(14, 12), stroke)
      ..drawLine(const Offset(14, 8.2), const Offset(10.2, 12), stroke);
  }

  /// A marker pen above the band it leaves. Same arrangement as [fontColor], so
  /// the two sit together in a bar without either looking taller.
  static void highlight(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(4.4, 9.6)
          ..lineTo(9.8, 3.2)
          ..lineTo(12.4, 5.4)
          ..lineTo(7, 11.8)
          ..lineTo(4.4, 11.8)
          ..close(),
        stroke,
      )
      ..drawLine(const Offset(4.4, 8.2), const Offset(7, 10.4), stroke)
      ..drawLine(const Offset(3, 13.4), const Offset(13, 13.4), stroke);
  }

  /// A speech bubble with a tail, and two lines of what was said.
  static void comment(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(3.5, 3)
          ..lineTo(12.5, 3)
          ..cubicTo(13.3, 3, 13.5, 3.5, 13.5, 4)
          ..lineTo(13.5, 9.5)
          ..cubicTo(13.5, 10.2, 13.1, 10.5, 12.5, 10.5)
          ..lineTo(7, 10.5)
          ..lineTo(4.2, 13.2)
          ..lineTo(4.2, 10.5)
          ..lineTo(3.5, 10.5)
          ..cubicTo(2.9, 10.5, 2.5, 10.2, 2.5, 9.5)
          ..lineTo(2.5, 4)
          ..cubicTo(2.5, 3.4, 2.9, 3, 3.5, 3)
          ..close(),
        stroke,
      )
      ..drawLine(const Offset(5, 5.8), const Offset(11, 5.8), stroke)
      ..drawLine(const Offset(5, 8), const Offset(9, 8), stroke);
  }

  /// A change bar in the margin beside text, with an insertion caret.
  ///
  /// The bar down the margin is the convention every word processor prints for
  /// a revised paragraph, and it is what makes this glyph mean *recorded*
  /// rather than merely *edited*. Deliberately not a pen over a rule — that is
  /// [highlight], and at sixteen pixels the two were the same picture.
  static void trackChanges(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(2.4, 2.8), const Offset(2.4, 13.2), stroke)
      ..drawLine(const Offset(5.2, 3.8), const Offset(13.4, 3.8), stroke)
      ..drawLine(const Offset(5.2, 7.4), const Offset(10.6, 7.4), stroke)
      ..drawLine(const Offset(5.2, 12.8), const Offset(13.4, 12.8), stroke)
      ..drawPath(
        Path()
          ..moveTo(8.2, 11)
          ..lineTo(9.8, 9)
          ..lineTo(11.4, 11),
        stroke,
      );
  }

  /// A magnifier over a rule: find, then act on what was found.
  static void findReplace(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(7, 6.4), 3.6, stroke)
      ..drawLine(const Offset(9.7, 9.1), const Offset(12.6, 12), stroke)
      ..drawLine(const Offset(2.6, 13.4), const Offset(13.4, 13.4), stroke);
  }

  /// Rows of text with a double-headed arrow measuring the gap beside them.
  static void lineSpacing(Canvas canvas, Paint stroke) {
    for (final y in const <double>[3.6, 7.2, 10.8, 13.4]) {
      canvas.drawLine(Offset(6.6, y), Offset(13.4, y), stroke);
    }
    canvas.drawPath(
      Path()
        ..moveTo(3.6, 3)
        ..lineTo(3.6, 13.6)
        ..moveTo(2.2, 4.6)
        ..lineTo(3.6, 3)
        ..lineTo(5, 4.6)
        ..moveTo(2.2, 12)
        ..lineTo(3.6, 13.6)
        ..lineTo(5, 12),
      stroke,
    );
  }

  /// An x with a raised 2.
  static void superscript(Canvas canvas, Paint stroke) =>
      _script(canvas, stroke, raised: true);

  /// An x with a dropped 2.
  static void subscript(Canvas canvas, Paint stroke) =>
      _script(canvas, stroke, raised: false);

  /// The x and the 2 shared by [superscript] and [subscript]. Only the height
  /// of the 2 differs, which is exactly the distinction being drawn — so the
  /// two glyphs cannot drift apart in anything else.
  static void _script(Canvas canvas, Paint stroke, {required bool raised}) {
    final top = raised ? 2.6 : 8.6;
    canvas
      ..drawLine(const Offset(2.6, 4.4), const Offset(9, 12.2), stroke)
      ..drawLine(const Offset(9, 4.4), const Offset(2.6, 12.2), stroke)
      ..drawPath(
        Path()
          ..moveTo(10.6, top + 0.8)
          ..cubicTo(11.2, top - 0.2, 13.4, top + 0.6, 12.4, top + 1.9)
          ..lineTo(10.6, top + 3.6)
          ..lineTo(13.4, top + 3.6),
        stroke,
      );
  }

  /// A roller, its handle, and the band it lays down.
  ///
  /// A brush was tried first and read as a bottle: at this size the taper of
  /// bristles is a few pixels and carries no meaning. A roller is all
  /// rectangles, which survive being small.
  static void paintFormat(Canvas canvas, Paint stroke) {
    canvas
      ..drawRRect(
        RRect.fromLTRBR(2.4, 2.6, 11, 6.2, const Radius.circular(0.8)),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(11, 4.4)
          ..lineTo(12.9, 4.4)
          ..lineTo(12.9, 8.6)
          ..lineTo(7.6, 8.6)
          ..lineTo(7.6, 9.8),
        stroke,
      )
      ..drawRRect(
        RRect.fromLTRBR(5.6, 9.8, 9.6, 13.6, const Radius.circular(0.8)),
        stroke,
      );
  }

  /// A capital H. The letter is the convention for a heading level, and a
  /// caller wanting "H1" draws the numeral beside it rather than in it.
  static void heading(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(3.4, 3), const Offset(3.4, 13), stroke)
      ..drawLine(const Offset(10.4, 3), const Offset(10.4, 13), stroke)
      ..drawLine(const Offset(3.4, 8), const Offset(10.4, 8), stroke);
  }

  /// The pilcrow, U+00B6 — drawn rather than typed, so it matches the set's
  /// weight instead of whatever font happens to be in the row.
  static void pilcrow(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(9.4, 3)
          ..lineTo(6.2, 3)
          ..cubicTo(3.2, 3, 3.2, 8.6, 6.2, 8.6)
          ..lineTo(9.4, 8.6),
        stroke,
      )
      ..drawLine(const Offset(9.4, 3), const Offset(9.4, 13), stroke)
      ..drawLine(const Offset(12.4, 3), const Offset(12.4, 13), stroke)
      ..drawLine(const Offset(9.4, 3), const Offset(12.8, 3), stroke);
  }

  /// A rule with graduated ticks, long alternating with short.
  static void ruler(Canvas canvas, Paint stroke) {
    canvas.drawRRect(
      RRect.fromLTRBR(2, 5.5, 14, 10.5, const Radius.circular(1)),
      stroke,
    );
    for (var i = 1; i <= 5; i++) {
      final x = 2 + i * 2.0;
      canvas.drawLine(Offset(x, 5.5), Offset(x, i.isEven ? 7.4 : 8.4), stroke);
    }
  }

  // Capture and annotation.

  /// The pointer, for the tool that selects and moves rather than draws.
  static void cursor(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(4.6, 2.4)
        ..lineTo(4.6, 12.4)
        ..lineTo(7.1, 9.9)
        ..lineTo(8.9, 13.4)
        ..lineTo(10.6, 12.6)
        ..lineTo(8.9, 9.2)
        ..lineTo(12.2, 8.9)
        ..close(),
      stroke,
    );
  }

  /// The marquee: four corner brackets rather than a closed rectangle, so it
  /// reads as a region being chosen and not as a rectangle being drawn — which
  /// is what [rectangle] is for, and the two sit next to each other in a tool
  /// strip.
  static void regionSelect(Canvas canvas, Paint stroke) {
    const inset = 2.5;
    const arm = 3.0;
    const far = SlateIcons.grid - inset;
    canvas
      ..drawPath(
        Path()
          ..moveTo(inset, inset + arm)
          ..lineTo(inset, inset)
          ..lineTo(inset + arm, inset),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(far - arm, inset)
          ..lineTo(far, inset)
          ..lineTo(far, inset + arm),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(far, far - arm)
          ..lineTo(far, far)
          ..lineTo(far - arm, far),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(inset + arm, far)
          ..lineTo(inset, far)
          ..lineTo(inset, far - arm),
        stroke,
      );
  }

  /// A display, for capturing one whole screen.
  static void monitor(Canvas canvas, Paint stroke) {
    canvas
      ..drawRRect(
        RRect.fromLTRBR(1.8, 3, 14.2, 11.4, const Radius.circular(1.4)),
        stroke,
      )
      ..drawLine(const Offset(8, 11.4), const Offset(8, 13.4), stroke)
      ..drawLine(const Offset(5.6, 13.4), const Offset(10.4, 13.4), stroke);
  }

  /// A camera, for taking the shot.
  static void camera(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(5.8, 4.4)
          ..lineTo(6.7, 2.6)
          ..lineTo(9.3, 2.6)
          ..lineTo(10.2, 4.4),
        stroke,
      )
      ..drawRRect(
        RRect.fromLTRBR(1.8, 4.4, 14.2, 13.4, const Radius.circular(1.6)),
        stroke,
      )
      ..drawCircle(const Offset(8, 8.9), 2.6, stroke);
  }

  /// A stopwatch, for a delayed capture.
  static void timer(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(8, 9.4), 4.6, stroke)
      ..drawLine(const Offset(8, 4.8), const Offset(8, 2.8), stroke)
      ..drawLine(const Offset(6.2, 2.8), const Offset(9.8, 2.8), stroke)
      ..drawLine(const Offset(8, 9.4), const Offset(8, 6.4), stroke);
  }

  /// Two corner marks, the way a photographic crop has always been shown.
  static void crop(Canvas canvas, Paint stroke) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(4.6, 1.8)
          ..lineTo(4.6, 11.4)
          ..lineTo(14.2, 11.4),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(1.8, 4.6)
          ..lineTo(11.4, 4.6)
          ..lineTo(11.4, 14.2),
        stroke,
      );
  }

  static void rectangle(Canvas canvas, Paint stroke) {
    canvas.drawRRect(
      RRect.fromLTRBR(2.4, 4, 13.6, 12, const Radius.circular(1)),
      stroke,
    );
  }

  static void ellipse(Canvas canvas, Paint stroke) {
    canvas.drawOval(const Rect.fromLTRB(2.4, 4, 13.6, 12), stroke);
  }

  static void line(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(2.8, 13.2), const Offset(13.2, 2.8), stroke);
  }

  /// A diagonal arrow — the annotation kind. The existing [arrowLeft] and
  /// [arrowRight] are horizontal and belong to navigation; an arrow tool that
  /// only ever pointed sideways would be a strange thing to offer.
  static void arrow(Canvas canvas, Paint stroke) {
    canvas
      ..drawLine(const Offset(2.8, 13.2), const Offset(13.2, 2.8), stroke)
      ..drawPath(
        Path()
          ..moveTo(8.2, 2.8)
          ..lineTo(13.2, 2.8)
          ..lineTo(13.2, 7.8),
        stroke,
      );
  }

  /// A droplet: the mark every image editor uses for a blur.
  static void blur(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      Path()
        ..moveTo(8, 2.4)
        ..cubicTo(8, 2.4, 3.4, 7.8, 3.4, 10.1)
        ..cubicTo(3.4, 12.7, 5.5, 13.9, 8, 13.9)
        ..cubicTo(10.5, 13.9, 12.6, 12.7, 12.6, 10.1)
        ..cubicTo(12.6, 7.8, 8, 2.4, 8, 2.4)
        ..close(),
      stroke,
    );
  }

  /// A mosaic. The cells are filled in a checker rather than left as a bare
  /// grid, which is what keeps it from reading as [table].
  static void pixelate(Canvas canvas, Paint stroke) {
    const origin = 2.6;
    const cell = 3.6;
    final fill = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 3; column++) {
        if ((row + column).isOdd) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            origin + column * cell,
            origin + row * cell,
            cell,
            cell,
          ),
          fill,
        );
      }
    }
    canvas.drawRect(Rect.fromLTWH(origin, origin, cell * 3, cell * 3), stroke);
  }

  /// A numbered step marker: a filled disc with the numeral knocked out of it.
  ///
  /// Drawn solid rather than as a ring with a digit inside, for two reasons.
  /// [info] is already a ring with a vertical stroke through it, and at fifteen
  /// pixels a ringed "1" is the same picture. And a filled disc with a white
  /// numeral is what the tool actually stamps on an image, so the glyph is the
  /// mark rather than a description of it. Negative space survives being small
  /// where a third thin stroke inside a ring does not.
  static void stepBadge(Canvas canvas, Paint stroke) {
    final numeral = Path()
      ..addRect(const Rect.fromLTRB(7.2, 4.4, 8.9, 11.6))
      ..addRect(const Rect.fromLTRB(5.6, 10.2, 10.5, 11.6))
      ..addPath(
        Path()
          ..moveTo(7.2, 4.4)
          ..lineTo(7.2, 7.1)
          ..lineTo(5.5, 6.4)
          ..close(),
        Offset.zero,
      );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 6.4)),
        numeral,
      ),
      Paint()
        ..color = stroke.color
        ..isAntiAlias = true,
    );
  }
}

/// Renders a [SlateIconDraw] at a given size and colour.
class SlateIcon extends StatelessWidget {
  const SlateIcon(
    this.draw, {
    this.size,
    this.color,
    this.weight = 1.5,
    super.key,
  });

  final SlateIconDraw draw;
  final double? size;
  final Color? color;

  /// Stroke width on the 16-unit grid, so it scales with the glyph.
  final double weight;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final resolved = size ?? theme.metrics.iconSize;
    return SizedBox.square(
      dimension: resolved,
      child: CustomPaint(
        painter: _SlateIconPainter(
          draw: draw,
          color: color ?? theme.palette.ink,
          weight: weight,
        ),
      ),
    );
  }
}

class _SlateIconPainter extends CustomPainter {
  const _SlateIconPainter({
    required this.draw,
    required this.color,
    required this.weight,
  });

  final SlateIconDraw draw;
  final Color color;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / SlateIcons.grid, size.height / SlateIcons.grid);
    draw(
      canvas,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = weight
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SlateIconPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.weight != weight ||
      oldDelegate.draw != draw;
}
