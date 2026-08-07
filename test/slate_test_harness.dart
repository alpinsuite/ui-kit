import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

/// Puts [child] under a Material app themed by [theme], which is how the kit is
/// meant to be installed and therefore how it should be tested.
Widget wrap(
  Widget child, {
  SlateThemeData theme = const SlateThemeData.dark(),
}) {
  return MaterialApp(
    theme: theme.toMaterialTheme(),
    home: SlateTheme(
      data: theme,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

/// Moves a mouse pointer onto [finder] and leaves it there.
///
/// Half of this kit's design lives in the hover state, so a test that cannot
/// hover cannot check the thing that was actually designed.
Future<void> hover(WidgetTester tester, Finder finder) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  await gesture.moveTo(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

/// The decoration of the outermost [Container] a widget draws itself with.
BoxDecoration decorationOf(WidgetTester tester, Finder widget) {
  final container = tester.widget<Container>(
    find.descendant(of: widget, matching: find.byType(Container)).first,
  );
  return container.decoration! as BoxDecoration;
}
