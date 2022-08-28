import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  static const ID = '/support';

  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool isHeartExpanded = false;
  Timer? _heartExpandTimer;

  @override
  void initState() {
    super.initState();

    updateHeartExpandState();
  }

  @override
  void dispose() {
    _heartExpandTimer?.cancel();

    super.dispose();
  }

  void updateHeartExpandState() {
    final waitSeconds = Random().nextInt(7) + 3;

    _heartExpandTimer = Timer(Duration(seconds: waitSeconds), () {
      if (!mounted) {
        return;
      }

      setState(() {
        isHeartExpanded = !isHeartExpanded;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          localizations.supportScreenTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedScale(
                duration: const Duration(seconds: 1),
                scale: isHeartExpanded ? 1.2 : .9,
                curve: Curves.bounceOut,
                onEnd: updateHeartExpandState,
                child: Icon(
                  context.platformIcons.favoriteSolid,
                  color: Colors.red,
                  size: 100,
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
              Text(
                localizations.supportScreenTitle,
                textAlign: TextAlign.center,
                style: getTitleTextStyle(context),
              ),
              const SizedBox(height: MEDIUM_SPACE),
              Text(
                localizations.supportScreenDescription,
                style: getBodyTextTextStyle(context),
              ),
              const SizedBox(height: SMALL_SPACE),
              Text(
                localizations.supportScreenMethodsAvailable,
                style: getBodyTextTextStyle(context),
              ),
              const SizedBox(height: LARGE_SPACE),
              PlatformElevatedButton(
                child: IconButtonChild(
                  label: Text(
                    localizations.supportScreenOpenLink,
                  ),
                  icon: Icon(context.platformIcons.favoriteSolid),
                ),
                onPressed: () => launchUrl(
                  Uri.parse(DONATION_LINK),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
