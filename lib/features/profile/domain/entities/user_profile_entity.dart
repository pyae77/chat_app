class UserProfileEntity {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String? photoBase64;
  final bool isOnline;
  final DateTime? lastSeen;

  const UserProfileEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    this.photoBase64,
    required this.isOnline,
    this.lastSeen,
  });

  UserProfileEntity copyWith({
    String? name,
    String? bio,
    String? photoBase64,
    bool? isOnline,
  }) {
    return UserProfileEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      bio: bio ?? this.bio,
      photoBase64: photoBase64 ?? this.photoBase64,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen,
    );
  }
}