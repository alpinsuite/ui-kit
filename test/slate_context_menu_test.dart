import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

/// Opens a menu from a button, which is how one is reached in practice.
Future<void> openMenu(
  WidgetTester tester, {
  required List<SlateContextMenuItem> items,
  Offset at = const Offset(100, 100),
}) async {
  await tester.pumpWidget(
    wrap(
      Builder(
        builder: (context) => SlateButton(
          label: 'Open',
          onPressed: () => showSlateContextMenu(
            context: context,
            globalPosition: at,
            items: items,
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the labels it was given', (tester) async {
    await openMenu(
      tester,
      items: const <SlateContextMenuItem>[
        SlateContextMenuItem(label: 'Add above'),
        SlateContextMenuItem.separator(),
        SlateContextMenuItem(label: 'Delete'),
      ],
    );

    expect(find.text('Add above'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('choosing a row runs it and closes the menu', (tester) async {
    var chosen = 0;
    await openMenu(
      tester,
      items: <SlateContextMenuItem>[
        SlateContextMenuItem(label: 'Add below', onPressed: () => chosen++),
      ],
    );

    await tester.tap(find.text('Add below'));
    await tester.pumpAndSettle();

    expect(chosen, 1);
    // A popup still covering the row it just changed hides the result.
    expect(find.text('Add below'), findsNothing);
  });

  testWidgets('a click outside dismisses without choosing', (tester) async {
    var chosen = 0;
    await openMenu(
      tester,
      items: <SlateContextMenuItem>[
        SlateContextMenuItem(label: 'Delete', onPressed: () => chosen++),
      ],
    );

    await tester.tapAt(const Offset(600, 500));
    await tester.pumpAndSettle();

    expect(chosen, 0);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('Escape dismisses it', (tester) async {
    await openMenu(
      tester,
      items: const <SlateContextMenuItem>[
        SlateContextMenuItem(label: 'Delete'),
      ],
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('a row with no handler is shown but not tappable', (
    tester,
  ) async {
    await openMenu(
      tester,
      items: const <SlateContextMenuItem>[SlateContextMenuItem(label: 'Paste')],
    );

    // It stays visible: a command that disappears teaches the user it does not
    // exist.
    expect(find.text('Paste'), findsOneWidget);
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(find.text('Paste'), findsOneWidget);
  });

  testWidgets('a menu near the bottom edge is flipped back on screen', (
    tester,
  ) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await openMenu(
      tester,
      at: Offset(size.width - 10, size.height - 10),
      items: const <SlateContextMenuItem>[
        SlateContextMenuItem(label: 'One'),
        SlateContextMenuItem(label: 'Two'),
        SlateContextMenuItem(label: 'Three'),
      ],
    );

    // Every row reachable, including the last — which is usually the
    // destructive one.
    final last = tester.getRect(find.text('Three'));
    expect(last.bottom, lessThanOrEqualTo(size.height));
    expect(last.right, lessThanOrEqualTo(size.width));
  });

  testWidgets('the future completes when the menu closes', (tester) async {
    var done = false;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => SlateButton(
            label: 'Open',
            onPressed: () async {
              await showSlateContextMenu(
                context: context,
                globalPosition: const Offset(80, 80),
                items: const <SlateContextMenuItem>[
                  SlateContextMenuItem(label: 'Only'),
                ],
              );
              done = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(done, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });
}
