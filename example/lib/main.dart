import 'package:flutter/material.dart';
import 'package:slate_ui/slate_ui.dart';

void main() => runApp(const GalleryApp());

/// A gallery of every widget the kit publishes, in both palettes.
///
/// It doubles as the answer to "what does this look like?" and as a place to
/// see a change without wiring the kit into an application first.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    final theme = _dark
        ? const SlateThemeData.dark()
        : const SlateThemeData.light();

    return MaterialApp(
      title: 'Slate',
      debugShowCheckedModeBanner: false,
      theme: theme.toMaterialTheme(),
      // The kit's own theme is installed above everything that draws, which is
      // exactly how a consuming application should do it.
      builder: (context, child) => SlateTheme(data: theme, child: child!),
      home: _Gallery(
        dark: _dark,
        onBrightnessChanged: (value) => setState(() => _dark = value),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.dark, required this.onBrightnessChanged});

  final bool dark;
  final ValueChanged<bool> onBrightnessChanged;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final TextEditingController _field = TextEditingController(text: 'sketch');

  bool _antialias = true;
  bool _grid = false;
  String _cap = 'Round';
  String _mode = 'Fill';
  double _size = 12;
  String _lastCommand = 'nothing yet';
  int _shellCategory = 1;
  String _shellTab = 'a';

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _ran(String command) => setState(() => _lastCommand = command);

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _windowBar(theme),
          const SlateSeparator(),
          _toolOptionsBar(theme),
          const SlateSeparator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(theme.metrics.pad + 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _section(theme, 'Buttons'),
                  Wrap(
                    spacing: theme.metrics.gap,
                    runSpacing: theme.metrics.gap,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      SlateButton(
                        label: 'Primary',
                        onPressed: () => _ran('Primary'),
                        kind: SlateButtonKind.primary,
                      ),
                      SlateButton(
                        label: 'Secondary',
                        onPressed: () => _ran('Secondary'),
                      ),
                      SlateButton(
                        label: 'Ghost',
                        onPressed: () => _ran('Ghost'),
                        kind: SlateButtonKind.ghost,
                      ),
                      SlateButton(
                        label: 'With icon',
                        onPressed: () => _ran('With icon'),
                        icon: SlateIcons.copy,
                      ),
                      const SlateButton(label: 'Disabled', onPressed: null),
                    ],
                  ),
                  SizedBox(height: theme.metrics.pad + 8),

                  _section(theme, 'Icon buttons'),
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      SlateIconButton(
                        icon: SlateIcons.plus,
                        onPressed: () => _ran('Zoom in'),
                        tooltip: 'Zoom in',
                      ),
                      SlateIconButton(
                        icon: SlateIcons.minus,
                        onPressed: () => _ran('Zoom out'),
                        tooltip: 'Zoom out',
                      ),
                      SlateIconButton(
                        icon: SlateIcons.fitScreen,
                        onPressed: () => _ran('Fit'),
                        tooltip: 'Fit to window',
                        selected: true,
                      ),
                      SlateIconButton(
                        icon: SlateIcons.close,
                        onPressed: () => _ran('Delete'),
                        tooltip: 'Delete',
                        danger: true,
                      ),
                      const SlateIconButton(
                        icon: SlateIcons.search,
                        onPressed: null,
                        tooltip: 'Disabled',
                      ),
                    ],
                  ),
                  SizedBox(height: theme.metrics.pad + 8),

                  _section(theme, 'The whole icon set'),
                  _icons(theme),
                  SizedBox(height: theme.metrics.pad + 8),

                  _section(theme, 'Dialog'),
                  SlateButton(
                    label: 'Open a dialog',
                    onPressed: () => _showDialog(context),
                  ),
                  SizedBox(height: theme.metrics.pad + 8),

                  _section(theme, 'Shell'),
                  _shell(theme),
                  SizedBox(height: theme.metrics.pad + 8),

                  _section(theme, 'Last command'),
                  Text(_lastCommand, style: theme.dimTextStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(SlateThemeData theme, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label.toUpperCase(), style: theme.sectionStyle),
  );

  /// The window furniture assembled the way an application uses it: a rail, a
  /// titled panel, a draggable divider, document tabs and a status bar. Shown
  /// together rather than one at a time because what matters about these is
  /// whether their edges line up.
  Widget _shell(SlateThemeData theme) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        border: Border.all(color: theme.palette.border),
      ),
      child: Row(
        children: <Widget>[
          SlateActivityBar(
            items: const <SlateActivityItem>[
              SlateActivityItem(icon: SlateIcons.list, tooltip: 'Tasks'),
              SlateActivityItem(icon: SlateIcons.gantt, tooltip: 'Timeline'),
              SlateActivityItem(icon: SlateIcons.calendar, tooltip: 'Calendar'),
              SlateActivityItem(
                icon: SlateIcons.resource,
                tooltip: 'Resources',
              ),
              SlateActivityItem(
                icon: SlateIcons.warning,
                tooltip: 'Problems',
                badge: '3',
              ),
            ],
            selectedIndex: _shellCategory,
            onSelected: (i) => setState(() => _shellCategory = i),
            footerItems: const <SlateActivityItem>[
              SlateActivityItem(icon: SlateIcons.settings, tooltip: 'Settings'),
            ],
            onFooterSelected: (_) => setState(() => _lastCommand = 'Settings'),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                SlateTabStrip(
                  tabs: const <SlateTab>[
                    SlateTab(id: 'a', label: 'north-wing.plan'),
                    SlateTab(id: 'b', label: 'fit-out.plan', modified: true),
                  ],
                  selectedId: _shellTab,
                  onSelected: (id) => setState(() => _shellTab = id),
                  onClosed: (id) => setState(() => _lastCommand = 'Close $id'),
                  closeTooltip: 'Close',
                ),
                Expanded(
                  child: SlateSplitView(
                    initialFraction: 0.34,
                    minStartExtent: 120,
                    minEndExtent: 140,
                    start: SlateSidePanel(
                      title: 'Outline',
                      actions: <Widget>[
                        SlateIconButton(
                          icon: SlateIcons.filter,
                          onPressed: () =>
                              setState(() => _lastCommand = 'Filter'),
                          tooltip: 'Filter',
                        ),
                      ],
                      child: Padding(
                        padding: EdgeInsets.all(theme.metrics.pad),
                        child: Text(
                          'Tree, filters, saved views',
                          style: theme.dimTextStyle,
                        ),
                      ),
                    ),
                    end: ColoredBox(
                      color: theme.palette.background,
                      child: Center(
                        child: Text('Main view', style: theme.dimTextStyle),
                      ),
                    ),
                  ),
                ),
                SlateStatusBar(
                  leading: <Widget>[
                    const SlateStatusItem(label: '128 rows'),
                    const SlateStatusItem(label: '9 on the long path'),
                  ],
                  trailing: <Widget>[
                    SlateStatusItem(
                      label: '3 problems',
                      icon: SlateIcons.warning,
                      emphasis: true,
                      tooltip: 'Show problems',
                      onPressed: () =>
                          setState(() => _lastCommand = 'Problems'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The merged title and menu row, drawn the way a desktop application that
  /// hides the system title bar has to draw it.
  Widget _windowBar(SlateThemeData theme) {
    return Container(
      height: theme.metrics.windowBarHeight,
      color: theme.palette.chrome,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: <Widget>[
          SlateMenuBar(
            children: <Widget>[
              SlateMenuButton(
                label: 'File',
                items: (context) => <Widget>[
                  SlateMenuItem(
                    label: 'New',
                    shortcut: 'Ctrl+N',
                    onPressed: () => _ran('File ▸ New'),
                  ),
                  SlateMenuItem(
                    label: 'Open…',
                    shortcut: 'Ctrl+O',
                    onPressed: () => _ran('File ▸ Open'),
                  ),
                  SlateSubmenu(
                    label: 'Open Recent',
                    items: (context) => <Widget>[
                      for (final name in const <String>[
                        'sketch.png',
                        'mockup.jpg',
                        'icon.svg',
                      ])
                        SlateMenuItem(
                          label: name,
                          onPressed: () => _ran('Opened $name'),
                        ),
                    ],
                  ),
                  const SlateMenuSeparator(),
                  SlateMenuItem(
                    label: 'Save',
                    shortcut: 'Ctrl+S',
                    onPressed: () => _ran('File ▸ Save'),
                  ),
                  // A command with no callback is unavailable, and says so by
                  // greying rather than by disappearing.
                  const SlateMenuItem(label: 'Revert', shortcut: 'Ctrl+R'),
                ],
              ),
              SlateMenuButton(
                label: 'View',
                items: (context) => <Widget>[
                  SlateMenuItem(
                    label: 'Show Grid',
                    shortcut: 'Ctrl+\'',
                    checked: _grid,
                    // A toggle the user may want to hit several times.
                    closesMenu: false,
                    onPressed: () => setState(() => _grid = !_grid),
                  ),
                  const SlateMenuSeparator(),
                  SlateMenuItem(
                    label: 'Dark',
                    checked: widget.dark,
                    closesMenu: false,
                    onPressed: () => widget.onBrightnessChanged(true),
                  ),
                  SlateMenuItem(
                    label: 'Light',
                    checked: !widget.dark,
                    closesMenu: false,
                    onPressed: () => widget.onBrightnessChanged(false),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text('Slate gallery', style: theme.dimTextStyle),
          const Spacer(),
          SlateIconButton(
            icon: widget.dark ? SlateIcons.maximize : SlateIcons.restore,
            onPressed: () => widget.onBrightnessChanged(!widget.dark),
            tooltip: widget.dark ? 'Switch to light' : 'Switch to dark',
          ),
          SlateIconButton(
            icon: SlateIcons.minimize,
            onPressed: () => _ran('Minimize'),
            tooltip: 'Minimize',
          ),
          SlateIconButton(
            icon: SlateIcons.close,
            onPressed: () => _ran('Close'),
            tooltip: 'Close',
            danger: true,
          ),
        ],
      ),
    );
  }

  /// The dense row the kit is really designed for: several controls, all one
  /// height, none of them shouting.
  Widget _toolOptionsBar(SlateThemeData theme) {
    return Container(
      height: theme.metrics.barHeight,
      color: theme.palette.panel,
      padding: EdgeInsets.symmetric(horizontal: theme.metrics.pad),
      child: Row(
        children: <Widget>[
          // The options for the current tool scroll; the text controls stay
          // pinned. A bar this dense will always outgrow a narrow window, and
          // clipping the right-hand controls is worse than scrolling the left.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _toolOptions(theme),
              ),
            ),
          ),
          SlateIconButton(
            icon: SlateIcons.bold,
            onPressed: () => _ran('Bold'),
            tooltip: 'Bold',
          ),
          SlateIconButton(
            icon: SlateIcons.italic,
            onPressed: () => _ran('Italic'),
            tooltip: 'Italic',
          ),
          SlateIconButton(
            icon: SlateIcons.underline,
            onPressed: () => _ran('Underline'),
            tooltip: 'Underline',
          ),
        ],
      ),
    );
  }

  List<Widget> _toolOptions(SlateThemeData theme) {
    return <Widget>[
      Text('Size', style: theme.dimTextStyle),
      const SizedBox(width: 6),
      SlateSlider(
        value: _size,
        min: 1,
        max: 64,
        onChanged: (value) => setState(() => _size = value),
      ),
      const SizedBox(width: 4),
      SizedBox(
        width: 26,
        child: Text('${_size.round()}', style: theme.dimTextStyle),
      ),
      SlateSeparator(vertical: true, inset: theme.metrics.gap),
      const SizedBox(width: 4),
      Text('Cap', style: theme.dimTextStyle),
      const SizedBox(width: 4),
      SlateSelect<String>(
        value: _cap,
        values: const <String>['Round', 'Square', 'Butt'],
        labelOf: (value) => value,
        minWidth: 74,
        onChanged: (value) => setState(() => _cap = value),
      ),
      SlateSeparator(vertical: true, inset: theme.metrics.gap),
      const SizedBox(width: 4),
      SlateSegmented<String>(
        value: _mode,
        values: const <String>['Fill', 'Stroke', 'Both'],
        labelOf: (value) => value,
        onChanged: (value) => setState(() => _mode = value),
      ),
      SlateSeparator(vertical: true, inset: theme.metrics.gap),
      const SizedBox(width: 4),
      SlateCheckbox(
        value: _antialias,
        label: 'Antialias',
        onChanged: (value) => setState(() => _antialias = value),
      ),
      const SizedBox(width: 12),
      SlateField(controller: _field, width: 130, hint: 'Name'),
      const SizedBox(width: 12),
    ];
  }

  Widget _icons(SlateThemeData theme) {
    const glyphs = <String, SlateIconDraw>{
      'chevronDown': SlateIcons.chevronDown,
      'chevronRight': SlateIcons.chevronRight,
      'chevronUp': SlateIcons.chevronUp,
      'check': SlateIcons.check,
      'close': SlateIcons.close,
      'minimize': SlateIcons.minimize,
      'maximize': SlateIcons.maximize,
      'restore': SlateIcons.restore,
      'search': SlateIcons.search,
      'plus': SlateIcons.plus,
      'minus': SlateIcons.minus,
      'download': SlateIcons.download,
      'copy': SlateIcons.copy,
      'fitScreen': SlateIcons.fitScreen,
      'actualSize': SlateIcons.actualSize,
      'swap': SlateIcons.swap,
      'bold': SlateIcons.bold,
      'italic': SlateIcons.italic,
      'underline': SlateIcons.underline,
      'alignLeft': SlateIcons.alignLeft,
      'alignCenter': SlateIcons.alignCenter,
      'alignRight': SlateIcons.alignRight,
      'palette': SlateIcons.palette,
      'chevronLeft': SlateIcons.chevronLeft,
      'arrowLeft': SlateIcons.arrowLeft,
      'arrowRight': SlateIcons.arrowRight,
      'undo': SlateIcons.undo,
      'redo': SlateIcons.redo,
      'zoomIn': SlateIcons.zoomIn,
      'zoomOut': SlateIcons.zoomOut,
      'sidebar': SlateIcons.sidebar,
      'tiles': SlateIcons.tiles,
      'list': SlateIcons.list,
      'rotateRight': SlateIcons.rotateRight,
      'rotateLeft': SlateIcons.rotateLeft,
      'trash': SlateIcons.trash,
      'file': SlateIcons.file,
      'folder': SlateIcons.folder,
      'save': SlateIcons.save,
      'print': SlateIcons.print,
      'lock': SlateIcons.lock,
      'info': SlateIcons.info,
      'pencil': SlateIcons.pencil,
      'layers': SlateIcons.layers,
      'eye': SlateIcons.eye,
      'signature': SlateIcons.signature,
      'textCursor': SlateIcons.textCursor,
      'calendar': SlateIcons.calendar,
      'gantt': SlateIcons.gantt,
      'milestone': SlateIcons.milestone,
      'resource': SlateIcons.resource,
      'baseline': SlateIcons.baseline,
      'warning': SlateIcons.warning,
      'report': SlateIcons.report,
      'settings': SlateIcons.settings,
      'link': SlateIcons.link,
      'filter': SlateIcons.filter,
      'indentIncrease': SlateIcons.indentIncrease,
      'indentDecrease': SlateIcons.indentDecrease,
      'criticalPath': SlateIcons.criticalPath,
    };

    return Wrap(
      spacing: theme.metrics.gap,
      runSpacing: theme.metrics.gap,
      children: <Widget>[
        for (final entry in glyphs.entries)
          SizedBox(
            // Wide enough for the longest glyph name; a truncated label in a
            // reference sheet defeats the point of the sheet.
            width: 96,
            child: Column(
              children: <Widget>[
                SlateIcon(entry.value, size: 20),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: theme.dimTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    final width = TextEditingController(text: '800');
    final height = TextEditingController(text: '600');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SlateDialog(
        title: 'Resize Image',
        content: Row(
          children: <Widget>[
            Expanded(
              child: SlateLabeledField(
                label: 'Width',
                child: SlateField(controller: width),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SlateLabeledField(
                label: 'Height',
                child: SlateField(controller: height),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          SlateButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          SlateButton(
            label: 'Resize',
            onPressed: () => Navigator.of(context).pop(true),
            kind: SlateButtonKind.primary,
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      _ran('Resized to ${width.text}×${height.text}');
    }
    width.dispose();
    height.dispose();
  }
}
