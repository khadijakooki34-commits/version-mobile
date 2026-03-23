class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String phoneNumber;
  final String role; // USER or ADMIN
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.phoneNumber,
    required this.role,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for backend response (uses 'nom' field)
  factory User.fromBackendJson(Map<String, dynamic> json) {
    final nom = json['nom'] ?? '';
    final nameParts = nom.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    // Handle date parsing for backend format (LocalDateTime -> ISO string)
    DateTime? parseBackendDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    return User(
      id: (json['id'] is int) ? json['id'] : (json['id']?.toInt() ?? 0),
      email: json['email'] ?? '',
      firstName: firstName,
      lastName: lastName,
      profileImage: json['photoUrl'] ?? json['profileImage'],
      phoneNumber: json['telephone'] ?? json['phoneNumber'] ?? '',
      role: (json['role'] ?? 'USER').toString().toUpperCase(),
      isBlocked: json['compteBloquer'] ?? json['isBlocked'] ?? false,
      createdAt: parseBackendDate(json['dateInscription']) ?? 
                 parseBackendDate(json['createdAt']) ?? 
                 DateTime.now(),
      updatedAt: parseBackendDate(json['dateModification']) ?? 
                 parseBackendDate(json['updatedAt']) ?? 
                 DateTime.now(),
    );
  }

  // Factory constructor for standard JSON (uses firstName/lastName or falls back to backend format)
  factory User.fromJson(Map<String, dynamic> json) {
    // If 'nom' exists, use backend format; otherwise use standard format
    if (json['nom'] != null) {
      return User.fromBackendJson(json);
    }
    
    return User(
      id: json['id'] ?? json['userId']?.toInt() ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'] ?? json['photoUrl'],
      phoneNumber: json['phoneNumber'] ?? json['telephone'] ?? '',
      role: json['role'] ?? 'USER',
      isBlocked: json['isBlocked'] ?? json['compteBloquer'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['dateInscription'] != null 
              ? DateTime.parse(json['dateInscription']) 
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : (json['dateModification'] != null
              ? DateTime.parse(json['dateModification'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'role': role,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'ADMIN';
}

class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;
  final String message;
  final bool requiresTwoFactor;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
    required this.message,
    this.requiresTwoFactor = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns accessToken, not token
    final token = json['accessToken'] ?? json['token'] ?? '';
    final refreshToken = json['refreshToken'];
    final requiresTwoFactor = json['requiresTwoFactor'] ?? false;
    
    // Backend returns user fields directly in AuthResponse (userId, email, nom, role)
    // not nested in 'user' object. Create User from the response fields.
    User user;
    if (json['user'] != null) {
      // If user object exists, use it
      final userJson = json['user'] as Map<String, dynamic>;
      user = userJson['nom'] != null 
          ? User.fromBackendJson(userJson)
          : User.fromJson(userJson);
    } else {
      // Backend returns user fields at top level
      final userJson = {
        'id': json['userId'],
        'email': json['email'] ?? '',
        'nom': json['nom'] ?? '',
        'role': json['role'] ?? 'USER',
        'telephone': json['telephone'] ?? '',
        'photoUrl': json['photoUrl'],
        'compteBloquer': json['compteBloquer'] ?? false,
        'dateInscription': json['dateInscription'],
      };
      user = User.fromBackendJson(userJson);
    }
    
    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
      user: user,
      message: json['message'] ?? 'Success',
      requiresTwoFactor: requiresTwoFactor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'message': message,
      'requiresTwoFactor': requiresTwoFactor,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'motDePasse': password,  // Backend expects 'motDePasse'
    };
  }
}

class RegisterRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;

  RegisterRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nom': '$firstName $lastName',  // Backend expects 'nom' (full name)
      'motDePasse': password,          // Backend expects 'motDePasse'
      'telephone': phoneNumber,        // Backend expects 'telephone'
    };
  }
}
