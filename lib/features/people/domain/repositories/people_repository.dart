import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

abstract class PeopleRepository {
  Future<Either<AppFailure, List<ChatUserEntity>>> getPeople({
    required String currentUserId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  });
}