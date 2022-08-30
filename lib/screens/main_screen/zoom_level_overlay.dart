import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/utils/format_zoom_level.dart';

class ZoomLevelOverlay extends StatefulWidget {
  final double zoomLevel;

  const ZoomLevelOverlay({
    required this.zoomLevel,
    Key? key,
  }) : super(key: key);

  @override
  State<ZoomLevelOverlay> createState() => _ZoomLevelOverlayState();
}

class _ZoomLevelOverlayState extends State<ZoomLevelOverlay> {
  bool isVisible = false;
  Timer? changeVisibilityTimer;

  @override
  void didUpdateWidget(covariant ZoomLevelOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    changeVisibilityTimer?.cancel();

    setState(() {
      isVisible = true;
    });

    changeVisibilityTimer = Timer(Duration.zero, () {
      setState(() {
        isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: HUGE_SPACE,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        curve: Curves.easeInOut,
        duration: isVisible
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 1200),
        child: Center(
          child: Text(
            formatZoomLevel(widget.zoomLevel),
            style: platformThemeData(
              context,
              material: (data) => data.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              cupertino: (data) => data.textTheme.textStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
