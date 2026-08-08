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
