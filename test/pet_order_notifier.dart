import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_order_model.dart';
import 'pet_order_usecase.dart';

class PetOrderNotifier extends AsyncNotifier<PetOrderModel>{
  @override
  FutureOr<PetOrderModel> build() {
    return PetOrderModel(
      id: 0, 
      petId: 0, 
      quantity: 0, 
      shipDate: DateTime.now(), 
      status: 'pending', 
      complete: false,
    );
  }
  Future<PetOrderModel?> getPetOrder({required PetOrderModel order}) async {

  state = const AsyncValue.loading();
  final usecase = ref.read(petOrderUseCaseProvider);
  
 
  state = await AsyncValue.guard(() => usecase.getPetOrder(order));

  if (state.hasError) {
    return null; 
  }


  return state.value; 
}}
final petOrderNotifierProvider=AsyncNotifierProvider<PetOrderNotifier, PetOrderModel>(()=>PetOrderNotifier());

// class PetOrderNotifier extends AsyncNotifier<PetOrderModel>{
//   @override
//  Future<PetOrderModel> build() async {
//    return PetOrderModel(
//       id: 0, 
//       petId: 0, 
//       quantity: 0, 
//       shipDate: DateTime.now(), 
//       status: 'pending', 
//       complete: false,
//     );
//   }
//   Future<String?> getPetOrder(PetOrderModel order)async {
//     state=const AsyncValue.loading();
//     final  usecase=ref.read(petOrderUseCaseProvider);
//      state = await AsyncValue.guard(() => usecase.getPetOrder(order));
//     if(state.hasError){
//       return state.error.toString();
//     }
//     return null;
//   }
// }