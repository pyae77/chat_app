import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_order_model.dart';
import 'pet_repository.dart';
import 'pet_repository_impl.dart';

class PetOrderUseCase {
  final PetRepository petRepository;

  PetOrderUseCase({required this.petRepository});

  Future<PetOrderModel> getPetOrder(PetOrderModel petOrderModel) async {
    return await petRepository.getPetById(petOrderModel);
  }
}
final petOrderUseCaseProvider = Provider<PetOrderUseCase>((ref) {
  final petRepository = ref.watch(petRepositoryProvider);
  return PetOrderUseCase(petRepository: petRepository);
});
