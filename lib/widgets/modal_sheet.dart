import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/utils/theme.dart';

class ModalSheet extends StatelessWidget {
  final Widget child;

  const ModalSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(LARGE_SPACE),
            topRight: Radius.circular(LARGE_SPACE),
          ),
          color: getSheetColor(context),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: LARGE_SPACE,
            left: MEDIUM_SPACE,
            right: MEDIUM_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
            ],
          ),
        ),
      ),
      cupertino: (_, __) => CupertinoPopupSurface(
        isSurfacePainted: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: LARGE_SPACE,
            horizontal: MEDIUM_SPACE,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
            ],
          ),
        ),
      ),
    );
  }
}
