import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'bandeja_de_datos.dart';
import 'iphone_14_15_pro_5.dart';
import 'zona_de_entrenamiento.dart';

class AcercaDeFONOMED extends StatefulWidget {
  const AcercaDeFONOMED({super.key});

  @override
  _AcercaDeFONOMEDState createState() => _AcercaDeFONOMEDState();
}

class _AcercaDeFONOMEDState extends State<AcercaDeFONOMED>
    with TickerProviderStateMixin {
  List<bool> isExpanded = [false, false, false, false];

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String userName = "Usuario";
  String userEmail = "correo@ejemplo.com";

  @override
  void initState() {
    super.initState();
    _loadUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Usuario";
      userEmail = prefs.getString('user_email') ?? "correo@ejemplo.com";
    });
  }

  // ================== MENU SUPERIOR ===================
  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Home':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => IPhone1415Pro5Screen(
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        );
        break;

      case 'Zona de entrenamiento':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZonaDeEntrenamiento()),
        );
        break;

      case 'Historial de datos':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BandejaDeDatos()),
        );
        break;

      case 'Ayuda':
        
        break;
    }
  }

  // ===========================================================
  // ========================= UI ==============================
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 25),

            // ====== TÍTULO ======
            Center(
              child: Container(
                width: 308,
                decoration: BoxDecoration(
                  color: const Color(0xFF3868FE),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  "Ayuda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Merriweather",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ====== CONTENEDOR PRINCIPAL ======
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // ---------- Sección 1 ----------
                  _buildExpandableSection(
                    index: 0,
                    title: "¿Qué es FONOMED?",
                    content: const Text(
                      'Fonomed es una avanzada aplicación multiplataforma diseñada para el análisis, clasificación y optimización en la detección de sonidos cardíacos, incluyendo fonocardiogramas (FCG) y electrocardiogramas (ECG). Su objetivo principal es facilitar el diagnóstico temprano de enfermedades cardiovasculares en pacientes con acceso limitado a estudios médicos avanzados.\n\n'
                      'A través de esta aplicación, los usuarios pueden contribuir al reentrenamiento del clasificador de audios cardíacos, alimentando el sistema con nuevos datos que permiten mejorar su precisión y capacidad de detección.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: "Merriweather",
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // ---------- Sección 2 ----------
                  _buildExpandableSection(
                    index: 1,
                    title: "Patologías",
                    content: _buildPatologias(),
                  ),

                  // ---------- Sección 3 ----------
                  _buildExpandableSection(
                    index: 2,
                    title: "Manual de uso",
                    content: _buildManual(),
                  ),

                  // ---------- Sección 4 ----------
                  _buildExpandableSection(
                    index: 3,
                    title: "Soporte técnico",
                    content: const Text(
                      "Si encuentras un error, contacta:\n\n"
                      "📧 salvador.altamirano.guicho@gmail.com\n\n"
                      "Incluye una captura de pantalla y una breve descripción del problema.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Merriweather",
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // ===================== HEADER NUEVO ========================
  // ===========================================================
  Widget _buildHeader() {
    return // ===================== HEADER REORDENADO + FONOMED =====================
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 56, 104, 254),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ///  Botón Menú a la izquierda
                PopupMenuButton<String>(
                  icon: Image.asset('assets/images/Vector.png', width: 40),
                  onSelected: (value) => _onMenuSelected(context, value),
                  color: Colors.black87,
                  itemBuilder: (_) => [
                    'Home', 'Ayuda', 'Zona de entrenamiento', 'Historial de datos'
                  ].map((e) => PopupMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )).toList(),
                ),

                const SizedBox(width: 12),

                /// Foto del usuario
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "assets/images/Foto perfil.png",
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 14),

                /// Nombre + correo
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Merriweather"),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// 🟦 Texto "FONOMED"
                const Text(
                  "Fonomed",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Merriweather",
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                /// Logo a la derecha
                Image.asset("assets/images/Logo.png", width: 45),
              ],
            ),
          );
  }

  // ===========================================================
  // =============== SECCIÓN EXPANDIBLE ========================
  // ===========================================================
  Widget _buildExpandableSection({
    required int index,
    required String title,
    required Widget content,
  }) {
    final bool expanded = isExpanded[index];

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded[index] = !expanded;
              _controller.reset();
              _controller.forward();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: "Merriweather",
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3868FE),
                    ),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF3868FE),
                ),
              ],
            ),
          ),
        ),

        // --- Contenido con animación ---
        if (expanded)
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: content,
              ),
            ),
          ),

        const Divider(height: 1, color: Color(0xFFCCCCCC)),
      ],
    );
  }

  // ===========================================================
  // ================ MANUAL SECTION BUILDER ====================
  // ===========================================================
  Widget _buildManualSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),

        // Viñetas animadas
        ...items.map(
          (item) => SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  "• $item",
                  style: const TextStyle(
                    fontFamily: "Merriweather",
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ===========================================================
  // ==================== CONTENIDOS ============================
  // ===========================================================

  Widget _buildPatologias() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        textAlign: TextAlign.justify,
        text: const TextSpan(
          style: TextStyle(
            fontFamily: "Merriweather",
            fontSize: 14,
            color: Colors.black,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: 'Patologías Cardíacas Evaluadas\n\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text:
                    'En Fonomed, analizamos distintos sonidos del corazón para identificar posibles afecciones.\n\n'),

            TextSpan(
                text: '🔵 Estado Normal\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'Sonidos S1 y S2 regulares, indicando flujo normal.\n\n'),

            TextSpan(
                text: '🟠 Clic Cardíaco\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'Sonido corto y agudo asociado a prolapso mitral.\n\n'),

            TextSpan(
                text: '🟡 Soplo Temprano\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'Se presenta después de S1, relacionado con estenosis o insuficiencia valvular.\n\n'),

            TextSpan(
                text: '🟢 Soplo Medio\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'A mitad del ciclo cardíaco, indica resistencia en válvulas.\n\n'),

            TextSpan(
                text: '🔴 Soplo Tardío\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'Justo antes de S2, asociado a insuficiencia aórtica.\n\n'),

            TextSpan(
                text: '⚫ Soplo Holosistólico\n',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'Durante toda la sístole, indica insuficiencia valvular o defectos del tabique.\n'),
          ],
        ),
      ),
    );
  }

  Widget _buildManual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interfaz y Funcionalidades',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        _buildManualSection(
          title: "1. Pantalla Principal",
          items: [
            'Botón "Zona de entrenamiento": Área para análisis de audios cardíacos.',
            'Botón "Acerca de FONOMED": Información general.',
            'Botón "Historial de Datos": Ver registros enviados.',
          ],
        ),

        _buildManualSection(
          title: "2. Zona de Entrenamiento",
          items: [
            'Paso 1: Ingresar Datos del Paciente y cargar archivo de audio.',
            'Paso 2: Visualizar forma de onda y usar controles de reproducción.',
            'Paso 3: Presionar "Analizar Audio" para obtener diagnóstico.',
            'Paso 4: Seleccionar patología correcta y subir datos a la nube.',
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Recomendaciones para una Mejor Contribución",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Merriweather",
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '✅ Grabaciones claras y sin ruido.\n'
          '✅ Duración recomendada: 10–30 segundos.\n'
          '✅ Verificar patología antes de subir.',
          style: TextStyle(
            fontFamily: "Merriweather",
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
