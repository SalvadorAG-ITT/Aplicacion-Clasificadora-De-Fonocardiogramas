import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const PasswordResetScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  /// 🔹 control del botón mostrar/ocultar contraseña
  bool _obscurePass1 = true;
  bool _obscurePass2 = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingrese y confirme la contraseña');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/reset-password'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': widget.email,
          'code': widget.verificationCode,
          'newPassword': _newPasswordController.text,
        }),
      ).timeout(const Duration(seconds: 30));

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw FormatException('Respuesta inesperada del servidor', response.body);
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() => _success = true);
        _showSuccessSnackBar('Contraseña cambiada exitosamente');

        Timer(const Duration(seconds: 2),
            () => Navigator.of(context).popUntil((route) => route.isFirst));
      } else {
        setState(() => _errorMessage = responseData['message'] ??
            'Error al cambiar contraseña (Código: ${response.statusCode})');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// 🔹 Widget reutilizable con estilos consistentes
  Widget _input(String hint, TextEditingController controller, bool pass,
      {required bool obscureText, required VoidCallback toggle}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        obscureText: pass ? obscureText : false,
        style: const TextStyle(fontFamily: "Merriweather"),
        decoration: InputDecoration(
          labelText: hint,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Colors.black54),
          suffixIcon: pass
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: toggle,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF3868FE),
        elevation: 0,
        title: const Text(
          'Restablecer Contraseña',
          style: TextStyle(fontFamily: "Merriweather"),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 40),

              Text(
                "Restablecer tu contraseña",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Merriweather",
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "Correo asociado: ${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: "Merriweather", fontSize: 16),
              ),

              const SizedBox(height: 28),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: "Merriweather", fontSize: 16),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              _input(
                "Nueva contraseña",
                _newPasswordController,
                true,
                obscureText: _obscurePass1,
                toggle: () => setState(() => _obscurePass1 = !_obscurePass1),
              ),

              const SizedBox(height: 18),

              _input(
                "Confirmar contraseña",
                _confirmPasswordController,
                true,
                obscureText: _obscurePass2,
                toggle: () => setState(() => _obscurePass2 = !_obscurePass2),
              ),

              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3868FE),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "Cambiar contraseña",
                        style: TextStyle(
                            fontFamily: "Merriweather",
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),

              if (_success) ...[
                const SizedBox(height: 20),
                const Center(child: Icon(Icons.check_circle,
                    color: Colors.green, size: 60)),
                const SizedBox(height: 10),
                const Center(
                    child: Text("Contraseña actualizada!",
                        style: TextStyle(
                            fontFamily: "Merriweather",
                            fontWeight: FontWeight.bold)))
              ]
            ],
          ),
        ),
      ),
    );
  }
}
