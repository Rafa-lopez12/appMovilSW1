// lib/data/models/auth/cliente_model.dart
class ClienteModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final bool isActive;
  final String tenantId;

  ClienteModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
    required this.isActive,
    required this.tenantId,
  });

  String get fullName => '$firstName $lastName';

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['telefono'],
      address: json['direccion'],
      isActive: json['isActive'] ?? true,
      tenantId: json['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'telefono': phone,
      'direccion': address,
      'isActive': isActive,
      'tenantId': tenantId,
    };
  }

  ClienteModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    bool? isActive,
    String? tenantId,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}

// lib/data/models/auth/login_request_model.dart
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// lib/data/models/auth/register_request_model.dart
class RegisterRequestModel {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? telefono;
  final String? direccion;

  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.telefono,
    this.direccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
    };
  }
}

// lib/data/models/auth/auth_response_model.dart
class AuthResponseModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? telefono;
  final String? direccion;
  final bool isActive;
  final String tenantId;
  final String token;

  AuthResponseModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.telefono,
    this.direccion,
    required this.isActive,
    required this.tenantId,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      telefono: json['telefono'],
      direccion: json['direccion'],
      isActive: json['isActive'] ?? true,
      tenantId: json['tenantId'] ?? '',
      token: json['token'] ?? '',
    );
  }

  ClienteModel toClienteModel() {
    return ClienteModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: telefono,
      address: direccion,
      isActive: isActive,
      tenantId: tenantId,
    );
  }
}