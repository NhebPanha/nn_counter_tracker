import 'package:flutter_test/flutter_test.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

void main() {
  group('CounterData', () {
    test('empty has zeroed counters', () {
      const data = CounterData.empty('a');
      expect(data.id, 'a');
      expect(data.views, 0);
      expect(data.clicks, 0);
      expect(data.lastViewedAt, isNull);
      expect(data.lastClickedAt, isNull);
    });

    test('copyWith overrides only provided fields', () {
      const data = CounterData(id: 'a', views: 1, clicks: 2);
      final copy = data.copyWith(views: 5);
      expect(copy.views, 5);
      expect(copy.clicks, 2);
      expect(copy.id, 'a');
    });

    test('json round-trips', () {
      final data = CounterData(
        id: 'a',
        views: 3,
        clicks: 4,
        lastViewedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
        lastClickedAt: DateTime.utc(2026, 6, 7, 8, 9, 10),
      );
      final restored = CounterData.fromJson(data.toJson());
      expect(restored, data);
    });

    test('equality and hashCode', () {
      const a = CounterData(id: 'x', views: 1, clicks: 1);
      const b = CounterData(id: 'x', views: 1, clicks: 1);
      const c = CounterData(id: 'x', views: 2, clicks: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('fromJson tolerates missing/legacy fields', () {
      final data = CounterData.fromJson(<String, dynamic>{'id': 'z'});
      expect(data.views, 0);
      expect(data.clicks, 0);
    });
  });
}
