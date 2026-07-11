import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

import 'in_memory_storage.dart';

void main() {
  late CounterTrackerService service;

  setUp(() async {
    service = CounterTrackerService.instance;
    service.configure(storage: InMemoryCounterStorage(), enableLogs: false);
    await service.clear();
  });

  testWidgets('CounterClickTracker records taps and fires callback',
      (tester) async {
    var lastCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CounterClickTracker(
            id: 'btn',
            onClicked: (count) => lastCount = count,
            child: const Text('Tap me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();

    expect(lastCount, 1);
    expect(await service.getClicks('btn'), 1);
  });

  testWidgets('CounterBuilder rebuilds when counters change', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CounterBuilder(
            id: 'card',
            builder: (context, data, _) =>
                Text('V:${data.views} C:${data.clicks}'),
          ),
        ),
      ),
    );

    expect(find.text('V:0 C:0'), findsOneWidget);

    await service.incrementView('card');
    await tester.pump();

    expect(find.text('V:1 C:0'), findsOneWidget);
  });
}
