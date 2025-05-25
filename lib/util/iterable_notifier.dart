import 'package:flutter_riverpod/flutter_riverpod.dart';

class IterableNotifier<T, C extends Iterable<T>> extends StateNotifier<C> {
  IterableNotifier(super.state);

  int get length => state.length;
  bool get isEmpty => state.isEmpty;
  bool contains(T item) => state.contains(item);

  @override
  bool updateShouldNotify(C old, C current) => true;
}
