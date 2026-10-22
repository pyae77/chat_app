import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/firestore_people_datasource.dart';
import '../../data/repositories_impl/people_repository_impl.dart';
import '../../domain/repositories/people_repository.dart';
import '../../domain/usecases/get_people_usecase.dart';

// 1. Providers Setup
final firestorePeopleDataSourceProvider = Provider<FirestorePeopleDataSource>((ref) {
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

// Search Query Provider for People
final peopleSearchQueryProvider = StateProvider<String>((ref) => '');

// 2. Pagination State Class
class PeopleState {
  final List<ChatUserEntity> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final String? errorMessage;

  PeopleState({
    this.users = const [],
    this.isLoading = false,
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
    DocumentSnapshot? lastDocument,
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
  
  PeopleNotifier(this._getPeopleUseCase) : super(PeopleState()) {
    fetchInitialPeople();
  }

  static const int _limit = 10;

  Future<void> fetchInitialPeople() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getPeopleUseCase.execute(
      currentUserId: currentUserId,
      limit: _limit,
    );

    result.fold(
      ifLeft: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      ifRight: (newUsers) {
       
        state = state.copyWith(
          isLoading: false,
          users: newUsers,
          hasMore: newUsers.length >= _limit,
        );
      },
    );
  }

  Future<void> loadMorePeople() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _getPeopleUseCase.execute(
      currentUserId: currentUserId,
      lastDocument: state.lastDocument,
      limit: _limit,
    );

    result.fold(
      ifLeft: (failure) {
        state = state.copyWith(isLoadingMore: false, errorMessage: failure.message);
      },
      ifRight: (newUsers) {
        state = state.copyWith(
          isLoadingMore: false,
          users: [...state.users, ...newUsers],
          hasMore: newUsers.length >= _limit,
        );
      },
    );
  }
}

// 4. StateNotifierProvider
final peopleProvider = StateNotifierProvider<PeopleNotifier, PeopleState>((ref) {
  final useCase = ref.watch(getPeopleUseCaseProvider);
  return PeopleNotifier(useCase);
});