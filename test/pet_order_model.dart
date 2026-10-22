import 'pet_order_entity.dart';

class PetOrderModel extends PetOrderEntity{
  PetOrderModel({required super.id, required super.petId, required super.quantity, required super.shipDate, required super.status, required super.complete});
  
  PetOrderModel.fromJson(Map<String,dynamic> json) : super(
    id: json['id'] as int, 
    petId: json['petId'] as int, 
    quantity: json['quantity'] as int, 
    shipDate: DateTime.parse(json['shipDate'] as String), 
    status: json['status'] as String, 
    complete: json['complete'] as bool){

  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'quantity': quantity,
    'shipDate': shipDate.toIso8601String(),
    'status': status,
    'complete': complete
  };
}