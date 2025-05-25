import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/providers/iterable_notifier.dart';

class ListNotifier<T> extends IterableNotifier<T, List<T>> {
  ListNotifier(super.state);

  void add(T item) {
    state.add(item);
    state = state;
  }

  void remove(T item) {
    state.remove(item);
    state = state;
  }
}

typedef ListNotifierProvider<T> = StateNotifierProvider<ListNotifier<T>, List<T>>;