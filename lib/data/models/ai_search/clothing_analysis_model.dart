class ClothingAnalysisModel {
  final String tipo;
  final List<String> colores;
  final String estilo;
  final String material;
  final String patron;

  ClothingAnalysisModel({
    required this.tipo,
    required this.colores,
    required this.estilo,
    required this.material,
    required this.patron,
  });

  factory ClothingAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ClothingAnalysisModel(
      tipo: json['tipo'] ?? '',
      colores: List<String>.from(json['colores'] ?? []),
      estilo: json['estilo'] ?? '',
      material: json['material'] ?? '',
      patron: json['patron'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'colores': colores,
      'estilo': estilo,
      'material': material,
      'patron': patron,
    };
  }

  ClothingAnalysisModel copyWith({
    String? tipo,
    List<String>? colores,
    String? estilo,
    String? material,
    String? patron,
  }) {
    return ClothingAnalysisModel(
      tipo: tipo ?? this.tipo,
      colores: colores ?? this.colores,
      estilo: estilo ?? this.estilo,
      material: material ?? this.material,
      patron: patron ?? this.patron,
    );
  }

  @override
  String toString() {
    return 'ClothingAnalysisModel(tipo: $tipo, colores: $colores, estilo: $estilo, material: $material, patron: $patron)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothingAnalysisModel &&
        other.tipo == tipo &&
        other.colores.toString() == colores.toString() &&
        other.estilo == estilo &&
        other.material == material &&
        other.patron == patron;
  }

  @override
  int get hashCode {
    return tipo.hashCode ^
        colores.hashCode ^
        estilo.hashCode ^
        material.hashCode ^
        patron.hashCode;
  }

  /// Obtiene una descripción legible del análisis
  String get description {
    return '$tipo de color ${colores.join(", ")} con estilo $estilo, material $material y patrón $patron';
  }

  /// Obtiene el color principal (primer color en la lista)
  String get primaryColor {
    return colores.isNotEmpty ? colores.first : 'desconocido';
  }

  /// Verifica si tiene múltiples colores
  bool get hasMultipleColors {
    return colores.length > 1;
  }
}