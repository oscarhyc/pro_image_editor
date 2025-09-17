import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';

/// A padding used to calculate bar height(thumbRadius * 2 - kBarPadding).
const _kBarPadding = 4;

/// A widget that allows users to pick font sizes from a gradient bar.
///
/// The `BarFontSizePicker` widget provides a horizontal or vertical bar with a
/// thumb that users can drag to select a font size from a range.
///
/// Example Usage:
/// ```dart
/// BarFontSizePicker(
///   length: 200,
///   fontScale: 1.0,
///   thumbColor: Colors.black,
///   fontSizeListener: (fontScaleValue) {
///     // Handle the selected font size change here
///   },
/// )
/// ```
class BarFontSizePicker extends StatefulWidget {
  /// A widget for selecting font sizes using a bar-based picker.
  const BarFontSizePicker({
    super.key,
    this.horizontal = true,
    this.showThumb = true,
    this.length = 200,
    this.borderWidth = 0.0,
    this.cornerRadius = 0.0,
    this.thumbRadius = 6,
    this.fontScale = 1.0,
    this.thumbColor = Colors.black,
    this.padding = const EdgeInsets.only(left: 10, right: 5),
    this.animationDuration = const Duration(milliseconds: 200),
    required this.fontSizeListener,
    required this.configs,
  });

  /// The width of the bar if it is horizontal, or the height if it is vertical.
  final double length;

  /// A listener that receives font size pick events.
  final Function(double value) fontSizeListener;

  /// The corner radius of the picker bar for each corner.
  final double cornerRadius;

  /// Specifies whether the bar is horizontal (`true`) or vertical (`false`).
  final bool horizontal;

  /// The fill color of the thumb.
  final Color thumbColor;

  /// The radius of the thumb.
  final double thumbRadius;

  /// The font scale to be displayed.
  final double fontScale;

  /// Image editor configurations.
  final ProImageEditorConfigs configs;

  /// Show on the slider a thumb widget.
  final bool showThumb;

  /// The border width around the slider.
  final double borderWidth;

  /// The padding to be applied around the font size picker bar.
  final EdgeInsets padding;

  /// The duration of the animation used in the font size picker.
  /// This determines how long the animation takes to complete.
  final Duration animationDuration;

  @override
  createState() => _BarFontSizePickerState();
}

class _BarFontSizePickerState extends State<BarFontSizePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// The current percentage position in the gradient.
  double percent = 0.0;

  /// Minimum font scale value.
  late double minFontScale;

  /// Maximum font scale value.
  late double maxFontScale;

  /// Width of the font size bar.
  late double barWidth;

  /// Height of the font size bar.
  late double barHeight;

  @override
  void initState() {
    super.initState();
    _updateFontSizePosition();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BarFontSizePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fontScale != widget.fontScale) {
      _updateFontSizePosition();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFontSizePosition() {
    // Initialize min and max font scale values from configs
    minFontScale = widget.configs.textEditor.minFontScale;
    maxFontScale = widget.configs.textEditor.maxFontScale;

    // Calculate the percentage position based on the current font scale
    percent = (widget.fontScale - minFontScale) / (maxFontScale - minFontScale);
    percent = percent.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final thumbRadius = widget.thumbRadius;
    final horizontal = widget.horizontal;

    double borderWidth = widget.borderWidth;
    double left, top;
    double? thumbLeft, thumbTop;

    if (horizontal) {
      barWidth = widget.length;
      barHeight = widget.thumbRadius * 2 - _kBarPadding;

      thumbLeft = barWidth * percent;
      left = thumbRadius;
      top = (thumbRadius * 2 - barHeight) / 2;
    } else {
      barWidth = widget.thumbRadius * 2 - _kBarPadding;
      barHeight = widget.length;

      thumbTop = barHeight * percent;
      left = (thumbRadius * 2 - barWidth) / 2;
      top = thumbRadius;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Important:
          // Don't remove onTap, cuz it prevent that events are emitted.
        },
        onPanDown: (details) => handleTouch(details.globalPosition, context),
        onPanStart: (details) => handleTouch(details.globalPosition, context),
        onPanUpdate: (details) => handleTouch(details.globalPosition, context),
        child: Padding(
          padding: widget.padding,
          child: Stack(
            children: [
              _buildFrame(
                horizontal: horizontal,
                thumbRadius: thumbRadius,
                borderWidth: borderWidth,
              ),
              _buildContent(
                top: top,
                left: left,
                borderWidth: borderWidth,
              ),
              if (widget.showThumb)
                _buildThumb(
                  borderWidth: borderWidth,
                  thumbRadius: thumbRadius,
                  thumbLeft: thumbLeft,
                  thumbTop: thumbTop,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb({
    double? thumbLeft,
    double? thumbTop,
    required double thumbRadius,
    required double borderWidth,
  }) {
    return Positioned(
      left: borderWidth / 2 + (thumbLeft ?? 0),
      top: thumbTop,
      child: Container(
        padding: EdgeInsets.zero,
        width: thumbRadius * 2,
        height: thumbRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thumbRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45000000),
              spreadRadius: 2,
              blurRadius: 3,
            )
          ],
          color: widget.thumbColor,
        ),
      ),
    );
  }

  Widget _buildContent({
    required double top,
    required double left,
    required double borderWidth,
  }) {
    return Positioned(
      left: left - borderWidth / 2,
      top: top,
      child: Container(
        padding: EdgeInsets.zero,
        width: barWidth + borderWidth * 2,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border: borderWidth != 0
              ? Border.all(
                  color: Colors.white,
                  width: borderWidth,
                )
              : null,
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFrame({
    required bool horizontal,
    required double thumbRadius,
    required double borderWidth,
  }) {
    double frameWidth, frameHeight;
    if (horizontal) {
      frameWidth = barWidth + thumbRadius * 2 + borderWidth;
      frameHeight = thumbRadius * 2;
    } else {
      frameWidth = thumbRadius * 2 + borderWidth;
      frameHeight = barHeight + thumbRadius * 2;
    }
    return SizedBox(width: frameWidth, height: frameHeight);
  }

  /// calculate font sizes picked from palette and update our states.
  void handleTouch(Offset globalPosition, BuildContext context) {
    var box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    var localPosition = box.globalToLocal(globalPosition);
    double percent;
    if (widget.horizontal) {
      percent = (localPosition.dx - widget.thumbRadius) / barWidth;
    } else {
      percent = (localPosition.dy - widget.thumbRadius) / barHeight;
    }
    percent = min(max(0.0, percent), 1.0);
    setState(() {
      this.percent = percent;
    });

    // Calculate the font scale based on the percentage
    final double fontScale =
        minFontScale + (maxFontScale - minFontScale) * percent;
    widget.fontSizeListener(fontScale);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('length', widget.length))
      ..add(DoubleProperty('fontScale', widget.fontScale))
      ..add(ColorProperty('thumbColor', widget.thumbColor))
      ..add(DoubleProperty('thumbRadius', widget.thumbRadius))
      ..add(DoubleProperty('cornerRadius', widget.cornerRadius))
      ..add(DoubleProperty('borderWidth', widget.borderWidth))
      ..add(DiagnosticsProperty<EdgeInsets>('padding', widget.padding))
      ..add(DiagnosticsProperty<Duration>(
          'animationDuration', widget.animationDuration))
      ..add(FlagProperty('horizontal',
          value: widget.horizontal, ifTrue: 'horizontal', ifFalse: 'vertical'))
      ..add(FlagProperty('showThumb',
          value: widget.showThumb, ifTrue: 'thumb visible'))
      ..add(PercentProperty('percent', percent));
  }
}
