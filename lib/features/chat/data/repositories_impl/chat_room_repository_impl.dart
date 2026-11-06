import 'package:dart_either/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../../data/datasources/firestore_chatroom_datasource.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_room_repository.dart';

class ChatRoomRepositoryImpl implements ChatRoomRepository {
  final FirestoreChatRoomDataSource _dataSource;
  final FirebaseAuth _auth;

  ChatRoomRepositoryImpl({
    required FirestoreChatRoomDataSource dataSource,
    FirebaseAuth? auth,
  })  : _dataSource = dataSource,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<Either<AppFailure, List<MessageEntity>>> getMessagesStream(
    String chatRoomId,
  ) {
    return _dataSource.getMessagesStream(chatRoomId).map((models) {
      final entities = models.map((model) => model.toEntity()).toList();

      return Right<AppFailure, List<MessageEntity>>(entities);
    }).handleError((error) {
      return Left<AppFailure, List<MessageEntity>>(
        ServerFailure(error.toString()),
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String messageText,
    String? replyToMessageId,
    String? replyToSenderId,
    String? replyToMessage,
    String? replyToImageUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null || currentUserId.isEmpty) {
        return const Left(
          UserFetchFailure('No authenticated user found.'),
        );
      }

      final messageModel = MessageModel(
        id: '',
        senderId: currentUserId,
        receiverId: receiverId,
        message: messageText,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        replyToSenderId: replyToSenderId,
        replyToMessage: replyToMessage,
        replyToImageUrl: replyToImageUrl,
      );

      await _dataSource.sendMessage(chatRoomId, messageModel);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> sendImageMessage({
    required String chatRoomId,
    required String receiverId,
    required String imagePath,
    String caption = '',
    String? replyToMessageId,
    String? replyToSenderId,
    String? replyToMessage,
    String? replyToImageUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null || currentUserId.isEmpty) {
        return const Left(
          UserFetchFailure('No authenticated user found.'),
        );
      }

      final messageModel = MessageModel(
        id: '',
        senderId: currentUserId,
        receiverId: receiverId,
        message: caption,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        replyToSenderId: replyToSenderId,
        replyToMessage: replyToMessage,
        replyToImageUrl: replyToImageUrl,
      );

      await _dataSource.sendImageMessage(
        chatRoomId,
        messageModel,
        imagePath,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, void>> markMessagesAsRead(
    String chatRoomId,
    String currentUserId,
  ) async {
    try {
      await _dataSource.markMessagesAsRead(
        chatRoomId,
        currentUserId,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}