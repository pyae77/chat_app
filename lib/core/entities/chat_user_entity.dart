class ChatUserEntity {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? photoBase64;
  final bool isOnline;

  const ChatUserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.photoBase64,
    this.isOnline = false,
  });

  bool get hasPhotoBase64 =>
      photoBase64 != null && photoBase64!.trim().isNotEmpty;

  bool get hasPhotoUrl => photoUrl != null && photoUrl!.trim().isNotEmpty;
}
