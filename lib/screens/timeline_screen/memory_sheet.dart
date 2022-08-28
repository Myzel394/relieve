import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/screens/memory_map_screen.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:quid_faciam_hodie/widgets/platform_widgets/memory_cupertino_maps.dart';
import 'package:quid_faciam_hodie/widgets/platform_widgets/memory_material_maps.dart';
import 'package:quid_faciam_hodie/widgets/sheet_indicator.dart';

import 'memory_delete_dialog.dart';

class MemorySheet extends StatefulWidget {
  final Memory memory;
  final BuildContext sheetContext;

  const MemorySheet({
    Key? key,
    required this.memory,
    required this.sheetContext,
  }) : super(key: key);

  @override
  State<MemorySheet> createState() => _MemorySheetState();
}

class _MemorySheetState extends State<MemorySheet> with Loadable {
  bool isExpanded = false;

  Future<void> deleteFile() async {
    final closeSheet = await showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MemoryDeleteDialog(
        memory: widget.memory,
      ),
    );

    if (!mounted) {
      return;
    }

    if (closeSheet == true) {
      Navigator.pop(context);
    }
  }

  Future<void> downloadFile() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await widget.memory.saveFileToGallery();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      context.showSuccessSnackBar(
        message: localizations.memorySheetSavedToGallery,
      );
    } catch (error) {
      context.showErrorSnackBar(message: localizations.generalError);
    }
  }

  Widget buildLoadingIndicator() {
    final size = platformThemeData(
      context,
      material: (data) => data.textTheme.titleLarge!.fontSize,
      cupertino: (data) => data.textTheme.textStyle.fontSize,
    );

    return SizedBox.square(
      dimension: size,
      child: PlatformCircularProgressIndicator(
        material: (_, __) => MaterialProgressIndicatorData(
          strokeWidth: 2,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final backgroundColor = getSheetColor(context);

    return ExpandableBottomSheet(
      onIsContractedCallback: () {
        setState(() {
          isExpanded = false;
        });
      },
      onIsExtendedCallback: () {
        setState(() {
          isExpanded = true;
        });
      },
      enableToggle: true,
      background: GestureDetector(
        onTap: () => Navigator.pop(context),
      ),
      persistentHeader: Material(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(LARGE_SPACE),
          topRight: Radius.circular(LARGE_SPACE),
        ),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(MEDIUM_SPACE),
          child: Column(
            children: <Widget>[
              if (widget.memory.location != null) ...[
                const Padding(
                  padding: EdgeInsets.all(SMALL_SPACE),
                  child: SheetIndicator(),
                ),
                const SizedBox(height: MEDIUM_SPACE),
              ],
              Text(
                localizations.memorySheetTitle,
                style: getTitleTextStyle(context),
              ),
              const SizedBox(height: MEDIUM_SPACE),
              ListTile(
                leading: PlatformWidget(
                  cupertino: (_, __) => Icon(
                    CupertinoIcons.down_arrow,
                    color: getBodyTextColor(context),
                  ),
                  material: (_, __) => Icon(
                    Icons.download,
                    color: getBodyTextColor(context),
                  ),
                ),
                title: Text(
                  localizations.memorySheetDownloadMemory,
                  style: getBodyTextTextStyle(context),
                ),
                enabled: !getIsLoadingSpecificID('download'),
                onTap: getIsLoadingSpecificID('download')
                    ? null
                    : () => callWithLoading(downloadFile, 'download'),
                trailing: getIsLoadingSpecificID('download')
                    ? buildLoadingIndicator()
                    : (widget.memory.hasBeenSavedToGallery
                        ? Icon(context.platformIcons.checkMarkCircledSolid)
                        : null),
              ),
              ListTile(
                leading: Icon(
                  context.platformIcons.delete,
                  color: getBodyTextColor(context),
                ),
                title: Text(
                  localizations.memorySheetDeleteMemory,
                  style: getBodyTextTextStyle(context),
                ),
                onTap: deleteFile,
              ),
              const SizedBox(height: MEDIUM_SPACE),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    context.platformIcons.time,
                    size: getIconSizeForBodyText(context),
                  ),
                  const SizedBox(width: TINY_SPACE),
                  Text(
                    localizations.memorySheetCreatedAtDataKey(
                      widget.memory.creationDate,
                    ),
                    style: getBodyTextTextStyle(context),
                  ),
                ],
              ),
              if (widget.memory.location != null) ...[
                const SizedBox(height: SMALL_SPACE),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      isExpanded
                          ? context.platformIcons.downArrow
                          : context.platformIcons.upArrow,
                      size: getIconSizeForBodyText(context),
                    ),
                    const SizedBox(width: TINY_SPACE),
                    Text(
                      isExpanded
                          ? localizations.generalSwipeDownToClose
                          : localizations.generalSwipeUpForMore,
                      style: getBodyTextTextStyle(context),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      expandableContent: widget.memory.location == null
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: backgroundColor,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: GestureDetector(
                      // Avoid panning, map is view-only
                      onDoubleTap: () {},
                      child: PlatformWidget(
                        material: (_, __) => MemoryMaterialMaps(
                          location: widget.memory.location!,
                          initialZoom: 14,
                        ),
                        cupertino: (_, __) => MemoryCupertinoMaps(
                          location: widget.memory.location!,
                          initialZoom: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                  PlatformTextButton(
                    child: IconButtonChild(
                      icon: Icon(context.platformIcons.fullscreen),
                      label: Text(localizations.memorySheetViewMoreDetails),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoryMapScreen(
                            location: widget.memory.location!,
                          ),
                        ),
                      );

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                ],
              ),
            ),
    );
  }
}
