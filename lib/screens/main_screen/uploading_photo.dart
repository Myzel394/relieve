import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

class UploadingPhoto extends StatefulWidget {
  final Uint8List data;
  final VoidCallback onDone;

  const UploadingPhoto({
    Key? key,
    required this.data,
    required this.onDone,
  }) : super(key: key);

  @override
  State<UploadingPhoto> createState() => _UploadingPhotoState();
}

const DURATION = Duration(milliseconds: 800);
const CURVE = Curves.easeInBack;

class _UploadingPhotoState extends State<UploadingPhoto>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  bool animateOut = false;
  Timer? _doneTimer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: DURATION,
      vsync: this,
    );
    animation = Tween(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: controller,
        curve: CURVE,
      ),
    );

    controller.forward();

    controller.addListener(() {
      if (controller.status == AnimationStatus.completed) {
        _doneTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) {
            return;
          }

          widget.onDone();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        animateOut = true;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _doneTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 12,
          ),
          borderRadius: BorderRadius.circular(MEDIUM_SPACE),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.memory(widget.data, fit: BoxFit.cover),
            AnimatedOpacity(
              opacity: animateOut ? 0 : 1,
              duration: DURATION,
              curve: CURVE,
              child: Container(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
