import 'package:flutter/material.dart';

/// Security visual widget used in onboarding (large white tile with shield and green badge)
class SecurityCard extends StatelessWidget {
  final double? width;
  final double? height;
  const SecurityCard({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    // Make the default tile more compact: ~56% of screen width and slightly shorter height
    final double defaultW = screenW * 0.26;
    final double w = (width ?? defaultW).clamp(180.0, screenW);
    final double h = height ?? w * 0.18;

    final double base = w < h ? w : h;
    final double tileRadius = base * 0.12;
    final double shieldSize = base * 0.42; // main blue shield container
    final double badgeSize = base * 0.18;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // white rounded tile with subtle shadow
          Center(
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(tileRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: shieldSize,
                  height: shieldSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(shieldSize * 0.18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: shieldSize * 0.44,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // green badge overlapping top-right with white border
          Positioned(
            right: -badgeSize * 0.22,
            top: -badgeSize * 0.22,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(badgeSize * 0.28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: badgeSize * 0.08,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: badgeSize * 0.46,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
