import 'package:flutter_riverpod/legacy.dart';

final bottomNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');