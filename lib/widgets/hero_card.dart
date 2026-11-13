import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive HeroCard used across onboarding pages.
/// Redesigned spacing: smaller blue square, larger inner panel, badges moved outward,
/// softer shadows and proportional icon sizes for better visual balance.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final double base = min(w, h);
        final double s = base.clamp(90.0, 320.0);

        final double outer = s; // outer rounded background
        final double innerPanel = outer * 0.82; // slightly larger inner panel
        final double blue = s * 0.50; // slightly reduced main blue square
        final double whiteInner = blue * 0.56; // inner white square
        final double badge = s * 0.16; // smaller green badge box
        final double smile = s * 0.14; // smaller smile icon
        final double dot = s * 0.035; // small dot

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // outer soft rounded background (softer shadow)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: outer,
                  height: outer,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5FF),
                    borderRadius: BorderRadius.circular(outer * 0.18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),

              // inner lighter panel (inset)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: innerPanel,
                  height: innerPanel,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FBFF),
                    borderRadius: BorderRadius.circular(innerPanel * 0.18),
                  ),
                ),
              ),

              // main blue rounded square (higher than before for more breathing room)
              Align(
                alignment: const Alignment(0, -0.22),
                child: Container(
                  width: blue,
                  height: blue,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(blue * 0.18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: whiteInner,
                      height: whiteInner,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(whiteInner * 0.18),
                      ),
                      child: Icon(
                        Icons.calculate_rounded,
                        color: const Color(0xFF1565C0),
                        size: whiteInner * 0.56,
                      ),
                    ),
                  ),
                ),
              ),

              // subtle green dot below blue square
              Align(
                alignment: const Alignment(-0.02, 0.46),
                child: Container(
                  width: dot * 2.8,
                  height: dot * 2.8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // green badge bottom-left (moved further outward to avoid overlap)
              Align(
                alignment: const Alignment(-0.26, 0.78),
                child: Container(
                  width: badge,
                  height: badge,
                  padding: EdgeInsets.all(badge * 0.12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(badge * 0.22),
                    border: Border.all(
                      color: Colors.green,
                      width: max(0.9, badge * 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: Colors.green,
                    size: badge * 0.46,
                  ),
                ),
              ),

              // smile icon bottom-right (moved further outward)
              Align(
                alignment: const Alignment(0.26, 0.78),
                child: Icon(
                  Icons.sentiment_satisfied_alt,
                  color: const Color(0xFF1565C0),
                  size: smile,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
