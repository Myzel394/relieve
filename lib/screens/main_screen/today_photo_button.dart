import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/screens/empty_screen.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';
import 'package:quid_faciam_hodie/widgets/raw_memory_display.dart';

class TodayPhotoButton extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onComeBack;

  const TodayPhotoButton({
    Key? key,
    required this.onLeave,
    required this.onComeBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final memories = context.read<Memories>();

        if (memories.memories.isEmpty) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmptyScreen()),
          );
          return;
        }

        onLeave();

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimelineScreen()),
        );

        onComeBack();
      },
      child: Align(
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(SMALL_SPACE),
            color: Colors.grey,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SMALL_SPACE),
            child: Consumer<Memories>(
              builder: (_, memories, __) => (memories.latest == null)
                  ? const SizedBox.shrink()
                  : RawMemoryDisplay(
                      file: memories.latest!.file,
                      type: memories.latest!.type,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
