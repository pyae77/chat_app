import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordNoifier extends Notifier<bool>{
  @override
  bool build() {
    // TODO: implement build
    return false;
  }
  void togglePasswordVisibility(){
    state=!state;
  }

}
final passwordProvider=NotifierProvider.autoDispose<PasswordNoifier,bool>(PasswordNoifier.new);

class PasswordRiverpod extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final isObscure=ref.watch(passwordProvider);
     return TextField(
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(isObscure?Icons.visibility_off:Icons.visibility),
          onPressed: (){
           ref.read(passwordProvider.notifier).togglePasswordVisibility();
          },
        ),
      ),
     );
  }

}