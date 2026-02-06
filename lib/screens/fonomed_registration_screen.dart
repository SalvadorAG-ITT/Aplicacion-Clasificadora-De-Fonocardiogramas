import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
// import 'welcome_screen.dart';
// import 'iphone_14_15_pro_5.dart';

class FonomedRegistrationScreen extends StatefulWidget {
  const FonomedRegistrationScreen({super.key});

  @override
  State<FonomedRegistrationScreen> createState() =>
      _FonomedRegistrationScreenState();
}

class _FonomedRegistrationScreenState extends State<FonomedRegistrationScreen> {
  bool isRegistering = true;
  bool isLoading = false; // Nuevo estado para manejar el loading

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  // Método para registrar usuario
  Future<void> _registerUser() async {
    setState(() {
      isLoading = true;
    });

    // Validar campos vacíos
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Validar formato de email
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un correo electrónico válido'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:3000/api/register',
        ), // Para emulador Android usa 10.0.2.2
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nombre_completo': _nameController.text,
          'correo_electronico': _emailController.text,
          'contrasena': _passwordController.text,
          'telefono_celular': _numberController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registro exitoso
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
        // Navegar a la pantalla principal
        Navigator.pushReplacement(
        context,
        _fadeRoute(const LoginScreen()),
);
      } else {
        // Error en el registro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Error en el registro'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

Route _fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: animation,
      child: page,
    ),
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

            // 🔵 BARRA SUPERIOR estilo login
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

            const SizedBox(height: 40),

            // ================= Tarjeta principal =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // 🔘 Botones superiores estilo login
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDFF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                _fadeRoute(const LoginScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                "Ingresar",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Merriweather",
                                  fontSize: 20,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3868FE),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Text(
                              "Registrarse",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Merriweather",
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ================= Campos =================

                  _inputBox("Nombre completo", _nameController),
                  const SizedBox(height: 18),

                  _inputBox("Correo electrónico", _emailController, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 18),

                  _inputBox("Contraseña", _passwordController, obscure: true),
                  const SizedBox(height: 18),

                  _inputBox("Número de teléfono", _numberController, keyboard: TextInputType.phone),

                  const SizedBox(height: 35),

                  // ================= Botón registrar =================
                  ElevatedButton(
                    onPressed: isLoading ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3868FE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Registrarse", style: TextStyle(fontFamily: "Merriweather", fontSize: 24, color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    ),
  );
}

// ====== Mini widget reutilizable para inputs ======
Widget _inputBox(String text, TextEditingController controller,
    {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    decoration: InputDecoration(
      hintText: text,
      filled: true,
      fillColor: const Color(0xFFEFF2FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
  );
}

}
