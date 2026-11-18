import 'package:flutter/material.dart';

/// AutoCalcCard - card used in "Cálculos Automáticos" onboarding page
/// Displays a background image from assets and a bottom-left floating badge
/// with a green icon and text "PROTOCOLO / Validado Clínicamente".
class AutoCalcCard extends StatelessWidget {
  final double? width;
  final String imagePath;
  const AutoCalcCard({
    super.key,
    this.width,
    this.imagePath = 'assets/images/doc.png',
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double parentSuggested =
            (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
            ? constraints.maxWidth
            : (screenW * 0.9);

        final double w = (width ?? parentSuggested).clamp(160.0, screenW);
        final double h = w * 0.7;

        final double badgeHeight = h * 0.22;
        // Tarjeta estrecha → etiqueta compacta (letra menor, texto en 2 líneas).
        final bool compact = w < 260;
        final double badgeFont = compact ? 11 : 13;
        final double iconBox = compact
            ? 24
            : (badgeHeight * 0.7).clamp(28.0, 40.0);
        final double badgeRadius = 12.0;

        return Center(
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Background image loaded with Image.asset so we can show a fallback
                Positioned.fill(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback visual when asset not found or fails to decode
                      return Container(
                        color: const Color(0xFFF3F6F8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.image_not_supported,
                                size: 44,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Imagen no disponible',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // bottom-left badge using fixed offsets instead of fractions of parent's size
                Positioned(
                  left: 12,
                  bottom: 12,
                  // Nunca más ancha que la tarjeta (menos márgenes).
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: w - 24),
                    child: Container(
                      // Sin alto fijo: la etiqueta crece con su texto y no
                      // desborda cuando la tarjeta es pequeña.
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 14,
                        vertical: compact ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(badgeRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: iconBox,
                            height: iconBox,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(
                                compact ? 7 : 10,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: compact ? 14 : 18,
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 8 : 12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROTOCOLO',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: badgeFont,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Validado Clínicamente',
                                  maxLines: compact ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: badgeFont,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
