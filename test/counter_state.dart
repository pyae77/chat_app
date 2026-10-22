class CounterState {
  final int count;
  final bool isDarkMode;

  CounterState({this.count = 0, this.isDarkMode = false});

  CounterState copyWith({int? count, bool? isDarkMode}) {
    return CounterState(
      count: count ?? this.count,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}