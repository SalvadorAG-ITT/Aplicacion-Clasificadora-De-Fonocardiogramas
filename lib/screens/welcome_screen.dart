import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'fonomed_registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navegación con transición suave sin paquetes
  void _navigate(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [

            /// 🔹 Header superior profesional
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF3868FE),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Fonomed",
                    style: TextStyle(
                      fontFamily: "Merriweather",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    "assets/images/Logo.png", 
                    width: 55,
                    height: 55,
                  ),
                ],
              ),
            ),

            /// 🔹 Cuerpo centrado
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      "Bienvenido a\nFONOMED",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Merriweather",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// 🔹 Logo con animación scale + fade
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          "assets/images/medical tech.png",
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Frase profesional opcional
                    const Text(
                      "Mejorando los diagnosticos médicos con tecnología avanzada.",
                      style: TextStyle(
                        fontFamily: "Merriweather",
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 50),

                    /// Botón principal mejorado
                    GestureDetector(
                      onTap: () => _navigate(const LoginScreen()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 230,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3868FE),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontFamily: "Merriweather",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿No tienes una cuenta? ",
                          style: TextStyle(
                            fontFamily: "Merriweather",
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _navigate(const FonomedRegistrationScreen()),
                          child: const Text(
                            "Regístrate",
                            style: TextStyle(
                              fontFamily: "Merriweather",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2856EA),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

