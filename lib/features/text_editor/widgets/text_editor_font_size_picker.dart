import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/font_size_picker/bar_font_size_picker.dart';
import '../text_editor.dart';

/// A widget for selecting and customizing text font sizes in the text editor,
/// allowing updates to the font scale.
class TextEditorFontSizePicker extends StatelessWidget {
  /// Creates a `TextEditorFontSizePicker` with the necessary configurations,
  /// state, and callbacks for handling font size updates.
  ///
  /// - [state]: Represents the current state of the text editor.
  /// - [configs]: Configuration settings for the editor, including available
  ///   font sizes.
  /// - [rebuildController]: A stream controller for triggering UI updates.
  /// - [fontScale]: The current font scale selected for the text.
  /// - [selectedTextStyle]: The text style currently applied to the text.
  /// - [onUpdateFontSize]: Callback triggered when the font size is updated.
  const TextEditorFontSizePicker({
    super.key,
    required this.state,
    required this.configs,
    required this.rebuildController,
    required this.fontScale,
    required this.selectedTextStyle,
    required this.onUpdateFontSize,
  });

  /// Represents the current state of the text editor.
  final TextEditorState state;

  /// Configuration settings for the editor, including available font sizes.
  final ProImageEditorConfigs configs;

  /// A stream controller for triggering UI updates.
  final StreamController<void> rebuildController;

  /// The current font scale selected for the text.
  final double fontScale;

  /// The text style currently applied to the text.
  final TextStyle selectedTextStyle;

  /// Callback triggered when the font size is updated.
  final Function(double fontScale) onUpdateFontSize;

  @override
  Widget build(BuildContext context) {
    if (configs.textEditor.widgets.fontSizePicker != null) {
      return configs.textEditor.widgets.fontSizePicker!.call(
            state,
            rebuildController.stream,
            fontScale,
            onUpdateFontSize,
          ) ??
          const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BarFontSizePicker(
          configs: configs,
          length: min(
            350,
            MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                10 * 2 -
                MediaQuery.paddingOf(context).top,
          ),
          fontScale: fontScale,
          horizontal: false,
          thumbColor: Colors.white,
          cornerRadius: 10,
          fontSizeListener: (double value) => onUpdateFontSize(value),
        ),
      ),
    );
  }
}
