import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/firestore_people_datasource.dart';
import '../../data/repositories_impl/people_repository_impl.dart';
import '../../domain/repositories/people_repository.dart';
import '../../domain/usecases/get_people_usecase.dart';

// 1. Providers Setup
final firestorePeopleDataSourceProvider = Provider<FirestorePeopleDataSource>((
  ref,
) {
  return FirestorePeopleDataSourceImpl();
});

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  final dataSource = ref.watch(firestorePeopleDataSourceProvider);
  return PeopleRepositoryImpl(dataSource: dataSource);
});

final getPeopleUseCaseProvider = Provider<GetPeopleUseCase>((ref) {
  final repository = ref.watch(peopleRepositoryProvider);
  return GetPeopleUseCase(repository);
});

final userPresenceStreamProvider = StreamProvider.autoDispose
    .family<ChatUserEntity?, String>((ref, userId) {
      return ref.watch(getPeopleUseCaseProvider).getUserPresenceStream(userId);
    });

// Search Query Provider for People
final peopleSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

// 2. Pagination State Class
class PeopleState {
  final List<ChatUserEntity> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final String? errorMessage;

  PeopleState({
    this.users = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastDocument,
    this.errorMessage,
  });

  PeopleState copyWith({
    List<ChatUserEntity>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    String? errorMessage,
  }) {
    return PeopleState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      errorMessage: errorMessage,
    );
  }
}

// 3. StateNotifier for Pagination Logic
class PeopleNotifier extends StateNotifier<PeopleState> {
  final GetPeopleUseCase _getPeopleUseCase;
  final String _currentUserId;
  final bool _onlineOnly;

  PeopleNotifier(
    this._getPeopleUseCase, {
    required String currentUserId,
    required bool onlineOnly,
  }) : _currentUserId = currentUserId,
       _onlineOnly = onlineOnly,
       super(PeopleState()) {
    if (_currentUserId.isNotEmpty) {
      fetchInitialPeople();
    } else {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  static const int _limit = 10;

  Future<void> fetchInitialPeople() async {
    if (_currentUserId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getPeopleUseCase.execute(
      currentUserId: _currentUserId,
      limit: _limit,
      onlineOnly: _onlineOnly,
    );
    if (!mounted) return;

    result.fold(
      ifLeft: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      ifRight: (newUsers) {
        state = state.copyWith(
          isLoading: false,
          users: newUsers.items,
          lastDocument: newUsers.cursor,
          hasMore: newUsers.hasMore,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    final result = await _getPeopleUseCase.execute(
      currentUserId: _currentUserId,
      lastDocument: state.lastDocument,
      limit: _limit,
      onlineOnly: _onlineOnly,
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

// 4. StateNotifierProvider
final peopleProvider =
    StateNotifierProvider.autoDispose<PeopleNotifier, PeopleState>((ref) {
      final currentUserId = ref.watch(currentUserIdProvider) ?? '';
      final useCase = ref.watch(getPeopleUseCaseProvider);
      return PeopleNotifier(
        useCase,
        currentUserId: currentUserId,
        onlineOnly: false,
      );
    });

final onlineUsersProvider =
    StateNotifierProvider.autoDispose<PeopleNotifier, PeopleState>((ref) {
      final currentUserId = ref.watch(currentUserIdProvider) ?? '';
      final useCase = ref.watch(getPeopleUseCaseProvider);
      return PeopleNotifier(
        useCase,
        currentUserId: currentUserId,
        onlineOnly: true,
      );
    });
