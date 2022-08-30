import 'dart:math';

import 'package:flutter/material.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/foreign_types/memory.dart';
import 'package:relieve/utils/theme.dart';
import 'package:relieve/widgets/modal_sheet.dart';

class SaveToGalleryModal extends StatefulWidget {
  final Iterable<Memory> memories;

  const SaveToGalleryModal({
    Key? key,
    required this.memories,
  }) : super(key: key);

  @override
  State<SaveToGalleryModal> createState() => _SaveToGalleryModalState();
}

class _SaveToGalleryModalState extends State<SaveToGalleryModal> {
  int currentMemory = 0;

  @override
  void initState() {
    super.initState();

    downloadMemories();
  }

  Future<void> downloadMemories() async {
    for (final memory in widget.memories) {
      await memory.saveFileToGallery();

      if (memory != widget.memories.last) {
        setState(() {
          currentMemory = min(widget.memories.length - 1, currentMemory + 1);
        });
      }
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Column(
        children: <Widget>[
          Text(
            'Saving to gallery',
            style: getTitleTextStyle(context),
          ),
          const SizedBox(height: LARGE_SPACE),
          Text(
            '$currentMemory/${widget.memories.length}',
            style: getBodyTextTextStyle(context),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          LinearProgressIndicator(
            value: currentMemory / widget.memories.length,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          Text(
            widget.memories.elementAt(currentMemory).annotation,
            style: getSubTitleTextStyle(context),
          )
        ],
      ),
    );
  }
}
