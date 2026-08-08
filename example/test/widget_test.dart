import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';
import 'package:slate_ui_example/main.dart';

void main() {
  testWidgets('the gallery renders and can switch palette', (tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.text('Primary'), findsOneWidget);
    expect(find.byType(SlateSelect<String>), findsOneWidget);

    // The gallery starts dark; the title bar button swaps the palette, which is
    // the one thing here worth a regression test — it proves both palettes lay
    // out without overflowing.
    await tester.tap(find.byTooltip('Switch to light'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to dark'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the resize dialog opens and reports its result', (tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    // The button sits below the fold of the 800x600 test viewport, and moves
    // further down every time the kit gains a glyph — the icon section above it
    // is a Wrap. Tapping a finder that is off-screen silently misses.
    final openDialog = find.text('Open a dialog');
    await tester.ensureVisible(openDialog);
    await tester.pumpAndSettle();

    await tester.tap(openDialog);
    await tester.pumpAndSettle();
    expect(find.text('Resize Image'), findsOneWidget);

    await tester.tap(find.text('Resize'));
    await tester.pumpAndSettle();

    expect(find.text('Resized to 800×600'), findsOneWidget);
  });
}
