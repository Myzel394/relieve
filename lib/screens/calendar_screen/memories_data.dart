import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/models/memories.dart';
import 'package:relieve/utils/theme.dart';

class MemoriesData extends StatelessWidget {
  const MemoriesData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memories = context.watch<Memories>();
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              localizations.calendarScreenMemoriesDataMemoriesAmount(
                memories.memories.length,
              ),
              style: getBodyTextTextStyle(context),
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              localizations.calendarScreenMemoriesDataMemoriesSpanning(
                memories.memories.last.creationDate,
                memories.memories.first.creationDate,
              ),
              style: getBodyTextTextStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
