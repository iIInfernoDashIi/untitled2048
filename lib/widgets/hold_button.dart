import 'package:flutter/material.dart';

class HoldButton extends StatefulWidget {
  final VoidCallback? onHold;
  final Icon icon;
  const HoldButton({super.key, required this.icon, this.onHold});

  @override
  HoldButtonState createState() => HoldButtonState();
}

class HoldButtonState extends State<HoldButton> with SingleTickerProviderStateMixin{
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(milliseconds: 250),
    );
    controller.addListener(() {
      setState(() {});
      if (controller.value == 1.0){
        widget.onHold?.call();
        controller.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => controller.forward(),
      onTapUp: (_) {
        if (controller.status == AnimationStatus.forward) {
          controller.reverse();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              value: controller.value,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            widget.icon,
          ],
        ),
      ),
    );
  }
}