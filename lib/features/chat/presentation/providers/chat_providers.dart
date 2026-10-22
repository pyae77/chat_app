import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:flutter_chat_app/features/chat/data/repositories_impl/chat_repository_impl.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/get_chat_users_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestoreChatDataSourceProvider = Provider<FirestoreChatDataSource>((ref) {
  return FirestoreChatDataSourceImpl();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(firestoreChatDataSourceProvider);
  return ChatRepositoryImpl(datasource: dataSource);
});

final getChatUsersUseCaseProvider = Provider<GetChatUsersUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatUsersUseCase(repository);
});

final chatUsersStreamProvider = StreamProvider<Either<AppFailure, List<ChatUserEntity>>>((ref) {
  final useCase = ref.watch(getChatUsersUseCaseProvider);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  if (currentUserId.isEmpty) {
    return Stream.value(const Left(UserFetchFailure('No authenticated user found.')));
  }

  return useCase.execute(currentUserId);
});