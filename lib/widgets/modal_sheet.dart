import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class ModalSheet extends StatelessWidget {
  final Widget child;

  const ModalSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: MEDIUM_SPACE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformWidget(
            material: (_, __) => Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(LARGE_SPACE),
                  topRight: Radius.circular(LARGE_SPACE),
                ),
                color: getSheetColor(context),
              ),
              padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
                child: child,
              ),
            ),
            cupertino: (_, __) => CupertinoPopupSurface(
              isSurfacePainted: false,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                  child: child,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
