import 'package:flutter/foundation.dart';

/// Immutable snapshot of the tracking counters associated with a single [id].
///
/// A [CounterData] holds the number of [views] and [clicks] that have been
/// recorded for a tracked widget, along with the timestamps of the most recent
/// view and click.
///
/// Instances are value types: two instances with identical field values are
/// considered equal (see [operator ==]).
@immutable
class CounterData {
  /// Creates a [CounterData].
  const CounterData({
    required this.id,
    this.views = 0,
    this.clicks = 0,
    this.lastViewedAt,
    this.lastClickedAt,
  });

  /// Creates an empty [CounterData] for [id] with all counters set to zero.
  const CounterData.empty(this.id)
      : views = 0,
        clicks = 0,
        lastViewedAt = null,
        lastClickedAt = null;

  /// The unique identifier of the tracked entity (widget, product, banner…).
  final String id;

  /// The total number of recorded views/impressions.
  final int views;

  /// The total number of recorded clicks/taps.
  final int clicks;

  /// The moment the most recent view was recorded, or `null` if never viewed.
  final DateTime? lastViewedAt;

  /// The moment the most recent click was recorded, or `null` if never clicked.
  final DateTime? lastClickedAt;

  /// Returns a copy of this object with the given fields replaced.
  CounterData copyWith({
    String? id,
    int? views,
    int? clicks,
    DateTime? lastViewedAt,
    DateTime? lastClickedAt,
  }) {
    return CounterData(
      id: id ?? this.id,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      lastClickedAt: lastClickedAt ?? this.lastClickedAt,
    );
  }

  /// Deserializes a [CounterData] from a JSON map.
  factory CounterData.fromJson(Map<String, dynamic> json) {
    return CounterData(
      id: json['id'] as String,
      views: (json['views'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      lastViewedAt: _parseDate(json['lastViewedAt']),
      lastClickedAt: _parseDate(json['lastClickedAt']),
    );
  }

  /// Serializes this object to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'views': views,
      'clicks': clicks,
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'lastClickedAt': lastClickedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterData &&
        other.id == id &&
        other.views == views &&
        other.clicks == clicks &&
        other.lastViewedAt == lastViewedAt &&
        other.lastClickedAt == lastClickedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, views, clicks, lastViewedAt, lastClickedAt);

  @override
  String toString() =>
      'CounterData(id: $id, views: $views, clicks: $clicks, '
      'lastViewedAt: $lastViewedAt, lastClickedAt: $lastClickedAt)';
}
