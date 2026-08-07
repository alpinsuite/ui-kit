import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate_ui/slate_ui.dart';

import 'slate_test_harness.dart';

void main() {
  group('SlateMenuButton', () {
    testWidgets('opens its panel on tap and closes it on a second tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateMenuItem(label: 'Open', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Open'), findsNothing);

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('builds its items lazily, so they reflect current state', (
      tester,
    ) async {
      // A menu built once at construction would show a stale recent-files list
      // or a command that is no longer available.
      var builds = 0;
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) {
                  builds++;
                  return <Widget>[
                    SlateMenuItem(label: 'Open', onPressed: () {}),
                  ];
                },
              ),
            ],
          ),
        ),
      );

      expect(builds, 0);

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(builds, greaterThan(0));
    });
  });

  group('SlateMenuBar', () {
    testWidgets('hovering switches menus once one is open', (tester) async {
      // Every menu bar on every desktop follows the pointer once one of them is
      // open, and one that does not feels broken long before anyone can say why.
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateMenuItem(label: 'Open', onPressed: () {}),
                ],
              ),
              SlateMenuButton(
                label: 'Edit',
                items: (context) => <Widget>[
                  SlateMenuItem(label: 'Undo', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);

      await hover(tester, find.text('Edit'));

      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('hovering a closed bar opens nothing', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateMenuItem(label: 'Open', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      );

      await hover(tester, find.text('File'));

      expect(find.text('Open'), findsNothing);
    });
  });

  group('SlateMenuItem', () {
    testWidgets('runs its command and puts the menu away', (tester) async {
      var ran = 0;
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateMenuItem(label: 'Open', onPressed: () => ran++),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(ran, 1);
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('closesMenu: false leaves the menu standing', (tester) async {
      // For a toggle the user may want to hit several times.
      var ran = 0;
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'View',
                items: (context) => <Widget>[
                  SlateMenuItem(
                    label: 'Grid',
                    onPressed: () => ran++,
                    closesMenu: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();

      expect(ran, 1);
      expect(find.text('Grid'), findsOneWidget);
    });

    testWidgets('a null callback disables the row', (tester) async {
      var ran = 0;
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'Edit',
                items: (context) => <Widget>[
                  const SlateMenuItem(label: 'Paste'),
                  SlateMenuItem(label: 'Undo', onPressed: () => ran++),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(ran, 0);
      // A disabled row must not close the menu either.
      expect(find.text('Paste'), findsOneWidget);
    });

    testWidgets('shows its shortcut and its check', (tester) async {
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'View',
                items: (context) => <Widget>[
                  SlateMenuItem(
                    label: 'Grid',
                    shortcut: 'Ctrl+G',
                    checked: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      expect(find.text('Ctrl+G'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SlateMenuItem),
          matching: find.byType(SlateIcon),
        ),
        findsOneWidget,
      );
    });
  });

  group('SlateSubmenu', () {
    testWidgets('opens on hover and closes the whole chain on a choice', (
      tester,
    ) async {
      // Choosing a command in a submenu should put the interface away, not
      // leave its parent standing.
      var ran = 0;
      await tester.pumpWidget(
        wrap(
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateSubmenu(
                    label: 'Recent',
                    items: (context) => <Widget>[
                      SlateMenuItem(
                        label: 'sketch.png',
                        onPressed: () => ran++,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('sketch.png'), findsNothing);

      await hover(tester, find.text('Recent'));
      expect(find.text('sketch.png'), findsOneWidget);

      await tester.tap(find.text('sketch.png'));
      await tester.pumpAndSettle();

      expect(ran, 1);
      expect(find.text('sketch.png'), findsNothing);
      expect(find.text('Recent'), findsNothing);
    });
  });

  group('SlateMenuSeparator', () {
    testWidgets('is a hairline', (tester) async {
      await tester.pumpWidget(wrap(const SlateMenuSeparator()));
      expect(
        tester.getSize(find.byType(SlateMenuSeparator)).height,
        greaterThan(0),
      );
    });
  });
}
