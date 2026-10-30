import 'package:flutter_chat_app/core/models/chat_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses photoBase64 from Firestore user documents', () {
    final model = ChatUserModel.fromFirestore(
      {
        'name': 'Ada',
        'email': 'ada@example.com',
        'photoBase64': 'abc123',
        'isOnline': true,
      },
      'uid-1',
    );

    expect(model.photoBase64, 'abc123');
    expect(model.toEntity().photoBase64, 'abc123');
    expect(model.hasPhotoBase64, isTrue);
  });

  test('falls back to profilePic when photoUrl is missing', () {
    final model = ChatUserModel.fromFirestore(
      {
        'name': 'Ada',
        'email': 'ada@example.com',
        'profilePic': 'https://example.com/ada.png',
        'photoBase64': '   ',
      },
      'uid-1',
    );

    expect(model.photoBase64, isNull);
    expect(model.photoUrl, 'https://example.com/ada.png');
  });
}
