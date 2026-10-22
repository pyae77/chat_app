import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../../domain/repositories/people_repository.dart';
import '../datasources/firestore_people_datasource.dart';

class PeopleRepositoryImpl implements PeopleRepository {
  final FirestorePeopleDataSource _dataSource;

  PeopleRepositoryImpl({required FirestorePeopleDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<AppFailure, List<ChatUserEntity>>> getPeople({
    required String currentUserId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      
      final models = await _dataSource.getPeople(
        currentUserId: currentUserId,
        lastDocument: lastDocument,
        limit: limit,
      );

    
      final entities = models.map((model) => model.toEntity()).toList();

    
      return Right(entities);
    } catch (e) {
      
      return Left(UserFetchFailure(e.toString()));
    }
  }
}