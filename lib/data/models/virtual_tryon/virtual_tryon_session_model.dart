
import 'package:prueba/data/models/product/product_model.dart';

class VirtualTryonSessionModel {
  final String id;
  final String userImageUrl;
  final String garmentImageUrl;
  final String? resultImageUrl;
  final String? replicateId;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final String tenantId;
  final ProductModel? producto;
  final DateTime createdAt;
  final DateTime updatedAt;

  VirtualTryonSessionModel({
    required this.id,
    required this.userImageUrl,
    required this.garmentImageUrl,
    this.resultImageUrl,
    this.replicateId,
    required this.status,
    this.errorMessage,
    this.metadata,
    required this.tenantId,
    this.producto,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory VirtualTryonSessionModel.fromJson(Map<String, dynamic> json) {
    return VirtualTryonSessionModel(
      id: json['id'] as String,
      userImageUrl: json['userImageUrl'] as String,
      garmentImageUrl: json['garmentImageUrl'] as String,
      resultImageUrl: json['resultImageUrl'] as String?,
      replicateId: json['replicateId'] as String?,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tenantId: json['tenantId'] as String,
      producto: json['produto'] != null 
          ? ProductModel.fromJson(json['produto'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userImageUrl': userImageUrl,
      'garmentImageUrl': garmentImageUrl,
      'resultImageUrl': resultImageUrl,
      'replicateId': replicateId,
      'status': status,
      'errorMessage': errorMessage,
      'metadata': metadata,
      'tenantId': tenantId,
      'produto': producto?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  VirtualTryonSessionModel copyWith({
    String? id,
    String? userImageUrl,
    String? garmentImageUrl,
    String? resultImageUrl,
    String? replicateId,
    String? status,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    String? tenantId,
    ProductModel? producto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VirtualTryonSessionModel(
      id: id ?? this.id,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      garmentImageUrl: garmentImageUrl ?? this.garmentImageUrl,
      resultImageUrl: resultImageUrl ?? this.resultImageUrl,
      replicateId: replicateId ?? this.replicateId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      tenantId: tenantId ?? this.tenantId,
      producto: producto ?? this.producto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isInProgress => isPending || isProcessing;
  bool get hasResult => resultImageUrl != null && resultImageUrl!.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasProduct => producto != null;

  // Status helpers
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'processing':
        return 'Procesando';
      case 'completed':
        return 'Completado';
      case 'failed':
        return 'Falló';
      default:
        return 'Desconocido';
    }
  }

  String get statusDescription {
    switch (status) {
      case 'pending':
        return 'Tu try-on está en cola para procesarse';
      case 'processing':
        return 'Estamos procesando tu try-on virtual';
      case 'completed':
        return 'Tu try-on está listo';
      case 'failed':
        return hasError ? errorMessage! : 'Ocurrió un error durante el procesamiento';
      default:
        return 'Estado desconocido';
    }
  }

  // Duration helpers
  Duration get processingDuration {
    return updatedAt.difference(createdAt);
  }

  String get processingTimeFormatted {
    final duration = processingDuration;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Time ago helpers
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace unos segundos';
    }
  }

  // Validation helpers
  bool get isValid {
    return id.isNotEmpty &&
           userImageUrl.isNotEmpty &&
           garmentImageUrl.isNotEmpty &&
           tenantId.isNotEmpty &&
           _isValidStatus(status);
  }

  static bool _isValidStatus(String status) {
    return ['pending', 'processing', 'completed', 'failed'].contains(status);
  }

  // Equality and hashcode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VirtualTryonSessionModel &&
           other.id == id &&
           other.status == status &&
           other.resultImageUrl == resultImageUrl &&
           other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, status, resultImageUrl, updatedAt);
  }

  @override
  String toString() {
    return 'VirtualTryonSessionModel{id: $id, status: $status, hasResult: $hasResult, timeAgo: $timeAgo}';
  }
}

// lib/data/models/virtual_tryon/tryon_result_model.dart
class TryonResultModel {
  final String sessionId;
  final String resultImageUrl;
  final double confidence;
  final Map<String, dynamic>? processingMetadata;
  final Duration processingTime;
  final String processingVersion;

  TryonResultModel({
    required this.sessionId,
    required this.resultImageUrl,
    required this.confidence,
    this.processingMetadata,
    required this.processingTime,
    required this.processingVersion,
  });

  factory TryonResultModel.fromJson(Map<String, dynamic> json) {
    return TryonResultModel(
      sessionId: json['sessionId'] as String,
      resultImageUrl: json['resultImageUrl'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      processingMetadata: json['processingMetadata'] as Map<String, dynamic>?,
      processingTime: Duration(seconds: json['processingTimeSeconds'] as int),
      processingVersion: json['processingVersion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'resultImageUrl': resultImageUrl,
      'confidence': confidence,
      'processingMetadata': processingMetadata,
      'processingTimeSeconds': processingTime.inSeconds,
      'processingVersion': processingVersion,
    };
  }

  // Quality helpers
  String get qualityLevel {
    if (confidence >= 0.9) return 'Excelente';
    if (confidence >= 0.7) return 'Buena';
    if (confidence >= 0.5) return 'Regular';
    return 'Baja';
  }

  bool get isHighQuality => confidence >= 0.7;
}

// lib/data/models/virtual_tryon/tryon_status_model.dart
class TryonStatusModel {
  final String sessionId;
  final String status;
  final double? progress;
  final String? currentStep;
  final String? estimatedTimeRemaining;
  final List<String> completedSteps;
  final String? errorDetails;

  TryonStatusModel({
    required this.sessionId,
    required this.status,
    this.progress,
    this.currentStep,
    this.estimatedTimeRemaining,
    required this.completedSteps,
    this.errorDetails,
  });

  factory TryonStatusModel.fromJson(Map<String, dynamic> json) {
    return TryonStatusModel(
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      progress: json['progress'] as double?,
      currentStep: json['currentStep'] as String?,
      estimatedTimeRemaining: json['estimatedTimeRemaining'] as String?,
      completedSteps: (json['completedSteps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      errorDetails: json['errorDetails'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'status': status,
      'progress': progress,
      'currentStep': currentStep,
      'estimatedTimeRemaining': estimatedTimeRemaining,
      'completedSteps': completedSteps,
      'errorDetails': errorDetails,
    };
  }

  // Progress helpers
  double get progressPercentage => (progress ?? 0.0) * 100;
  
  String get progressText {
    if (progress != null) {
      return '${progressPercentage.toInt()}%';
    }
    return statusText;
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En cola';
      case 'processing':
        return currentStep ?? 'Procesando';
      case 'completed':
        return 'Completado';
      case 'failed':
        return 'Error';
      default:
        return 'Desconocido';
    }
  }

  bool get hasProgress => progress != null;
  bool get isComplete => status == 'completed';
  bool get hasFailed => status == 'failed';
  bool get isProcessing => status == 'processing';
}

// lib/data/models/virtual_tryon/create_tryon_request_model.dart
class CreateTryonRequestModel {
  final String? userImageUrl;
  final String? garmentImageUrl;
  final String? userImageBase64;
  final String? garmentImageBase64;
  final String? productoId;
  final Map<String, dynamic>? metadata;
  final TryonSettings? settings;

  CreateTryonRequestModel({
    this.userImageUrl,
    this.garmentImageUrl,
    this.userImageBase64,
    this.garmentImageBase64,
    this.productoId,
    this.metadata,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (userImageUrl != null) json['userImageUrl'] = userImageUrl;
    if (garmentImageUrl != null) json['garmentImageUrl'] = garmentImageUrl;
    if (userImageBase64 != null) json['userImageBase64'] = userImageBase64;
    if (garmentImageBase64 != null) json['garmentImageBase64'] = garmentImageBase64;
    if (productoId != null) json['productoId'] = productoId;
    if (metadata != null) json['metadata'] = metadata;
    if (settings != null) json['settings'] = settings!.toJson();
    
    return json;
  }

  // Validation
  bool get isValid {
    final hasUserImage = userImageUrl != null || userImageBase64 != null;
    final hasGarmentImage = garmentImageUrl != null || garmentImageBase64 != null;
    return hasUserImage && hasGarmentImage;
  }

  bool get isUrlRequest => userImageUrl != null && garmentImageUrl != null;
  bool get isBase64Request => userImageBase64 != null && garmentImageBase64 != null;
}

// lib/data/models/virtual_tryon/tryon_settings_model.dart
class TryonSettings {
  final String quality; // 'low', 'medium', 'high'
  final bool preserveBackground;
  final bool enhanceColors;
  final double fitAdjustment; // 0.0 to 1.0
  final String renderingMode; // 'fast', 'balanced', 'quality'

  TryonSettings({
    this.quality = 'medium',
    this.preserveBackground = true,
    this.enhanceColors = false,
    this.fitAdjustment = 0.5,
    this.renderingMode = 'balanced',
  });

  factory TryonSettings.fromJson(Map<String, dynamic> json) {
    return TryonSettings(
      quality: json['quality'] as String? ?? 'medium',
      preserveBackground: json['preserveBackground'] as bool? ?? true,
      enhanceColors: json['enhanceColors'] as bool? ?? false,
      fitAdjustment: (json['fitAdjustment'] as num?)?.toDouble() ?? 0.5,
      renderingMode: json['renderingMode'] as String? ?? 'balanced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'preserveBackground': preserveBackground,
      'enhanceColors': enhanceColors,
      'fitAdjustment': fitAdjustment,
      'renderingMode': renderingMode,
    };
  }

  // Preset configurations
  static TryonSettings get fast => TryonSettings(
    quality: 'low',
    renderingMode: 'fast',
    fitAdjustment: 0.3,
  );

  static TryonSettings get balanced => TryonSettings(
    quality: 'medium',
    renderingMode: 'balanced',
    fitAdjustment: 0.5,
  );

  static TryonSettings get highQuality => TryonSettings(
    quality: 'high',
    renderingMode: 'quality',
    preserveBackground: true,
    enhanceColors: true,
    fitAdjustment: 0.7,
  );
}