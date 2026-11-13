import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/hero_card.dart';
import '../widgets/security_card.dart';
import '../widgets/auto_calc_card.dart';
import 'instrucciones_screen_with_terms.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InstruccionesScreenWithTerms()),
      );
    }
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: active ? 12 : 8,
      height: active ? 12 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0E71C2) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  // Reusable hero wrapper used across all onboarding pages
  Widget _heroBox(
    BuildContext context, {
    required double maxHeight,
    double? maxWidth,
  }) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;
    final double computedMaxWidth = maxWidth ?? (isSmall ? 140 : 220);
    final double computedMaxHeight = isSmall ? (maxHeight * 0.75) : maxHeight;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: computedMaxHeight,
            maxWidth: computedMaxWidth,
          ),
          child: const HeroCard(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => currentPage = i),
                children: [
                  _pageOne(context),
                  _pageTwo(context),
                  _pageThree(context),
                  _pageFour(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(currentPage == 0),
                  _dot(currentPage == 1),
                  _dot(currentPage == 2),
                  _dot(currentPage == 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _primary = Color(0xFF0E71C2);
  static const double _maxContentWidth = 420;

  /// Estructura común de cada página del onboarding:
  /// - contenido centrado con ancho máximo [_maxContentWidth]
  /// - botón abajo cuando hay espacio; scroll cuando no cabe (sin overflow)
  /// - [visualHeight] se adapta al alto disponible para las ilustraciones
  Widget _pageLayout({
    required List<Widget> Function(double contentWidth, double visualHeight)
    content,
    required Widget bottom,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double hPad = 20, vPad = 12;
        final double contentWidth = min(
          constraints.maxWidth - hPad * 2,
          _maxContentWidth,
        );
        // En ventanas bajas la ilustración se reduce más para que quepa todo.
        final double visualFactor = constraints.maxHeight < 700 ? 0.22 : 0.28;
        final double visualHeight = (constraints.maxHeight * visualFactor)
            .clamp(110.0, 230.0);

        // El padding lateral centra el contenido y le da un ancho exacto;
        // así se respeta el alto mínimo y el botón queda al fondo.
        final double sidePad = (constraints.maxWidth - contentWidth) / 2;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sidePad, vertical: vPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: max(0, constraints.maxHeight - vPad * 2),
            ),
            child: Column(
              // Con minHeight, spaceBetween lleva el botón al fondo
              // cuando sobra espacio, sin alturas fijas.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: content(contentWidth, visualHeight),
                ),
                Padding(padding: const EdgeInsets.only(top: 20), child: bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _primaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _appTitle(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return Text(
      'Pedx Calc',
      style: TextStyle(
        fontSize: isSmall ? 22 : 28,
        fontWeight: FontWeight.w800,
        color: _primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _pageTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF5A6973),
        fontSize: 15,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _pageOne(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;

    return _pageLayout(
      content: (contentWidth, visualHeight) => [
        const SizedBox(height: 6),
        _appTitle(context),
        const SizedBox(height: 12),
        _heroBox(context, maxHeight: visualHeight * 0.75),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
            children: const [
              TextSpan(
                text: 'Cálculos Pediátricos ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Precisos',
                style: TextStyle(color: _primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FBFF),
            borderRadius: BorderRadius.circular(18),
            border: const Border(left: BorderSide(color: _primary, width: 6)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            'La herramienta diseñada para complementar a los profesionales de la salud en el cálculo de las dosis para la administración de medicamentos en la edad pediátrica con eficiencia y rapidez.',
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              color: const Color(0xFF33414A),
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _featureChip(
              Icons.verified_user_outlined,
              'Protocolos seguros',
              _primary,
            ),
            _featureChip(Icons.flash_on, 'Acceso rápido', Colors.green),
          ],
        ),
      ],
      bottom: _primaryButton('Comenzar', _next),
    );
  }

  Widget _pageTwo(BuildContext context) {
    return _pageLayout(
      content: (contentWidth, visualHeight) => [
        const SizedBox(height: 6),
        _appTitle(context),
        const SizedBox(height: 16),
        SecurityCard(width: contentWidth, height: visualHeight),
        const SizedBox(height: 20),
        _pageTitle('Seguridad y Protocolos'),
        const SizedBox(height: 12),
        _bodyText(
          'Todos los cálculos están basados en protocolos estandarizados precisos para la población pediátrica.',
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _infoCard(Icons.update, 'Protocolos 2024', null)),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                Icons.science,
                'Evidencia Clínica',
                null,
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
      bottom: Column(
        children: [
          _primaryButton('Entendido y continuar', _next),
          const SizedBox(height: 8),
          const Text(
            'VERSIÓN 2.4.1 • ESTÁNDAR PEDIÁTRICO',
            style: TextStyle(color: Color(0xFF9AA5AE), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _pageThree(BuildContext context) {
    return _pageLayout(
      content: (contentWidth, visualHeight) => [
        const SizedBox(height: 6),
        _appTitle(context),
        const SizedBox(height: 12),
        _heroBox(context, maxHeight: visualHeight * 0.75),
        const SizedBox(height: 16),
        _pageTitle('Cálculos Automáticos'),
        const SizedBox(height: 12),
        _bodyText(
          'En caso de desconocer el peso se estima de forma automática, facilitando la toma de decisiones en momentos particulares.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFEAF6FF),
                child: Icon(Icons.tag_faces, color: _primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EDAD: 5 AÑOS',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        color: _primary,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '18.5 kg',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: _primaryButton('Siguiente', _next),
    );
  }

  Widget _pageFour(BuildContext context) {
    return _pageLayout(
      content: (contentWidth, visualHeight) => [
        const SizedBox(height: 6),
        _appTitle(context),
        const SizedBox(height: 12),
        // AutoCalcCard mide alto = ancho × 0,7 → ancho según el alto disponible
        AutoCalcCard(width: min(contentWidth, visualHeight / 0.7)),
        const SizedBox(height: 16),
        _pageTitle('Todo listo para comenzar'),
        const SizedBox(height: 12),
        _bodyText(
          'Ingresa pocos parámetros del paciente y obtendrás resultados instantáneos de dosis de medicamentos, oxigenoterapia y dispositivos médicos.',
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _infoCard(
                Icons.flash_on,
                'Velocidad',
                'Cálculos en menos de 2 segundos',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                Icons.shield,
                'Seguridad',
                'Doble verificación de dosis',
              ),
            ),
          ],
        ),
      ],
      bottom: _primaryButton(
        'Comenzar',
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const InstruccionesScreenWithTerms(),
          ),
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String? subtitle, {
    Color iconColor = _primary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
