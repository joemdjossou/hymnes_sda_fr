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
    final dateAdded = DateTime.fromMillisecondsSinceEpoch(
      json['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
    );
    return FavoriteHymn(hymn: hymn, dateAdded: dateAdded);
  }

  Map<String, dynamic> toJson() {
    final json = hymn.toJson();
    json['dateAdded'] = dateAdded.millisecondsSinceEpoch;
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
