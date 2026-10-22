import 'pet_order_model.dart';

abstract class PetRepository{
  Future<PetOrderModel> getPetById(PetOrderModel petOrderModel);
}