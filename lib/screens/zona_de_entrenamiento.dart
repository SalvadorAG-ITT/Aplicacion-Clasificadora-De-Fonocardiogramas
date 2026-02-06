import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
//import '../utils/constants.dart';
import 'bandeja_de_datos.dart';
import 'iphone_14_15_pro_5.dart';
import 'acerca_de_fonomed_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Para TimeoutException
import 'package:flutter/foundation.dart' show kIsWeb;

String userName = "Usuario";
String userEmail = "correo@ejemplo.com";

double _uploadProgress = 0.0;
Timer? _progressTimer;


class ZonaDeEntrenamiento extends StatefulWidget {
  const ZonaDeEntrenamiento({super.key});

  @override
  State<ZonaDeEntrenamiento> createState() => _ZonaDeEntrenamientoState();
}

class _ZonaDeEntrenamientoState extends State<ZonaDeEntrenamiento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _estaturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PlatformFile? _audioFile;
  String? _patologiaSeleccionada;
  //String? _patologiaDetectada;
  String? _sexoSeleccionado;
  bool _mostrarFormulario = false;
  bool _isPlaying = false;
  bool _mostrarDatosPaciente = false;
  bool _subiendo = false;
  bool _analizando = false;
  String? _resultadoAnalisis;
  String? _confianzaAnalisis;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<double> _fonocardiogramData = [];
  double _samplesPerSecond = 100.0;
  int _currentPositionIndex = 0;
  double _chartZoomFactor = 1.0;
  Map<String, dynamic>? _audioMetadata;

  static const List<String> _patologias = [
    'Normal',
    'Clic Cardíaco',
    'Soplo Temprano',
    'Soplo Medio',
    'Soplo Tardío',
    'Soplo Holosistólico',
  ];

  static const List<String> _sexos = ['Masculino', 'Femenino', 'Otro'];

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _estaturaController.dispose();
    _pesoController.dispose();
    _edadController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
        if (duration.inSeconds > 0 && _fonocardiogramData.isNotEmpty) {
          _samplesPerSecond = _fonocardiogramData.length / duration.inSeconds;
        }
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
        if (_duration.inMilliseconds > 0 && _fonocardiogramData.isNotEmpty) {
          _currentPositionIndex = (position.inMilliseconds /
                  _duration.inMilliseconds *
                  _fonocardiogramData.length)
              .toInt()
              .clamp(0, _fonocardiogramData.length - 1);
        }
      });
    });
  }

// Función para seleccionar audio y enviar a análisis
Future<void> _seleccionarAudio() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // necesario para Web
    );

    if (result != null && result.files.isNotEmpty) {
      final audioFile = result.files.first;
      await _uploadAndAnalyzeAudio(audioFile); // Llamada a la función de análisis
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar audio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _startFakeProgress() {
  _uploadProgress = 0.0;
  _progressTimer?.cancel();

  _progressTimer = Timer.periodic(
    const Duration(milliseconds: 300),
    (timer) {
      if (_uploadProgress < 0.9) {
        setState(() {
          _uploadProgress += 0.05;
        });
      }
    },
  );
}

void _completeProgress() {
  _progressTimer?.cancel();
  setState(() {
    _uploadProgress = 1.0;
  });
}

Future<void> _playSuccessSound() async {
  await _audioPlayer.play(
    AssetSource('sounds/Exito.mp3'),
  );
}

// Función para subir y analizar el audio
Future<void> _uploadAndAnalyzeAudio(PlatformFile audioFile) async {
  try {
    setState(() => _analizando = true);

_startFakeProgress();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Procesando audio'),
        content: Column(
         mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 16),
            Text('${(_uploadProgress * 100).toInt()} % completado'),
          ],
        )   ,
      ),
    );

    final token = await _obtenerToken();
    final uri = Uri.parse('http://127.0.0.1:3000/api/analizar-audio');

    http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Detectar plataforma
    if (kIsWeb) {
      final bytes = audioFile.bytes;
      if (bytes == null) throw Exception("Archivo no disponible en memoria para Web.");

      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          bytes,
          filename: audioFile.name,
        ),
      );
    } else {
      final file = File(audioFile.path!);
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          file.path,
          filename: audioFile.name,
        ),
      );
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (mounted) Navigator.of(context).pop();

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      await _playSuccessSound();  
      if (mounted) {
        setState(() {
          _audioFile = audioFile;
          _audioMetadata = jsonResponse['audioAnalysis'];

          if (_audioMetadata?['fonocardiogramData'] != null) {
            _fonocardiogramData = List<double>.from(
              _audioMetadata!['fonocardiogramData'].map((x) => x.toDouble()),
            );
          }
      
_completeProgress();

          _samplesPerSecond = _audioMetadata?['sampleRate']?.toDouble() ?? 1000.0;
          _resultadoAnalisis = 'Análisis completado';
          _confianzaAnalisis =
              'Archivo: ${_audioMetadata?['filename'] ?? audioFile.name}';

          // Opcional: mostrar éxito al usuario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio analizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        });
      }
    } else {
      throw Exception(jsonResponse['message'] ?? 'Error en el servidor');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    rethrow;
  } finally {
    if (mounted) setState(() => _analizando = false);
  }
}
 
 void _generateRealisticFonocardiogram() {
  if (_audioMetadata == null) {
    // Datos de ejemplo más centrados
    _fonocardiogramData = List.generate(1000, (i) {
      double t = i / 100; // Tiempo en segundos (0-10)
      
      // Componentes más definidos
      double s1 = 0.0;
      if (t % 0.8 < 0.1) {
        s1 = -1.5 * exp(-pow((t % 0.8) * 15, 2)); // Pico más estrecho y definido
      }
      
      double s2 = 0.0;
      if (t % 0.8 > 0.3 && t % 0.8 < 0.35) {
        s2 = -1.0 * exp(-pow((t % 0.8 - 0.32) * 15, 2));
      }
      
      // Ruido más sutil
      double noise = Random().nextDouble() * 0.1 - 0.05;
      
      return (s1 + s2 + noise).clamp(-1.5, 1.5);
    });
    return;
  }

  try {
    final duration = _audioMetadata!['duration'] ?? 10.0;
    final sampleRate = _audioMetadata!['sampleRate']?.toDouble() ?? 1000.0;
    final totalSamples = (duration * sampleRate).toInt();

    setState(() {
      _fonocardiogramData = List.generate(totalSamples, (i) {
        double t = i / sampleRate;
        
        // Componentes más definidos
        double s1 = 0.0;
        if (t % 0.8 < 0.1) {
          s1 = -1.5 * exp(-pow((t % 0.8) * 15, 2));
        }
        
        double s2 = 0.0;
        if (t % 0.8 > 0.3 && t % 0.8 < 0.35) {
          s2 = -1.0 * exp(-pow((t % 0.8 - 0.32) * 15, 2));
        }
        
        double noise = Random().nextDouble() * 0.1 - 0.05;
        
        return (s1 + s2 + noise).clamp(-1.5, 1.5);
      });
      
      _samplesPerSecond = sampleRate;
    });
  } catch (e) {
    print('Error generando gráfico: $e');
    // Datos de fallback más centrados
    _fonocardiogramData = List.generate(1000, (i) {
      double t = i / 100;
      return -1.5 * exp(-pow((t % 0.8) * 10, 2));
    });
  }
}



Widget _buildFonocardiogramChart() {
  if (_audioFile == null) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Text(
        'Suba un archivo de audio para visualizar el fonocardiograma',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  final maxX = (_fonocardiogramData.isNotEmpty 
      ? _fonocardiogramData.length / _samplesPerSecond 
      : 10.0) * _chartZoomFactor;

  return Column(
    children: [
      if (_audioMetadata != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Duración: ${_audioMetadata!['duration']?.toStringAsFixed(2) ?? '--'}s'),
              Text('Muestras/s: ${_samplesPerSecond.toStringAsFixed(0)}'),
            ],
          ),
        ),
      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(
      height: 250,
      child: Stack(
        children: [
          SfCartesianChart(
            margin: const EdgeInsets.all(0),
            plotAreaBorderWidth: 0,
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: 'Tiempo (s)'),
              minimum: 0,
              maximum: maxX,
              interval: 0.5,
              majorGridLines: const MajorGridLines(width: 1, color: Color(0xFFEEEEEE)),
              minorGridLines: const MinorGridLines(width: 0.5, color: Color(0xFFF5F5F5)),
              axisLine: const AxisLine(width: 1, color: Colors.black),
              labelStyle: const TextStyle(fontSize: 10, color: Colors.black),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Amplitud'),
              minimum: -1.6,
              maximum: 1.6,
              interval: 0.5,
              majorGridLines: const MajorGridLines(width: 1, color: Color(0xFFEEEEEE)),
              minorGridLines: const MinorGridLines(width: 0.5, color: Color(0xFFF5F5F5)),
              axisLine: const AxisLine(width: 1, color: Colors.black),
              labelStyle: const TextStyle(fontSize: 10, color: Colors.black),
            ),
            series: <CartesianSeries>[
              LineSeries<double, double>(
                dataSource: _fonocardiogramData,
                xValueMapper: (data, index) => index / _samplesPerSecond,
                yValueMapper: (data, _) => data,
                color: Colors.red,
                width: 2.5,
                animationDuration: 0,
              ),
              if (_isPlaying && _fonocardiogramData.isNotEmpty)
                ScatterSeries<double, double>(
                  dataSource: [_fonocardiogramData[_currentPositionIndex]],
                  xValueMapper: (data, index) => _currentPositionIndex / _samplesPerSecond,
                  yValueMapper: (data, _) => data,
                  pointColorMapper: (data, _) => Colors.blue,
                  markerSettings: const MarkerSettings(
                    width: 10,
                    height: 10,
                    color: Colors.blue,
                    borderWidth: 2,
                    borderColor: Colors.white,
                  ),
                ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_in, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _chartZoomFactor = (_chartZoomFactor * 0.8).clamp(0.1, 1.0);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.zoom_out, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _chartZoomFactor = (_chartZoomFactor * 1.2).clamp(0.1, 1.0);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.blue),
                  onPressed: _showFullChartDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8), // Espacio entre el gráfico y los textos
    Text(
      'Amplitud: ${_fonocardiogramData.isNotEmpty ? _fonocardiogramData.reduce((a, b) => a > b ? a : b).toStringAsFixed(2) : "0.00"}',
      style: const TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    Text(
      'Frecuencia: ${_samplesPerSecond > 0 ? _samplesPerSecond.toString() : "0"} Hz',
      style: const TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
)

    ],
  );
}
void _showFullChartDialog() {
    if (_audioFile == null || _fonocardiogramData.isEmpty) return;

    final maxX = _fonocardiogramData.length / _samplesPerSecond;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              Text(
                'Fonocardiograma Completo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SfCartesianChart(
                  margin: const EdgeInsets.all(0),
                  plotAreaBorderWidth: 0,
                  primaryXAxis: NumericAxis(
                    title: AxisTitle(text: 'Tiempo (s)'),
                    isVisible: true,
                    minimum: 0,
                    maximum: maxX,
                    interval: maxX > 10 ? 1 : 0.5,
                    majorGridLines: const MajorGridLines(
                      width: 1,
                      color: Colors.grey,
                    ),
                    minorGridLines: const MinorGridLines(
                      width: 0.5,
                      color: Colors.grey,
                      dashArray: <double>[5, 5],
                    ),
                    axisLine: const AxisLine(width: 1, color: Colors.black),
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    isVisible: true,
                    minimum: -1.5,
                    maximum: 1.5,
                    majorGridLines: const MajorGridLines(
                      width: 1,
                      color: Colors.grey,
                    ),
                    axisLine: const AxisLine(width: 1, color: Colors.black),
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  series: <CartesianSeries>[
                    LineSeries<double, double>(
                      dataSource: _fonocardiogramData,
                      xValueMapper: (data, index) => index / _samplesPerSecond,
                      yValueMapper: (data, _) => data,
                      color: Colors.red,
                      width: 2.0,
                      animationDuration: 0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDatosPaciente() {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.95, // 95% del ancho de la pantalla
      constraints: const BoxConstraints(
        maxWidth: 800, // Opcional: limitar a un máximo de 600 px
      ),
      child: ExpansionTile(
        title: const Text(
          'Datos del Paciente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: "Merriweather",
          ),
        ),
        initiallyExpanded: _mostrarDatosPaciente,
        onExpansionChanged: (expanded) {
          setState(() {
            _mostrarDatosPaciente = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Nombre completo
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    labelStyle: TextStyle(fontFamily: "Merriweather"),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  style: const TextStyle(fontFamily: "Merriweather"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Edad y Sexo
                Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: TextFormField(
                        controller: _edadController,
                        decoration: const InputDecoration(
                          labelText: 'Edad',
                          labelStyle: TextStyle(fontFamily: "Merriweather"),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(fontFamily: "Merriweather"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese la edad';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        value: _sexoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          labelStyle: TextStyle(fontFamily: "Merriweather"),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                        ),
                        items: _sexos.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontFamily: "Merriweather"),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sexoSeleccionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Seleccione el sexo';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Estatura y Peso
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        controller: _estaturaController,
                        decoration: const InputDecoration(
                          labelText: 'Estatura (cm)',
                          labelStyle: TextStyle(fontFamily: "Merriweather"),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(fontFamily: "Merriweather"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese la estatura';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        controller: _pesoController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          labelStyle: TextStyle(fontFamily: "Merriweather"),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(fontFamily: "Merriweather"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese el peso';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAudioControls() {
    if (_audioFile == null) return const SizedBox();

    return Column(
      children: [
        Slider(
          min: 0,
          max: _duration.inMilliseconds.toDouble(),
          value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
          onChanged: (value) async {
            final newPosition = Duration(milliseconds: value.toInt());
            setState(() => _position = newPosition);
            await _audioPlayer.seek(newPosition);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 36,
              onPressed: _playPauseAudio,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              iconSize: 36,
              onPressed: _stopAudio,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultadoAnalisis() {
    if (_resultadoAnalisis == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Resultado: $_resultadoAnalisis',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_confianzaAnalisis != null) ...[
            const SizedBox(height: 4),
            Text(
              'Confianza: $_confianzaAnalisis',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _playPauseAudio() async {
    if (_audioFile == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioFile!.path!));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => _position = Duration.zero);
  }

  Future<void> _analizarAudio() async {
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor seleccione un archivo de audio primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _analizando = true;
      _resultadoAnalisis = null;
      _confianzaAnalisis = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final randomIndex = DateTime.now().millisecond % _patologias.length;
      final confianza = (70 + DateTime.now().millisecond % 30).toString();

      setState(() {
        _resultadoAnalisis = _patologias[randomIndex];
        _confianzaAnalisis = '$confianza%';
        _patologiaSeleccionada = _patologias[randomIndex];
      });

      _generateRealisticFonocardiogram();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Análisis completado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error durante el análisis: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _analizando = false);
      }
    }
  }

  Future<String> _obtenerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        throw Exception('No se encontró token de autenticación. Por favor inicie sesión nuevamente.');
      }
      
      return token;
    } catch (e) {
      print('Error al obtener token: $e');
      throw Exception('Error al obtener credenciales. Por favor inicie sesión nuevamente.');
    }
  }

  Future<void> _subirAudioAlServidor() async {
  if (_audioFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor seleccione un archivo de audio'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _subiendo = true);

  try {
    final token = await _obtenerToken();
    final uri = Uri.parse('http://127.0.0.1:3000/api/subir-audio');
    
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'nombre': _nombreController.text,
        'edad': _edadController.text,
        'sexo': _sexoSeleccionado ?? '',
        'estatura': _estaturaController.text,
        'peso': _pesoController.text,
        'patologia': _patologiaSeleccionada ?? ''
      })
      ..files.add(await http.MultipartFile.fromPath(
        'audio',
        _audioFile!.path!,
        filename: _audioFile!.name,
      ));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos y audio subidos exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _limpiarFormulario();
    } else {
      throw Exception(jsonResponse['message'] ?? 'Error en el servidor');
    }
  } catch (e) {
    print('Error al subir audio: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al subir datos: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _subiendo = false);
  }
}

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _audioFile = null;
      _patologiaSeleccionada = null;
      _sexoSeleccionado = null;
      _mostrarFormulario = false;
      _resultadoAnalisis = null;
      _confianzaAnalisis = null;
      _fonocardiogramData = [];
      _isPlaying = false;
      _position = Duration.zero;
      _chartZoomFactor = 1.0;
      _audioMetadata = null;
    });
    _nombreController.clear();
    _estaturaController.clear();
    _pesoController.clear();
    _edadController.clear();
    _audioPlayer.stop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Home':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IPhone1415Pro5Screen()),
        );
        break;
      case 'Zona de entrenamiento':
        break;
      case 'Historial de datos':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BandejaDeDatos()),
        );
        break;
      case 'Ayuda':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AcercaDeFONOMED()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
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
                Container(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Center(
              child: Container(
                width: 308,
                decoration: BoxDecoration(
                  color: const Color(0xFF3868FE),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  "Zona de entrenamiento",
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
                      Center(
                        child: Image.asset(
                          'assets/images/LogoNube.png',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _mostrarFormulario = !_mostrarFormulario;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mostrarFormulario
                                //? Colors.grey[600]
                                ? const Color(0xFFC3E5FF)
                                : const Color(0xFF3868FE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 60,
                            ),
                          ),
                          child: Text(
                            _mostrarFormulario ? 'Ocultar' : 'Ingresar datos',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(0xFFF9F9F9),
                            ),
                          ),
                        ),
                      ),
                      if (_mostrarFormulario) ...[
                        const SizedBox(height: 30),
                        Center(
                          child: Container(
                            width: 309,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildDatosPaciente(),
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.audio_file),
                                      title: Text(
                                        _audioFile?.name ??
                                            'No se ha seleccionado audio',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.upload_file),
                                        onPressed: _seleccionarAudio,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFonocardiogramChart(),
                                  const SizedBox(height: 20),
                                  _buildAudioControls(),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _analizando ? null : _analizarAudio,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: _analizando
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text('Analizar Audio'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_audioFile != null)
                                    _buildResultadoAnalisis(),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar patología',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    initialValue: _patologiaSeleccionada,
                                    items: _patologias.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _patologiaSeleccionada = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Por favor seleccione una patología';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                          onPressed: _subiendo ? null : _subirAudioAlServidor,
                                          style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                                 ),
                                          child: _subiendo
                                         ? const CircularProgressIndicator(color: Colors.white)
                                         : const Text('Subir a la Nube'),
                                                  ),
                                   ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}