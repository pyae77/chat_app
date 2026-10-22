import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';
import 'pet_order_model.dart';

abstract class PetRemoteDataSource{
  Future<PetOrderModel> getPetById(PetOrderModel petOrderModel);
}
class PetRemoteDataSourceImpl implements PetRemoteDataSource{
  final Dio dio;

  PetRemoteDataSourceImpl({required this.dio});
  @override
  Future<PetOrderModel> getPetById(PetOrderModel petOrderModel) async{
    final response=await dio.post('/store/order',data: petOrderModel.toJson());
   if(response.statusCode==200){
    return PetOrderModel.fromJson(response.data);
  }else{
    throw Exception('Failed to load pet order');
  }
  }

}
final PetRemoteDataSourceProvider=Provider<PetRemoteDataSource>(
  (ref){
    final dio=ref.watch(dioProvider);
    return PetRemoteDataSourceImpl(dio: dio);
  }
);