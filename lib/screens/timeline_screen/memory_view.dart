import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:relieve/enums.dart';
import 'package:relieve/foreign_types/memory.dart';
import 'package:relieve/widgets/raw_memory_display.dart';
import 'package:video_player/video_player.dart';

class MemoryView extends StatefulWidget {
  final Memory memory;
  final bool loopVideo;
  final void Function(VideoPlayerController)? onVideoControllerInitialized;

  const MemoryView({
    Key? key,
    required this.memory,
    this.loopVideo = false,
    this.onVideoControllerInitialized,
  }) : super(key: key);

  @override
  State<MemoryView> createState() => _MemoryViewState();
}

class _MemoryViewState extends State<MemoryView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        if (widget.memory.type == MemoryType.photo)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: RawMemoryDisplay(
              file: widget.memory.file,
              type: widget.memory.type,
              loopVideo: widget.loopVideo,
              fit: BoxFit.cover,
            ),
          ),
        RawMemoryDisplay(
          file: widget.memory.file,
          type: widget.memory.type,
          fit: BoxFit.contain,
          loopVideo: widget.loopVideo,
          onVideoControllerInitialized: widget.onVideoControllerInitialized,
        ),
      ],
    );
  }
}
