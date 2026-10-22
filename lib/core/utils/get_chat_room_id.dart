String getChatRoomId(String userId1, String userId2) {
  List<String> ids = [userId1, userId2];
  ids.sort(); // Alphabetical sorting sathi
  return '${ids[0]}_${ids[1]}';
}