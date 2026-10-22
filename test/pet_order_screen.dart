import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_order_model.dart';
import 'pet_order_notifier.dart';

// class PetOrderScreen extends ConsumerWidget{
//   final TextEditingController petIdController=TextEditingController();
//   final TextEditingController quantityController=TextEditingController();
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final petOrderState=ref.watch(petOrderNotifierProvider);

//     return Column(
//       children: [
//        TextField(
//         controller: petIdController,
//         decoration: const InputDecoration(
//           labelText: 'Pet ID',
//         ),
//        ),
//        TextField(
//         controller: quantityController,
//         decoration: const InputDecoration(
//           labelText: 'Quantity',
//         ),),
      
//         ElevatedButton(
//           child:  Text('Get Pet Order'),
//           onPressed: () async{
//            final errorMsg=  await ref.read(petOrderNotifierProvider.notifier).getPetOrder(order: 
//             PetOrderModel(
//             id: 0, 
//             petId: int.tryParse(petIdController.text.trim()) ?? 0,
//             quantity: int.tryParse(quantityController.text.trim())??0, 
//             shipDate: DateTime.now(), 
//             status: '', 
//             complete: false)

//             );
       
//           if (errorMsg != null) {
     
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('$errorMsg')),
//       );
//     } else {
    
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Order Success!')),
//       );
//     }
      
            
//           },
//         ),
        
//       ],
//     );
//   }

// }
// class PetOrderScreen extends ConsumerWidget{
//   final TextEditingController petIdController=TextEditingController();
//   final TextEditingController quantityController=TextEditingController();
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final petOrderState=ref.watch(petOrderNotifierProvider);

//     return Column(
//       children: [
//        TextField(
//         controller: petIdController,
//         decoration: const InputDecoration(
//           labelText: 'Pet ID',
//         ),
//        ),
//        TextField(
//         controller: quantityController,
//         decoration: const InputDecoration(
//           labelText: 'Quantity',
//         ),),
      
//         ElevatedButton(
//           child:  Text('Get Pet Order'),
//           onPressed: () async{
//            final errorMsg=  await ref.read(petOrderNotifierProvider.notifier).getPetOrder(order: 
//             PetOrderModel(
//             id: 0, 
//             petId: int.tryParse(petIdController.text.trim()) ?? 0,
//             quantity: int.tryParse(quantityController.text.trim())??0, 
//             shipDate: DateTime.now(), 
//             status: '', 
//             complete: false)

//             );
       
        
//           },
//         ),
//          petOrderState.when(
//           data:(message) => Text('Sucess'), 
//            error: (err, stack) => Center(
//           child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
//       ),
//           loading: () => const CircularProgressIndicator())
            
//       ],
//     );
//   }

// }

class PetOrderScreen extends ConsumerWidget{
  final TextEditingController petIdController=TextEditingController();
  final TextEditingController quantityController=TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petOrderState=ref.watch(petOrderNotifierProvider);

    return Column(
      children: [
       TextField(
        controller: petIdController,
        decoration: const InputDecoration(
          labelText: 'Pet ID',
        ),
       ),
       TextField(
        controller: quantityController,
        decoration: const InputDecoration(
          labelText: 'Quantity',
        ),),
      
        ElevatedButton(
          child:  Text('Get Pet Order'),
          onPressed: () async{
            await ref.read(petOrderNotifierProvider.notifier).getPetOrder(order: 
            PetOrderModel(
            id: 0, 
            petId: int.tryParse(petIdController.text.trim()) ?? 0,
            quantity: int.tryParse(quantityController.text.trim())??0, 
            shipDate: DateTime.now(), 
            status: '', 
            complete: false)

            );
       
        
          },
        ),
        if(petOrderState.value!=null)...[
          Text('id ${petOrderState.value?.id}'),
          Text('quantity ${petOrderState.value?.quantity}'),
        ]
         else if(petOrderState.isLoading)...[
         const CircularProgressIndicator()
         ]
         else if (petOrderState.hasError)...[
          Center(
          child: Text('Error', style: const TextStyle(color: Colors.red)),
      ),
         ]
        
            
      ],
    );
  }

}