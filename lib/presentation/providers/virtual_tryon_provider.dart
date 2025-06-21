import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../core/services/virtual_tryon_service.dart';
import '../../data/models/virtual_tryon/virtual_tryon_session_model.dart';

class VirtualTryonProvider extends ChangeNotifier {
  final VirtualTryonService _tryonService = VirtualTryonService();

  List<VirtualTryonSessionModel> _sessions = [];
  VirtualTryonSessionModel? _currentSession;
  
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isCreatingSession = false;
  bool _isPollingStatus = false;
  String? _errorMessage;
  
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  
  bool _isPollingActive = false;
  
  Map<String, VirtualTryonSessionModel> _sessionCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  List<VirtualTryonSessionModel> get sessions => _sessions;
  VirtualTryonSessionModel? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isCreatingSession => _isCreatingSession;
  bool get isPollingStatus => _isPollingStatus;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  String get uploadStatus => _uploadStatus;
  bool get isPollingActive => _isPollingActive;

  int get totalSessions => _sessions.length;
  bool get hasSessions => _sessions.isNotEmpty;
  List<VirtualTryonSessionModel> get completedSessions => 
      _sessions.where((s) => s.status == 'completed').toList();
  List<VirtualTryonSessionModel> get processingSessions => 
      _sessions.where((s) => s.status == 'processing' || s.status == 'pending').toList();
  List<VirtualTryonSessionModel> get failedSessions => 
      _sessions.where((s) => s.status == 'failed').toList();
  int get completedCount => completedSessions.length;
  int get processingCount => processingSessions.length;
  int get failedCount => failedSessions.length;

  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  Future<VirtualTryonSessionModel?> createTryonWithUserImage({
    required File userImage,
    required String garmentImageUrl,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadStatus('Preparando imágenes...');

    try {
      _updateUploadProgress(0.2);
      _updateUploadStatus('Convirtiendo imagen del usuario...');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateUploadProgress(0.4);
      _updateUploadStatus('Enviando a servidor...');

      final session = await _tryonService.createTryonWithUserImage(
        userImage: userImage,
        garmentImageUrl: garmentImageUrl,
        productoId: productoId,
        metadata: metadata,
      );

      _updateUploadProgress(0.8);
      _updateUploadStatus('Try-on creado exitosamente');
      
      if (session != null) {
        _currentSession = session;
        _addSessionToCache(session);
        
        if (session.status == 'processing' || session.status == 'pending') {
          _startPolling(session.id);
        }
        
        _updateUploadProgress(1.0);
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
      _updateUploadProgress(0.0);
    }
  }

  Future<VirtualTryonSessionModel?> createTryonFromUrls({
    required String userImageUrl,
    required String garmentImageUrl,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadStatus('Iniciando try-on desde URLs...');

    try {
      final session = await _tryonService.createTryonFromUrls(
        userImageUrl: userImageUrl,
        garmentImageUrl: garmentImageUrl,
        productoId: productoId,
        metadata: metadata,
      );

      _currentSession = session;
      if (session != null) {
        _addSessionToCache(session);
        _updateUploadStatus('Try-on creado exitosamente');
        
        if (session.status == 'processing' || session.status == 'pending') {
          _startPolling(session.id);
        }
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
    }
  }

  Future<VirtualTryonSessionModel?> createTryonFromBase64({
    required String userImageBase64,
    required String garmentImageBase64,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadStatus('Procesando imágenes base64...');

    try {
      final session = await _tryonService.createTryonFromBase64(
        userImageBase64: userImageBase64,
        garmentImageBase64: garmentImageBase64,
        productoId: productoId,
        metadata: metadata,
      );

      _currentSession = session;
      if (session != null) {
        _addSessionToCache(session);
        _updateUploadStatus('Try-on creado exitosamente');
        
        if (session.status == 'processing' || session.status == 'pending') {
          _startPolling(session.id);
        }
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
    }
  }

  Future<VirtualTryonSessionModel?> uploadAndCreateTryon({
    required File userImage,
    required File garmentImage,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadProgress(0.0);
    _updateUploadStatus('Subiendo imágenes...');

    try {
      for (int i = 1; i <= 5; i++) {
        _updateUploadProgress(i * 0.15);
        _updateUploadStatus('Subiendo imágenes... ${(i * 15).toInt()}%');
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final session = await _tryonService.uploadAndCreateTryon(
        userImage: userImage,
        garmentImage: garmentImage,
        productoId: productoId,
        metadata: metadata,
      );

      _updateUploadProgress(1.0);
      _updateUploadStatus('Try-on creado exitosamente');
      
      _currentSession = session;
      if (session != null) {
        _addSessionToCache(session);
        
        if (session.status == 'processing' || session.status == 'pending') {
          _startPolling(session.id);
        }
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
      _updateUploadProgress(0.0);
    }
  }

  Future<VirtualTryonSessionModel?> createTryonSmart({
    File? userImage,
    String? userImageUrl,
    File? garmentImage,
    String? garmentImageUrl,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    if ((userImage == null && userImageUrl == null) ||
        (garmentImage == null && garmentImageUrl == null)) {
      _handleError('Se requiere al menos una imagen o URL para usuario y prenda');
      return null;
    }

    if (userImage != null && garmentImageUrl != null) {
      return await createTryonWithUserImage(
        userImage: userImage,
        garmentImageUrl: garmentImageUrl,
        productoId: productoId,
        metadata: metadata,
      );
    }

    if (userImageUrl != null && garmentImageUrl != null) {
      return await createTryonFromUrls(
        userImageUrl: userImageUrl,
        garmentImageUrl: garmentImageUrl,
        productoId: productoId,
        metadata: metadata,
      );
    }

    if (userImage != null && garmentImage != null) {
      return await uploadAndCreateTryon(
        userImage: userImage,
        garmentImage: garmentImage,
        productoId: productoId,
        metadata: metadata,
      );
    }

    _handleError('Combinación de parámetros no soportada');
    return null;
  }

  Future<Map<String, dynamic>?> verifyReplicateAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _tryonService.verifyReplicateAccount();
      return result;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<VirtualTryonSessionModel?> getSessionStatus(String sessionId) async {
    _setPollingStatus(true);
    _clearError();

    try {
      if (_sessionCache.containsKey(sessionId) && _isCacheValid) {
        final cachedSession = _sessionCache[sessionId]!;
        if (cachedSession.status == 'completed' || cachedSession.status == 'failed') {
          _setPollingStatus(false);
          return cachedSession;
        }
      }

      final session = await _tryonService.getSessionStatus(sessionId);
      
      if (session != null) {
        _addSessionToCache(session);
        
        if (_currentSession?.id == sessionId) {
          _currentSession = session;
        }
        
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index != -1) {
          _sessions[index] = session;
        }
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setPollingStatus(false);
    }
  }

  Future<void> loadSessionHistory({bool refresh = false}) async {
    if (_sessions.isNotEmpty && !refresh && _isCacheValid) return;

    _setLoadingHistory(true);
    _clearError();

    try {
      final sessions = await _tryonService.getMySessions();
      _sessions = sessions;
      
      for (final session in sessions) {
        _addSessionToCache(session);
      }
      
      _lastCacheUpdate = DateTime.now();
    } catch (error) {
      _handleError(error);
    } finally {
      _setLoadingHistory(false);
    }
  }

  Future<VirtualTryonSessionModel?> retrySession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final session = await _tryonService.retrySession(sessionId);
      
      if (session != null) {
        _addSessionToCache(session);
        
        if (_currentSession?.id == sessionId) {
          _currentSession = session;
        }
        
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index != -1) {
          _sessions[index] = session;
        }
        
        if (session.status == 'processing' || session.status == 'pending') {
          _startPolling(session.id);
        }
      }

      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _startPolling(String sessionId) {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    notifyListeners();
    
    _pollSessionStatus(sessionId);
  }

  Future<void> _pollSessionStatus(String sessionId) async {
    int attempts = 0;
    const maxAttempts = 60;
    const pollInterval = Duration(seconds: 5);

    while (attempts < maxAttempts && _isPollingActive) {
      try {
        final session = await getSessionStatus(sessionId);
        
        if (session != null) {
          if (session.status == 'completed' || session.status == 'failed') {
            _stopPolling();
            _updateUploadStatus(
              session.status == 'completed' 
                ? 'Try-on completado exitosamente' 
                : 'Try-on falló: ${session.errorMessage ?? 'Error desconocido'}'
            );
            break;
          }
        }

        await Future.delayed(pollInterval);
        attempts++;
      } catch (error) {
        attempts++;
        await Future.delayed(pollInterval);
      }
    }

    if (attempts >= maxAttempts) {
      _stopPolling();
      _updateUploadStatus('Timeout: El procesamiento tomó demasiado tiempo');
    }
  }

  void _stopPolling() {
    _isPollingActive = false;
    notifyListeners();
  }

  void setCurrentSession(VirtualTryonSessionModel session) {
    _currentSession = session;
    notifyListeners();
  }

  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  VirtualTryonSessionModel? getSessionById(String sessionId) {
    if (_sessionCache.containsKey(sessionId)) {
      return _sessionCache[sessionId];
    }
    
    try {
      return _sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  void removeSessionFromHistory(String sessionId) {
    _sessions.removeWhere((session) => session.id == sessionId);
    _sessionCache.remove(sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
    
    notifyListeners();
  }

  void clearHistory() {
    _sessions.clear();
    _sessionCache.clear();
    _currentSession = null;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await loadSessionHistory(refresh: true);
  }

  Future<void> initialize() async {
    await loadSessionHistory();
  }

  void reset() {
    _stopPolling();
    _sessions.clear();
    _currentSession = null;
    _sessionCache.clear();
    _clearError();
    _isLoading = false;
    _isLoadingHistory = false;
    _isCreatingSession = false;
    _isPollingStatus = false;
    _uploadProgress = 0.0;
    _uploadStatus = '';
    _lastCacheUpdate = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingHistory(bool loading) {
    _isLoadingHistory = loading;
    notifyListeners();
  }

  void _setCreatingSession(bool creating) {
    _isCreatingSession = creating;
    notifyListeners();
  }

  void _setPollingStatus(bool polling) {
    _isPollingStatus = polling;
    notifyListeners();
  }

  void _updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _updateUploadStatus(String status) {
    _uploadStatus = status;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _addSessionToCache(VirtualTryonSessionModel session) {
    _sessionCache[session.id] = session;
    _lastCacheUpdate = DateTime.now();
  }

  @override
  void dispose() {
    _stopPolling();
    _sessionCache.clear();
    super.dispose();
  }
}