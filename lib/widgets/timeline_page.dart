import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/models/memory_pack.dart';
import 'package:share_location/models/timeline_overlay.dart';
import 'package:share_location/widgets/memory_sheet.dart';
import 'package:share_location/widgets/memory_slide.dart';

class TimelinePage extends StatefulWidget {
  final DateTime date;
  final VoidCallback onPreviousTimeline;
  final VoidCallback onNextTimeline;

  const TimelinePage({
    Key? key,
    required this.date,
    required this.onPreviousTimeline,
    required this.onNextTimeline,
  }) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final timelineOverlayController = TimelineOverlay();
  final pageController = PageController();

  Timer? overlayRemover;

  @override
  void initState() {
    super.initState();

    final memoryPack = context.read<MemoryPack>();

    timelineOverlayController.addListener(() {
      if (!mounted) {
        return;
      }

      if (timelineOverlayController.state == TimelineState.completed) {
        timelineOverlayController.reset();
        memoryPack.next();
      }
    }, ['state']);

    memoryPack.addListener(() {
      if (!mounted) {
        return;
      }

      if (memoryPack.completed) {
        widget.onNextTimeline();
        memoryPack.reset();
      }
    }, ['completed']);

    memoryPack.addListener(() {
      if (!mounted) {
        return;
      }

      if (memoryPack.currentMemoryIndex != pageController.page) {
        pageController.animateToPage(
          memoryPack.currentMemoryIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        final memoryPack = context.read<MemoryPack>();

        memoryPack.pause();
        timelineOverlayController.hideOverlay();

        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => MemorySheet(
            memory: memoryPack.currentMemory,
          ),
        );

        if (!mounted) {
          return;
        }

        memoryPack.removeCurrentMemory();
        memoryPack.resume();
        timelineOverlayController.restoreOverlay();
      },
      onTapDown: (_) {
        final memoryPack = context.read<MemoryPack>();

        memoryPack.pause();

        overlayRemover = Timer(
          const Duration(milliseconds: 200),
          timelineOverlayController.hideOverlay,
        );
      },
      onTapUp: (_) {
        final memoryPack = context.read<MemoryPack>();

        overlayRemover?.cancel();
        memoryPack.resume();
        timelineOverlayController.restoreOverlay();
      },
      onTapCancel: () {
        final memoryPack = context.read<MemoryPack>();

        overlayRemover?.cancel();

        timelineOverlayController.restoreOverlay();
        memoryPack.resume();
      },
      onHorizontalDragEnd: (details) {
        final memoryPack = context.read<MemoryPack>();

        if (details.primaryVelocity! < 0) {
          memoryPack.next();

          pageController.nextPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut,
          );
        } else if (details.primaryVelocity! > 0) {
          memoryPack.previous();

          pageController.previousPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut,
          );
        }
      },
      child: ChangeNotifierProvider<TimelineOverlay>(
        create: (_) => timelineOverlayController,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Consumer<MemoryPack>(
              builder: (_, memoryPack, __) {
                return PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => MemorySlide(
                    key: Key(memoryPack.memories[index].filename),
                    memory: memoryPack.memories[index],
                  ),
                  itemCount: memoryPack.memories.length,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: LARGE_SPACE,
                left: MEDIUM_SPACE,
                right: MEDIUM_SPACE,
              ),
              child: Consumer<TimelineOverlay>(
                builder: (context, overlayController, _) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut,
                  opacity: overlayController.showOverlay ? 1.0 : 0.0,
                  child: Text(
                    DateFormat('dd. MMMM yyyy').format(widget.date),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}