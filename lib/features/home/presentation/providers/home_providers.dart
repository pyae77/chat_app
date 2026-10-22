
import 'package:flutter_riverpod/legacy.dart';


final bottomNavIndexProvider = StateProvider<int>((ref) => 0);


final searchQueryProvider = StateProvider<String>((ref) => '');