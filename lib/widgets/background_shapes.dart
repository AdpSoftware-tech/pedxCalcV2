import 'package:flutter/material.dart';

class BackgroundShapes extends StatelessWidget {
  const BackgroundShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -140,
          top: 70,
          child: Container(
            width: 340,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xffEEF5FF),
              borderRadius: BorderRadius.circular(220),
            ),
          ),
        ),
        Positioned(
          right: -90,
          top: 150,
          child: Container(
            width: 230,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xffF7FAFF),
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
      ],
    );
  }
}
