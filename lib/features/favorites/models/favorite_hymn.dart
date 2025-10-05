import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/hymn.dart';

class FavoriteHymn extends Equatable {
  final Hymn hymn;
  final DateTime dateAdded;

  const FavoriteHymn({
    required this.hymn,
    required this.dateAdded,
  });

  @override
  List<Object?> get props => [hymn, dateAdded];

  factory FavoriteHymn.fromJson(Map<String, dynamic> json) {
    final hymn = Hymn.fromJson(json);

    // Handle both Firestore Timestamp and int milliseconds
    DateTime dateAdded;
    final dateAddedValue = json['dateAdded'];

    if (dateAddedValue is Timestamp) {
      // Firestore Timestamp
      dateAdded = dateAddedValue.toDate();
    } else if (dateAddedValue is int) {
      // Local storage milliseconds
      dateAdded = DateTime.fromMillisecondsSinceEpoch(dateAddedValue);
    } else {
      // Fallback to current time
      dateAdded = DateTime.now();
    }

    return FavoriteHymn(hymn: hymn, dateAdded: dateAdded);
  }

  Map<String, dynamic> toJson() {
    final json = hymn.toJson();
    json['dateAdded'] = dateAdded.millisecondsSinceEpoch;
    return json;
  }

  /// Convert to Firestore-compatible JSON (uses server timestamp)
  Map<String, dynamic> toFirestoreJson() {
    final json = hymn.toJson();
    json['dateAdded'] = FieldValue.serverTimestamp();
    json['userId'] = null; // Will be set by the repository
    return json;
  }

  FavoriteHymn copyWith({
    Hymn? hymn,
    DateTime? dateAdded,
  }) {
    return FavoriteHymn(
      hymn: hymn ?? this.hymn,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
