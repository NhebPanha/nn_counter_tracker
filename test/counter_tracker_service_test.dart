import 'package:flutter_test/flutter_test.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

void main() {
  late CounterTrackerService service;

  setUp(() async {
    service = CounterTrackerService.instance;
    service.configure(storage: MemoryCounterStorage(), enableLogs: false);
    await service.clear();
  });

  group('CounterTrackerService', () {
    test('incrementView increments and persists', () async {
      final a = await service.incrementView('p1');
      final b = await service.incrementView('p1');
      expect(a.views, 1);
      expect(b.views, 2);
      expect(await service.getViews('p1'), 2);
    });

    test('incrementClick increments and persists', () async {
      await service.incrementClick('p1');
      final data = await service.incrementClick('p1');
      expect(data.clicks, 2);
      expect(await service.getClicks('p1'), 2);
    });

    test('listenable reflects latest value', () async {
      final listenable = service.listenable('p2');
      await service.incrementView('p2');
      expect(listenable.value.views, 1);
    });

    test('updates stream emits on change', () async {
      final future = service.updates.firstWhere((d) => d.id == 'p3');
      await service.incrementClick('p3');
      final emitted = await future;
      expect(emitted.clicks, 1);
    });

    test('getAllCounters returns all tracked ids', () async {
      await service.incrementView('a');
      await service.incrementClick('b');
      final all = await service.getAllCounters();
      expect(all.keys, containsAll(<String>['a', 'b']));
    });

    test('clear resets everything', () async {
      await service.incrementView('a');
      await service.clear();
      expect(await service.getViews('a'), 0);
      expect((await service.getAllCounters()), isEmpty);
    });

    test('CounterAnalytics facade delegates to the service', () async {
      await CounterAnalytics.trackView('promo');
      expect(await CounterAnalytics.getViews('promo'), 1);
    });
  });
}
