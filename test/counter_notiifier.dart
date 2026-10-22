import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'counter_state.dart';

class CounterNotifier extends Notifier<CounterState>{
  @override
  CounterState build() {
    return CounterState();
  }
  void increment() {
    state=state.copyWith(count: state.count+1);
  }
  void decrement() {
   if(state.count>0){
    state=state.copyWith(count: state.count-1);
   }
  }
  void toggleDarkMode() {
    state=state.copyWith(isDarkMode: !state.isDarkMode);
  }

}

final counterProvider=NotifierProvider<CounterNotifier,CounterState>(CounterNotifier.new);