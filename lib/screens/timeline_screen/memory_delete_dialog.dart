import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/foreign_types/memory.dart';
import 'package:relieve/models/memories.dart';
import 'package:relieve/utils/loadable.dart';
import 'package:relieve/utils/theme.dart';
import 'package:relieve/widgets/icon_button_child.dart';

class MemoryDeleteDialog extends StatefulWidget {
  final Memory memory;

  const MemoryDeleteDialog({
    required this.memory,
    Key? key,
  }) : super(key: key);

  @override
  State<MemoryDeleteDialog> createState() => _MemoryDeleteDialogState();
}

class _MemoryDeleteDialogState extends State<MemoryDeleteDialog> with Loadable {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformAlertDialog(
      title: Text(localizations.memorySheetDeleteFileTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            localizations.memorySheetDeleteFileDescription,
            style: getBodyTextTextStyle(context),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          if (widget.memory.hasBeenSavedToGallery)
            Row(
              children: <Widget>[
                Icon(context.platformIcons.error),
                const SizedBox(width: SMALL_SPACE),
                Flexible(
                  child: Text(
                    localizations
                        .memorySheetDeleteFileGalleryDeletionDescription,
                    style: getBodyTextTextStyle(context),
                  ),
                )
              ],
            )
          else ...[
            Text(
              localizations.memorySheetDeleteFileGalleryDeletionDownloadOffer,
              style: getBodyTextTextStyle(context),
            ),
            const SizedBox(height: LARGE_SPACE),
            PlatformElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => callWithLoading(widget.memory.saveFileToGallery),
              child: IconButtonChild(
                icon: PlatformWidget(
                  cupertino: (_, __) => Icon(
                    CupertinoIcons.down_arrow,
                    color: getBodyTextColor(context),
                  ),
                  material: (_, __) => Icon(
                    Icons.download,
                    color: getBodyTextColor(context),
                  ),
                ),
                label: Text(
                  localizations.memorySheetDownloadMemory,
                ),
              ),
            ),
          ]
        ],
      ),
      actions: <Widget>[
        PlatformDialogAction(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: IconButtonChild(
            icon: Icon(context.platformIcons.clear),
            label: Text(localizations.generalCancelButtonLabel),
          ),
        ),
        PlatformDialogAction(
          onPressed: isLoading
              ? null
              : () async {
                  final memories = context.read<Memories>();

                  await memories.removeMemory(widget.memory);

                  if (!mounted) {
                    return;
                  }

                  Navigator.pop(context, true);
                },
          child: IconButtonChild(
            icon: Icon(context.platformIcons.delete),
            label: Text(localizations.memorySheetDeleteFileDeleteLabel),
          ),
        ),
      ],
    );
  }
}
