import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_order_model.dart';
import 'pet_remote_data_source.dart';
import 'pet_repository.dart';

class PetRepositoryImpl implements PetRepository{
  final PetRemoteDataSource petRemoteDataSource;
  PetRepositoryImpl({required this.petRemoteDataSource});
  @override
  Future<PetOrderModel> getPetById(PetOrderModel petOrderModel) {
    return petRemoteDataSource.getPetById(petOrderModel);
  }
  

  } 
  final petRepositoryProvider=Provider<PetRepository>((ref){
    final petRemoteDataSource=ref.watch(PetRemoteDataSourceProvider);
    return PetRepositoryImpl(petRemoteDataSource: petRemoteDataSource);
  });