import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'acerca_de_fonomed_screen.dart';
import 'bandeja_de_datos.dart';
import 'zona_de_entrenamiento.dart';
import 'package:audioplayers/audioplayers.dart';


final AudioPlayer _audioPlayer = AudioPlayer();
Future<void> _playClickSound() async {
  await _audioPlayer.play(
    AssetSource('sounds/click.mp3'),
  );
}

class IPhone1415Pro5Screen extends StatefulWidget {
  final String userName;
  final String userEmail;

  /// Ahora el menú recibe los datos desde login correctamente
  const IPhone1415Pro5Screen({
  super.key,
  this.userName = "Usuario",
  this.userEmail = "Ejemplo@gmail.com",
  });

  @override
  State<IPhone1415Pro5Screen> createState() => _IPhone1415Pro5ScreenState();
}

class _IPhone1415Pro5ScreenState extends State<IPhone1415Pro5Screen> {
  String userName = "Usuario";
  String userEmail = "correo@ejemplo.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = widget.userName;                    // ← Valor recibido del Login
      userEmail = widget.userEmail;                  // ← Valor recibido del Login

      /// Si luego quieres usar SharedPref, puedes guardar los datos aquí:
      prefs.setString('user_name', userName);
      prefs.setString('user_email', userEmail);
    });
  }

  // ===================== MENÚ =====================
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

      case 'Acerca de FONOMED':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AcercaDeFONOMED()),
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
    }
  }

  // ===================== UI PRINCIPAL =====================
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.backgroundGray,
    body: SingleChildScrollView(
      child: Column(
        children: [
          // ===================== HEADER REORDENADO + FONOMED =====================
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
          ),

          const SizedBox(height: 20),

          // ================== NUEVO ORDEN DE OPCIONES ==================

          /// Zona de Entrenamiento
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: SizedBox(
                width: 400, 
                child: _menuItem(
                title: "Zona de Entrenamiento",
                image: "assets/images/medical tech.png",
                onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZonaDeEntrenamiento()),
                ) ,
              ),
            ),
          ),
        ),

          /// Historial de señales
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: SizedBox(
                width: 400, 
                child: _menuItem(
                title: "Historial de audios",
                image: "assets/images/Group.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BandejaDeDatos()),
                  ),
                ),
              ),
            ),
          ),

          /// Ayuda (antes Acerca de FONOMED)
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 60),
            child: Center(
              child: SizedBox(
                width: 400, // 👉 Aquí controlas el ancho de TODOS los botones
                child: _menuItem(
                title: "Ayuda",
                image: "assets/images/information.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AcercaDeFONOMED()),
                   ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  // =================== WIDGET DE TARJETAS ===================
  Widget _menuItem({
  required String title,
  required String image,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: () async {
      await _playClickSound();
      onTap();
    },
    //onTap: onTap,
    child: Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bloque azul con imagen
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFC3E5FF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Texto del título
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                fontFamily: "Merriweather",
                color: Color(0xFF3868FE),
              ),
              overflow: TextOverflow.fade,
            ),
          ),

          // Flecha elegante a la derecha
          const Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: Color(0xFF3868FE),
            ),
          ),
        ],
      ),
    ),
  );
}

}
