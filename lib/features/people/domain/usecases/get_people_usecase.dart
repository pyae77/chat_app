import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../repositories/people_repository.dart';

class GetPeopleUseCase {
  final PeopleRepository _repository;

  GetPeopleUseCase(this._repository);

  Future<Either<AppFailure, List<ChatUserEntity>>> execute({
    required String currentUserId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) {
    return _repository.getPeople(
      currentUserId: currentUserId,
      lastDocument: lastDocument,
      limit: limit,
    );
  }
}