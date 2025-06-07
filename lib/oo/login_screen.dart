// virtual_tryon_widget.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

// Servicio para comunicarse con el backend
class VirtualTryonService {
  final String baseUrl;
  final String authToken;
  final String tenantId;

  VirtualTryonService({
    required this.baseUrl,
    required this.authToken,
    required this.tenantId,
  });

  // Método para crear try-on subiendo archivos directamente
  Future<Map<String, dynamic>> uploadAndCreateTryon({
    required File userImage,
    required File garmentImage,
    String? productoId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/virtual-tryon/upload-and-create'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $authToken',
        'X-Tenant-ID': tenantId,
      });

      request.files.add(await http.MultipartFile.fromPath('images', userImage.path));
      request.files.add(await http.MultipartFile.fromPath('images', garmentImage.path));
      
      if (productoId != null) {
        request.fields['productoId'] = productoId;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseData);
      } else {
        throw Exception('Error subiendo imágenes: $responseData');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método alternativo usando base64
  Future<Map<String, dynamic>> createTryonFromBase64({
    required String userImageBase64,
    required String garmentImageBase64,
    String? productoId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/virtual-tryon/create-from-base64'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'X-Tenant-ID': tenantId,
        },
        body: jsonEncode({
          'userImageBase64': userImageBase64,
          'garmentImageBase64': garmentImageBase64,
          'productoId': productoId,
          'metadata': {'source': 'flutter_app'}
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error creando try-on: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Verificar estado de la sesión
  Future<Map<String, dynamic>> checkSessionStatus(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/virtual-tryon/session/$sessionId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Tenant-ID': tenantId,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error verificando estado: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Polling para verificar cuando esté listo
  Future<Map<String, dynamic>> waitForCompletion(String sessionId) async {
    const maxAttempts = 60; // 5 minutos máximo
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final status = await checkSessionStatus(sessionId);
        
        if (status['status'] == 'completed') {
          return status;
        } else if (status['status'] == 'failed') {
          throw Exception('Try-on falló: ${status['errorMessage'] ?? 'Error desconocido'}');
        }
        
        // Esperar 5 segundos antes de verificar nuevamente
        await Future.delayed(Duration(seconds: 5));
        attempts++;
      } catch (e) {
        if (attempts >= maxAttempts - 1) rethrow;
        await Future.delayed(Duration(seconds: 5));
        attempts++;
      }
    }
    
    throw Exception('Timeout: El procesamiento tomó demasiado tiempo');
  }

  // Convertir archivo a base64
  Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    final extension = file.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    
    if (extension == 'png') mimeType = 'image/png';
    else if (extension == 'webp') mimeType = 'image/webp';
    
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
}

// Widget principal del probador virtual
class VirtualTryonWidget extends StatefulWidget {
  @override
  _VirtualTryonWidgetState createState() => _VirtualTryonWidgetState();
}

class _VirtualTryonWidgetState extends State<VirtualTryonWidget> {
  // Configuración del servicio - CAMBIAR ESTOS VALORES
  late final VirtualTryonService _tryonService;
  
  final ImagePicker _picker = ImagePicker();
  File? _userImage;
  File? _garmentImage;
  String? _resultImageUrl;
  bool _isProcessing = false;
  String _statusMessage = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // CONFIGURACIÓN IMPORTANTE - CAMBIAR ESTOS VALORES
    _tryonService = VirtualTryonService(
      baseUrl: 'http://192.168.1.10:3000', // ← CAMBIAR por tu IP real
      authToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImYyNGY4YjYyLWJmNjEtNDU5Ny04MjQ4LTRkM2RmYTI0YmRkYSIsImVtYWlsIjoiY2xpZW50ZUB0ZXN0LmNvbSIsImZpcnN0TmFtZSI6Ikp1YW4iLCJsYXN0TmFtZSI6IlDDqXJleiIsInR5cGUiOiJjbGllbnRlIiwidGVuYW50SWQiOiJiODc3Zjk3Ny04NzAzLTRmMzItYWJkZS02NWRmYWYyMDJhZjAiLCJpYXQiOjE3NDg3MDMzNTgsImV4cCI6MTc0OTMwODE1OH0.vxMlk2WZpI8c-sDsPP9ScRPv2Soqo10NaLyiB6duZeU',           // ← CAMBIAR por token real
      tenantId: 'tienda-abc',             // ← CAMBIAR por tenant real
    );
  }

  // Método para seleccionar imagen del usuario
  Future<void> _pickUserImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _userImage = File(image.path);
          _resultImageUrl = null; // Limpiar resultado anterior
        });
      }
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  // Método para seleccionar imagen de la prenda
  Future<void> _pickGarmentImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _garmentImage = File(image.path);
          _resultImageUrl = null; // Limpiar resultado anterior
        });
      }
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  // Método principal para procesar el try-on
  Future<void> _processTryon() async {
      print('🚀🚀🚀 BOTÓN PRESIONADO - INICIANDO PROCESO 🚀🚀🚀');
  
  if (_userImage == null || _garmentImage == null) {
    print('❌ Falta seleccionar imágenes');
    _showError('Por favor selecciona ambas imágenes');
    return;
  }
  
  print('✅ Ambas imágenes seleccionadas, continuando...');
    if (_userImage == null || _garmentImage == null) {
      _showError('Por favor selecciona ambas imágenes');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Subiendo imágenes...';
      _progress = 0.1;
    });

    try {
      // Opción 1: Subir archivos directamente (recomendado)
      Map<String, dynamic> session;
      
      try {
        setState(() {
          _statusMessage = 'Enviando al servidor...';
          _progress = 0.3;
        });
        
        session = await _tryonService.uploadAndCreateTryon(
          userImage: _userImage!,
          garmentImage: _garmentImage!,
        );
      } catch (e) {
        // Opción 2: Si falla, intentar con base64
        setState(() {
          _statusMessage = 'Reintentando con método alternativo...';
          _progress = 0.2;
        });
        
        final userBase64 = await _tryonService.fileToBase64(_userImage!);
        final garmentBase64 = await _tryonService.fileToBase64(_garmentImage!);
        
        session = await _tryonService.createTryonFromBase64(
          userImageBase64: userBase64,
          garmentImageBase64: garmentBase64,
        );
      }

      setState(() {
        _statusMessage = 'Procesando con IA...';
        _progress = 0.5;
      });

      // Esperar a que termine el procesamiento
      final result = await _tryonService.waitForCompletion(session['id']);

      setState(() {
        _statusMessage = 'Completado!';
        _progress = 1.0;
        _resultImageUrl = result['resultImageUrl'];
        _isProcessing = false;
      });

      _showSuccess('¡Try-on completado exitosamente!');

    } catch (error) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
        _progress = 0.0;
      });

      _showError('Error: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _clearImages() {
    setState(() {
      _userImage = null;
      _garmentImage = null;
      _resultImageUrl = null;
      _statusMessage = '';
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Probador Virtual IA'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (_userImage != null || _garmentImage != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _clearImages,
              tooltip: 'Limpiar imágenes',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado informativo
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Probador Virtual con IA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Selecciona tu foto y una prenda para ver cómo te queda',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Sección de selección de imágenes
            Row(
              children: [
                // Imagen del usuario
                Expanded(
                  child: _buildImageCard(
                    'Tu Foto',
                    _userImage,
                    _pickUserImage,
                    Icons.person,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                // Imagen de la prenda
                Expanded(
                  child: _buildImageCard(
                    'Prenda',
                    _garmentImage,
                    _pickGarmentImage,
                    Icons.checkroom,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // Barra de progreso si está procesando
            if (_isProcessing) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            
            // Botón de generar
            ElevatedButton(
              onPressed: _userImage != null && _garmentImage != null && !_isProcessing
                  ? _processTryon
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Procesando...', style: TextStyle(color: Colors.white)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Generar Prueba Virtual',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
            
            SizedBox(height: 30),
            
            // Resultado
            if (_resultImageUrl != null) _buildResultCard(),
            
            SizedBox(height: 20),
            
            // Información adicional
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String title, File? image, VoidCallback onTap, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 50, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'Toca para seleccionar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '¡Resultado Listo!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _resultImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.red[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 50),
                            SizedBox(height: 10),
                            Text('Error cargando imagen'),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar compartir
                        _showSuccess('Función de compartir próximamente');
                      },
                      icon: Icon(Icons.share),
                      label: Text('Compartir'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar guardar
                        _showSuccess('Función de guardar próximamente');
                      },
                      icon: Icon(Icons.download),
                      label: Text('Guardar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Consejos para mejores resultados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildTip('📸', 'Usa fotos con buena iluminación y fondo claro'),
            _buildTip('👤', 'La persona debe estar de frente en la foto'),
            _buildTip('👕', 'Las prendas deben estar extendidas y completas'),
            _buildTip('📏', 'Mejor calidad con imágenes de alta resolución'),
            _buildTip('⏱️', 'El procesamiento puede tomar 1-3 minutos'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }
}