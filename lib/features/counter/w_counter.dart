import 'package:flutter_template/features/counter/p_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Counter extends ConsumerWidget {

  const Counter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int countValue = ref.watch(counterProvider);
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text(countValue.toString()),
        ),
      ],
    );
  }
}
