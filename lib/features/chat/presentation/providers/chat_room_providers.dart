
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/get_typing_status_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/update_typing_status_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:flutter_chat_app/core/failures/app_failure.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_room_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/mark_message_as_read_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/message_usecases.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_image_message_usecase.dart';

import '../../data/datasources/firestore_chatroom_datasource.dart';
import '../../data/repositories_impl/chat_room_repository_impl.dart';

// 1. Data Source Provider
final chatRoomDataSourceProvider =
    Provider<FirestoreChatRoomDataSource>((ref) {
  return FirestoreChatRoomDataSourceImpl();
});

// 2. Repository Provider
final chatRoomRepositoryProvider =
    Provider<ChatRoomRepository>((ref) {
  final dataSource = ref.watch(chatRoomDataSourceProvider);

  return ChatRoomRepositoryImpl(
    dataSource: dataSource,
  );
});

// 3. UseCase Providers
final getMessagesUseCaseProvider =
    Provider<GetMessagesUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);

  return GetMessagesUseCase(repository);
});

final sendMessageUseCaseProvider =
    Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);

  return SendMessageUseCase(repository);
});

final sendImageMessageUseCaseProvider =
    Provider<SendImageMessageUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);

  return SendImageMessageUseCase(repository);
});

final markMessagesAsReadUseCaseProvider =
    Provider<MarkMessagesAsReadUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);

  return MarkMessagesAsReadUseCase(repository);
});

// 4. Real-time Message Stream Provider
final messagesStreamProvider =
    StreamProvider.family<
        Either<AppFailure, List<MessageEntity>>,
        String>((ref, chatRoomId) {
  final useCase = ref.watch(getMessagesUseCaseProvider);

  return useCase.execute(chatRoomId);
});

// 5. Message Text Controller
final chatMessageControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

// 6. Selected Image Provider
final selectedImagePathProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// 7. Selected Message Provider
final selectedMessageIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// 8. Selected Reply Message Provider
final selectedReplyMessageProvider =
    StateProvider.autoDispose<MessageEntity?>((ref) => null);
   
// 9. Image Bytes Cache Provider
final messageImageBytesProvider =
    Provider.autoDispose.family<Uint8List?, String>((ref, imageData) {
  try {
    return base64Decode(imageData);
  } catch (e) {
    debugPrint('Image decode error: $e');
    return null;
  }
});

final updateTypingStatusUseCaseProvider =
    Provider<UpdateTypingStatusUseCase>((ref) {
  return UpdateTypingStatusUseCase(
    ref.watch(chatRoomRepositoryProvider),
  );
});

final getTypingStatusUseCaseProvider =
    Provider<GetTypingStatusUseCase>((ref) {
  return GetTypingStatusUseCase(
    ref.watch(chatRoomRepositoryProvider),
  );
});

final typingStatusStreamProvider = StreamProvider.family<
    Either<AppFailure, bool>,
    (String, String)>((ref, params) {
  final useCase = ref.watch(getTypingStatusUseCaseProvider);

  return useCase(
    chatRoomId: params.$1,
    userId: params.$2,
  );
});