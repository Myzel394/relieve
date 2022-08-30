import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relieve/controllers/status_controller.dart';
import 'package:relieve/enums.dart';
import 'package:relieve/foreign_types/memory.dart';
import 'package:relieve/models/timeline.dart';
import 'package:relieve/widgets/status.dart';

import 'memory_view.dart';

const BAR_HEIGHT = 4.0;
const DEFAULT_IMAGE_DURATION = Duration(seconds: 5);

class MemorySlide extends StatefulWidget {
  final Memory memory;

  const MemorySlide({
    Key? key,
    required this.memory,
  }) : super(key: key);

  @override
  State<MemorySlide> createState() => _MemorySlideState();
}

class _MemorySlideState extends State<MemorySlide>
    with TickerProviderStateMixin {
  StatusController? controller;

  Duration? duration;

  @override
  void initState() {
    super.initState();

    if (widget.memory.type == MemoryType.photo) {
      initializeAnimation(DEFAULT_IMAGE_DURATION);
    }

    final timeline = context.read<TimelineModel>();

    // Pause / Resume `Status` widget when timeline pauses
    timeline.addListener(() {
      if (!mounted) {
        return;
      }

      if (timeline.paused) {
        controller?.stop();
      } else {
        controller?.start();
      }
    }, ['paused']);
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void initializeAnimation(final Duration newDuration) {
    duration = newDuration;

    final newController = StatusController(
      duration: newDuration,
    );

    newController.addListener(() {
      if (!mounted) {
        return;
      }

      final timeline = context.read<TimelineModel>();

      if (controller!.done) {
        timeline.nextMemory();
      }
    }, ['done']);

    setState(() {
      controller = newController;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final timeline = context.watch<TimelineModel>();

    return Status(
      controller: controller,
      paused: timeline.paused,
      hideProgressBar: !timeline.showOverlay,
      child: MemoryView(
        memory: widget.memory,
        loopVideo: false,
        onVideoControllerInitialized: (controller) {
          if (mounted) {
            initializeAnimation(controller.value.duration);

            timeline.addListener(() {
              if (!mounted) {
                return;
              }

              if (timeline.paused) {
                controller.pause();
              } else {
                controller.play();
              }
            }, ['paused']);
          }
        },
      ),
    );
  }
}
