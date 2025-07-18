class User {
  final int id;
  final String username;
  final String userId;
  final String email;
  final String displayName;
  final String bio;
  final String? avatar;
  final bool isDiscoverable;
  final String fullDisplayName;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.bio,
    this.avatar,
    required this.isDiscoverable,
    required this.fullDisplayName,
    required this.dateJoined,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatar: json['avatar'] as String?,
      isDiscoverable: json['is_discoverable'] as bool? ?? true,
      fullDisplayName: json['full_display_name'] as String,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'bio': bio,
      'avatar': avatar,
      'is_discoverable': isDiscoverable,
      'full_display_name': fullDisplayName,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? userId,
    String? email,
    String? displayName,
    String? bio,
    String? avatar,
    bool? isDiscoverable,
    String? fullDisplayName,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      isDiscoverable: isDiscoverable ?? this.isDiscoverable,
      fullDisplayName: fullDisplayName ?? this.fullDisplayName,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, userId: $userId, fullDisplayName: $fullDisplayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
