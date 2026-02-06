import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
//import '../utils/constants.dart';
import 'acerca_de_fonomed_screen.dart';
import 'iphone_14_15_pro_5.dart';
import 'zona_de_entrenamiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandejaDeDatos extends StatefulWidget {
  final String userName;
  final String userEmail;

  const BandejaDeDatos({
    super.key,
    this.userName = "Usuario",
    this.userEmail = "correo@ejemplo.com",
  });

  @override
  _BandejaDeDatosState createState() => _BandejaDeDatosState();
}

class _BandejaDeDatosState extends State<BandejaDeDatos>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _fileHistory = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _loading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadAudioHistory();
    _searchController.addListener(_onSearchChanged);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  // =============================================================
  // TOKEN
  // =============================================================
  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token no disponible.');
    }
    return token;
  }

  // =============================================================
  // Carga del historial
  // =============================================================
  Future<void> _loadAudioHistory() async {
    try {
      final token = await _obtenerToken();

      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/historial-audios'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _fileHistory = (data['audios'] as List).map((audio) {
            return {
              'id': audio['id'] ?? 0,
              'name': audio['name'] ?? 'Sin nombre',
              'date': audio['date'] ?? '',
              'path': audio['path'] ?? '',
              'size': audio['size'] ?? 0,
              'duration': audio['duration'] ?? 0,
            };
          }).toList();

          _filteredItems = List.from(_fileHistory);
          _loading = false;
        });
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // =============================================================
  // Reproducir audio
  // =============================================================
  Future<void> _playAudio(String url, int audioId) async {
    try {
      if (_currentlyPlayingId == audioId && _isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));

      setState(() => _currentlyPlayingId = audioId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al reproducir: $e")),
      );
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredItems = _fileHistory
          .where((item) =>
              item['name']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              item['date']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  // =============================================================
  // Menú
  // =============================================================
  void _onMenuSelected(String value) {
    switch (value) {
      case 'Home':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const IPhone1415Pro5Screen()));
        break;

      case 'Ayuda':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AcercaDeFONOMED()));
        break;

      case 'Zona de entrenamiento':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ZonaDeEntrenamiento()));
        break;

      case 'Historial de datos':
        break;
    }
  }

  // =============================================================
  // Formatters
  // =============================================================
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${units[i]}';
  }

// Error que ignore miserablemente:c

  // String _formatDuration(int s) {
  //  final d = Duration(seconds: s);
  //  return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  //}

  // =============================================================
  // Build
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF8),
      body: Column(
        children: [
          // ******************************************************************
          // 🔵 HEADER ESTÁNDAR
          // ******************************************************************
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF3868FE),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  icon: Image.asset('assets/images/Vector.png', width: 40),
                  onSelected: _onMenuSelected,
                  color: Colors.black87,
                  itemBuilder: (_) => [
                    'Home',
                    'Ayuda',
                    'Zona de entrenamiento',
                    'Historial de datos'
                  ]
                      .map((e) => PopupMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                ),

                const SizedBox(width: 12),

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

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Merriweather"),
                      ),
                      Text(
                        widget.userEmail,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

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

                Image.asset("assets/images/Logo.png", width: 45),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Center(
              child: Container(
                width: 308,
                decoration: BoxDecoration(
                  color: const Color(0xFF3868FE),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  "Historial de Audios",
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

            const SizedBox(height: 30),

          // ******************************************************************
          // BUSCADOR
          // ******************************************************************
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Buscar...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            color: Colors.grey),
                      ),
                    ),
                  ),

                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ******************************************************************
          // LISTA DE AUDIOS CON ANIMACIÓN + SOMBRA + ESTILO AZUL
          // ******************************************************************
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay audios guardados",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Inter",
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final audio = _filteredItems[index];

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: ListTile(
                              leading: Icon(Icons.audiotrack,
                                  color: Colors.blue.shade700, size: 32),
                              title: Text(
                                audio["name"],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${audio['date']}\n${_formatFileSize(audio['size'])}",
                                style: const TextStyle(
                                    height: 1.4, fontFamily: "Inter"),
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: Icon(
                                  _currentlyPlayingId == audio['id'] &&
                                          _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  size: 35,
                                  color: Colors.blue.shade800,
                                ),
                                onPressed: () => _playAudio(
                                  "http://127.0.0.1:3000${audio['path']}",
                                  audio["id"],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}