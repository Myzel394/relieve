import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/utils/theme.dart';

class AnnotationDialog extends StatefulWidget {
  const AnnotationDialog({Key? key}) : super(key: key);

  @override
  State<AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<AnnotationDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: Column(
              children: <Widget>[
                Text(
                  localizations.mainScreenAnnotationDialogTitle,
                  style: getTitleTextStyle(context),
                ),
                const SizedBox(height: SMALL_SPACE),
                Text(
                  localizations.mainScreenAnnotationDialogExplanation,
                  style: getBodyTextTextStyle(context),
                ),
                const SizedBox(height: MEDIUM_SPACE),
                PlatformTextField(
                  controller: controller,
                  autofocus: true,
                  material: (_, __) => MaterialTextFieldData(
                    decoration: InputDecoration(
                      labelText: localizations
                          .mainScreenAnnotationDialogAnnotationFieldLabel,
                    ),
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        PlatformDialogAction(
          child: Text(localizations.generalCancelButtonLabel),
          onPressed: () => Navigator.pop(context, ''),
        ),
        PlatformDialogAction(
          child: Text(localizations.generalSaveButtonLabel),
          onPressed: () => Navigator.pop(context, controller.text.trim()),
        ),
      ],
    );
  }
}
