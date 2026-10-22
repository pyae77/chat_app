import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'counter_notiifier.dart';

class CounterScreen extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterProvider);
    return Scaffold(
      backgroundColor: counterState.isDarkMode ? Colors.black87 : Colors.white,
      appBar: AppBar(
        title: Text('Counter Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: ${counterState.count}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).increment();
              },
              child: Text('Increment'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).decrement();
              },
              child: Text('Decrement'),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: counterState.isDarkMode,
              onChanged: (value) {
                ref.read(counterProvider.notifier).toggleDarkMode();
              },
            ),
          ],
        ),
      ),
    );
  }

}