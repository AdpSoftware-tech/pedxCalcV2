import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xffF2F7FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xff1565C0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Text(
              "La herramienta diseñada para ayudar a profesionales de la salud a calcular dosis y medidas pediátricas con seguridad y rapidez.",
              style: TextStyle(fontSize: 18, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
