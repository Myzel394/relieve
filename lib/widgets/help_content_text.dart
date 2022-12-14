import 'package:flutter/material.dart';
import 'package:relieve/utils/theme.dart';

class HelpContentText extends StatelessWidget {
  final String text;
  final Widget icon;

  const HelpContentText({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: icon,
        ),
        const Spacer(flex: 1),
        Expanded(
          flex: 14,
          child: Text(
            text,
            style: getBodyTextTextStyle(context),
          ),
        ),
      ],
    );
  }
}
