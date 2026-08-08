import 'package:flutter/widgets.dart';

import 'slate_theme.dart';

/// A titled panel with a header and a slot for header actions.
///
/// The side panel of an editor: a quiet heading, a row of small controls that
/// belong to the panel rather than to the document, and the content below.
class SlateSidePanel extends StatelessWidget {
  const SlateSidePanel({
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    super.key,
  });

  /// Displayed as given. The kit holds no localisations; the caller has already
  /// decided what language this is in and whether it is upper case.
  final String title;

  /// Small controls at the trailing edge of the header — collapse, filter, add.
  final List<Widget> actions;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;

    return Container(
      color: palette.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: theme.metrics.barHeight,
            child: Padding(
              padding: EdgeInsets.only(
                left: theme.metrics.pad,
                right: theme.metrics.pad / 2,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.sectionStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
          Container(height: 1, color: palette.separator),
          Expanded(child: child),
        ],
      ),
    );
  }
}
