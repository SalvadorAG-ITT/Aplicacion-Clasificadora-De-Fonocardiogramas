import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'iphone_14_15_pro_5.dart';
import 'fonomed_registration_screen.dart';
import 'password_reset_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginSelected = true;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _recoveryCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _recoveryEmailController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  // ---------------- LOGIN ----------------
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Por favor ingrese correo y contraseña');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'correo_electronico': _emailController.text,
          'contrasena': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString('user_email', _emailController.text);
        await prefs.setInt('user_id', responseData['userData']['id'] ?? 0);

        // 🔥 PASA NOMBRE Y EMAIL AL MENÚ PRINCIPAL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IPhone1415Pro5Screen(
              userName: responseData['userData']['nombre'] ?? 'Usuario',
              userEmail: _emailController.text,
            ),
          ),
        );

      } else {
        _showErrorSnackBar(responseData['message'] ?? 'Credenciales incorrectas');
      }
    } on TimeoutException {
      _showErrorSnackBar('Tiempo agotado. Intente nuevamente');
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }

    setState(() => _isLoading = false);
  }

  // ---------------- RECUPERACIÓN ----------------
  Future<void> _sendRecoveryCode() async {
    if (_recoveryEmailController.text.isEmpty || 
        !_recoveryEmailController.text.contains('@')) {
      _showErrorSnackBar('Ingrese un correo válido');
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/request-reset-code'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': _recoveryEmailController.text}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success']) {
        _showSuccessSnackBar('Código enviado');
      } else {
        _showErrorSnackBar(data['message'] ?? 'Error al enviar código');
      }
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  Future<void> _verifyRecoveryCode() async {
    if (_recoveryCodeController.text.isEmpty) {
      _showErrorSnackBar('Ingrese el código');
      return;
    }

    setState(() => _isVerifyingCode = true);

    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/verify-recovery-code'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': _recoveryEmailController.text.trim(),
          'code': _recoveryCodeController.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success']) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PasswordResetScreen(
              email: _recoveryEmailController.text.trim(),
              verificationCode: _recoveryCodeController.text.trim(),
            ),
          ),
        );
      } else {
        _showErrorSnackBar(data['message'] ?? 'Código incorrecto');
      }
    } finally {
      setState(() => _isVerifyingCode = false);
    }
  }

  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _recoveryEmailController, decoration: InputDecoration(labelText: 'Correo')),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isSendingCode ? null : _sendRecoveryCode,
              child: _isSendingCode ? CircularProgressIndicator() : Text('Enviar Código'),
            ),
            const SizedBox(height: 20),
            TextField(controller: _recoveryCodeController, decoration: InputDecoration(labelText: 'Código')),
          ],
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: _isVerifyingCode ? null : _verifyRecoveryCode,
            child: _isVerifyingCode ? CircularProgressIndicator() : const Text('Verificar'),
          )
        ],
      ),
    );
  }

  void _showErrorSnackBar(msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red),
  );

  void _showSuccessSnackBar(msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.green),
  );

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // 🔵 Header superior
              Container(
                height: 90,
                width: double.infinity,
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
                    Text("Fonomed",
                      style: TextStyle(fontFamily: "Merriweather", fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Image.asset("assets/images/Logo.png", width: 55),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Panel login
              Container(
                width: 350,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
                ),
                child: Column(children: [

                  // Selector
                  Container(
                    decoration: BoxDecoration(color: Color(0xFFE8EDFF), borderRadius: BorderRadius.circular(40)),
                    child: Row(children: [

                      Expanded(
                        child: GestureDetector(
                          onTap: ()=> setState(()=> _isLoginSelected = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color:_isLoginSelected? Color(0xFF3868FE):Colors.transparent,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Text("Ingresar",textAlign: TextAlign.center,
                              style: TextStyle(color:_isLoginSelected?Colors.white:Colors.black54,fontFamily:"Merriweather",fontSize:20),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            setState(()=> _isLoginSelected=false);
                            Navigator.pushReplacement(context,_fadeRoute(FonomedRegistrationScreen()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: !_isLoginSelected ? Color(0xFF3868FE) : Colors.transparent,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Text("Registrarse",textAlign: TextAlign.center,
                              style: TextStyle(color: !_isLoginSelected?Colors.white:Colors.black54,fontFamily:"Merriweather",fontSize:20),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  SizedBox(height: 35),
                  TextField(
                    controller: _emailController,
                    decoration: input("Correo electrónico"),
                  ),
                  SizedBox(height: 25),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: input("Contraseña"),
                  ),
                  SizedBox(height: 35),

                  ElevatedButton(
                    onPressed:_isLoading?null:_loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3868FE),
                      minimumSize: Size(280, 60), // Ancho - Alto
                      // padding: EdgeInsets.symmetric(vertical: 25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child:_isLoading?CircularProgressIndicator(color: Colors.white)
                    : Text("  Entrar  ",style: TextStyle(fontFamily:"Merriweather",fontSize:24,color:Colors.white)),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 15), // ajusta el valor para bajarlo más/menos
                    child: TextButton(
                      onPressed: _showRecoveryDialog,
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: Color(0xFF3868FE),
                          decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),  
                ]),
              ),

              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration input(String text)=>InputDecoration(
    hintText: text,filled:true,fillColor:Color(0xFFEFF2FF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide:BorderSide.none),
    contentPadding: EdgeInsets.all(18),
  );

  Route _fadeRoute(Widget page)=>PageRouteBuilder(
    transitionDuration: Duration(milliseconds:350),
    pageBuilder: (_,a,__)=>
      FadeTransition(opacity:a,child:page),
  );
}
