class PetOrderEntity {
  final int id;
  final int petId;
  final int quantity;
  final DateTime shipDate;
  final String status;
  final bool complete;

  PetOrderEntity({required this.id, required this.petId, required this.quantity, required this.shipDate, required this.status, required this.complete});
}