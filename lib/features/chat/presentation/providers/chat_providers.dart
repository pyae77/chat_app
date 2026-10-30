import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chat_app/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:flutter_chat_app/features/chat/data/repositories_impl/chat_repository_impl.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/get_chat_users_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final firestoreChatDataSourceProvider = Provider<FirestoreChatDataSource>((
  ref,
) {
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

class ChatUsersState {
  final List<ChatUserEntity> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final String? errorMessage;

  const ChatUsersState({
    this.users = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastDocument,
    this.errorMessage,
  });

  ChatUsersState copyWith({
    List<ChatUserEntity>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    String? errorMessage,
  }) {
    return ChatUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage,
    );
  }
}

class ChatUsersNotifier extends StateNotifier<ChatUsersState> {
  final GetChatUsersUseCase _getChatUsersUseCase;
  final String _currentUserId;

  ChatUsersNotifier(this._getChatUsersUseCase, this._currentUserId)
    : super(const ChatUsersState()) {
    if (_currentUserId.isEmpty) {
      state = state.copyWith(isLoading: false, hasMore: false);
    } else {
      fetchInitialChats();
    }
  }

  static const int _limit = 10;

  Future<void> fetchInitialChats() async {
    if (_currentUserId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getChatUsersUseCase.execute(
      currentUserId: _currentUserId,
      limit: _limit,
    );
    if (!mounted) return;

    result.fold(
      ifLeft: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      ifRight: (page) {
        state = state.copyWith(
          isLoading: false,
          users: page.items,
          lastDocument: page.cursor,
          hasMore: page.hasMore,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        _currentUserId.isEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    final result = await _getChatUsersUseCase.execute(
      currentUserId: _currentUserId,
      lastDocument: state.lastDocument,
      limit: _limit,
    );
    if (!mounted) return;

    result.fold(
      ifLeft: (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      ifRight: (page) {
        state = state.copyWith(
          isLoadingMore: false,
          users: [...state.users, ...page.items],
          lastDocument: page.cursor,
          hasMore: page.hasMore,
        );
      },
    );
  }
}

final chatUsersProvider =
    StateNotifierProvider.autoDispose<ChatUsersNotifier, ChatUsersState>((ref) {
      final currentUserId = ref.watch(currentUserIdProvider) ?? '';
      return ChatUsersNotifier(
        ref.watch(getChatUsersUseCaseProvider),
        currentUserId,
      );
    });
