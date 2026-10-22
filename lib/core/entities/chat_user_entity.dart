class ChatUserEntity {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isOnline;

  const ChatUserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
  });
}