import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/message_usecases.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_image_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/firestore_chatroom_datasource.dart';




import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../../data/repositories_impl/chat_room_repository_impl.dart';
import '../../domain/repositories/chat_room_repository.dart';

// 1. Data Source Provider
final chatRoomDataSourceProvider = Provider<FirestoreChatRoomDataSource>((ref) {
  return FirestoreChatRoomDataSourceImpl();
});

// 2. Repository Provider
final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  final dataSource = ref.watch(chatRoomDataSourceProvider);
  return ChatRoomRepositoryImpl(dataSource: dataSource);
});

// 3. UseCase Providers
final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);
  return GetMessagesUseCase(repository);
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);
  return SendMessageUseCase(repository);
});

// 4. Real-time Message Stream Provider (accessing chat romm ids with family provider)
final messagesStreamProvider = StreamProvider.family<Either<AppFailure, List<MessageEntity>>, String>((ref, chatRoomId) {
  final useCase = ref.watch(getMessagesUseCaseProvider);
  return useCase.execute(chatRoomId);
});

final chatMessageControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final sendImageMessageUseCaseProvider = Provider<SendImageMessageUseCase>((ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);
  return SendImageMessageUseCase(repository);
});


final selectedImagePathProvider = StateProvider.autoDispose<String?>((ref) => null);
