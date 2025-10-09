import 'package:objectbox/objectbox.dart';

@Entity()
class HymnEntity {
  @Id()
  int id = 0;

  @Unique()
  String number;

  String title;
  String lyrics;
  String author;
  String composer;
  String style;
  String sopranoFile;
  String altoFile;
  String tenorFile;
  String bassFile;
  String? countertenorFile;
  String? baritoneFile;
  String midiFile;
  String theme;
  String subtheme;
  String story;

  HymnEntity({
    this.id = 0,
    required this.number,
    required this.title,
    required this.lyrics,
    required this.author,
    required this.composer,
    required this.style,
    required this.sopranoFile,
    required this.altoFile,
    required this.tenorFile,
    required this.bassFile,
    this.countertenorFile,
    this.baritoneFile,
    required this.midiFile,
    required this.theme,
    required this.subtheme,
    required this.story,
  });

  factory HymnEntity.fromJson(Map<String, dynamic> json) {
    return HymnEntity(
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      lyrics: json['lyrics'] ?? '',
      author: json['author'] ?? '',
      composer: json['composer'] ?? '',
      style: json['style'] ?? '',
      sopranoFile: json['sopranoFile'] ?? '',
      altoFile: json['altoFile'] ?? '',
      tenorFile: json['tenorFile'] ?? '',
      bassFile: json['bassFile'] ?? '',
      countertenorFile: json['countertenorFile'],
      baritoneFile:
          json['baritoneFile'] ?? json['barritoneFile'], // Handle typo in JSON
      midiFile: json['midiFile'] ?? '',
      theme: json['theme'] ?? '',
      subtheme: json['subtheme'] ?? '',
      story: json['story'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'lyrics': lyrics,
      'author': author,
      'composer': composer,
      'style': style,
      'sopranoFile': sopranoFile,
      'altoFile': altoFile,
      'tenorFile': tenorFile,
      'bassFile': bassFile,
      'countertenorFile': countertenorFile,
      'baritoneFile': baritoneFile,
      'midiFile': midiFile,
      'theme': theme,
      'subtheme': subtheme,
      'story': story,
    };
  }
}

@Entity()
class FavoriteHymnEntity {
  @Id()
  int id = 0;

  @Unique()
  String hymnNumber;

  String title;
  String lyrics;
  String author;
  String composer;
  String style;
  String sopranoFile;
  String altoFile;
  String tenorFile;
  String bassFile;
  String? countertenorFile;
  String? baritoneFile;
  String midiFile;
  String theme;
  String subtheme;
  String story;

  @Property(type: PropertyType.date)
  DateTime dateAdded;

  FavoriteHymnEntity({
    this.id = 0,
    required this.hymnNumber,
    required this.title,
    required this.lyrics,
    required this.author,
    required this.composer,
    required this.style,
    required this.sopranoFile,
    required this.altoFile,
    required this.tenorFile,
    required this.bassFile,
    this.countertenorFile,
    this.baritoneFile,
    required this.midiFile,
    required this.theme,
    required this.subtheme,
    required this.story,
    required this.dateAdded,
  });

  factory FavoriteHymnEntity.fromHymnEntity(
      HymnEntity hymn, DateTime dateAdded) {
    return FavoriteHymnEntity(
      hymnNumber: hymn.number,
      title: hymn.title,
      lyrics: hymn.lyrics,
      author: hymn.author,
      composer: hymn.composer,
      style: hymn.style,
      sopranoFile: hymn.sopranoFile,
      altoFile: hymn.altoFile,
      tenorFile: hymn.tenorFile,
      bassFile: hymn.bassFile,
      countertenorFile: hymn.countertenorFile,
      baritoneFile: hymn.baritoneFile,
      midiFile: hymn.midiFile,
      theme: hymn.theme,
      subtheme: hymn.subtheme,
      story: hymn.story,
      dateAdded: dateAdded,
    );
  }

  factory FavoriteHymnEntity.fromJson(Map<String, dynamic> json) {
    // Handle both Firestore Timestamp and int milliseconds
    DateTime dateAdded;
    final dateAddedValue = json['dateAdded'];

    if (dateAddedValue is int) {
      // Local storage milliseconds
      dateAdded = DateTime.fromMillisecondsSinceEpoch(dateAddedValue);
    } else {
      // Fallback to current time
      dateAdded = DateTime.now();
    }

    return FavoriteHymnEntity(
      hymnNumber: json['number'] ?? '',
      title: json['title'] ?? '',
      lyrics: json['lyrics'] ?? '',
      author: json['author'] ?? '',
      composer: json['composer'] ?? '',
      style: json['style'] ?? '',
      sopranoFile: json['sopranoFile'] ?? '',
      altoFile: json['altoFile'] ?? '',
      tenorFile: json['tenorFile'] ?? '',
      bassFile: json['bassFile'] ?? '',
      countertenorFile: json['countertenorFile'],
      baritoneFile:
          json['baritoneFile'] ?? json['barritoneFile'], // Handle typo in JSON
      midiFile: json['midiFile'] ?? '',
      theme: json['theme'] ?? '',
      subtheme: json['subtheme'] ?? '',
      story: json['story'] ?? '',
      dateAdded: dateAdded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': hymnNumber,
      'title': title,
      'lyrics': lyrics,
      'author': author,
      'composer': composer,
      'style': style,
      'sopranoFile': sopranoFile,
      'altoFile': altoFile,
      'tenorFile': tenorFile,
      'bassFile': bassFile,
      'countertenorFile': countertenorFile,
      'baritoneFile': baritoneFile,
      'midiFile': midiFile,
      'theme': theme,
      'subtheme': subtheme,
      'story': story,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }
}

@Entity()
class RecentlyPlayedEntity {
  @Id()
  int id = 0;

  @Unique()
  String hymnNumber;

  String title;
  String lyrics;
  String author;
  String composer;
  String style;
  String sopranoFile;
  String altoFile;
  String tenorFile;
  String bassFile;
  String? countertenorFile;
  String? baritoneFile;
  String midiFile;
  String theme;
  String subtheme;
  String story;

  @Property(type: PropertyType.date)
  DateTime lastPlayed;

  RecentlyPlayedEntity({
    this.id = 0,
    required this.hymnNumber,
    required this.title,
    required this.lyrics,
    required this.author,
    required this.composer,
    required this.style,
    required this.sopranoFile,
    required this.altoFile,
    required this.tenorFile,
    required this.bassFile,
    this.countertenorFile,
    this.baritoneFile,
    required this.midiFile,
    required this.theme,
    required this.subtheme,
    required this.story,
    required this.lastPlayed,
  });

  factory RecentlyPlayedEntity.fromHymnEntity(
      HymnEntity hymn, DateTime lastPlayed) {
    return RecentlyPlayedEntity(
      hymnNumber: hymn.number,
      title: hymn.title,
      lyrics: hymn.lyrics,
      author: hymn.author,
      composer: hymn.composer,
      style: hymn.style,
      sopranoFile: hymn.sopranoFile,
      altoFile: hymn.altoFile,
      tenorFile: hymn.tenorFile,
      bassFile: hymn.bassFile,
      countertenorFile: hymn.countertenorFile,
      baritoneFile: hymn.baritoneFile,
      midiFile: hymn.midiFile,
      theme: hymn.theme,
      subtheme: hymn.subtheme,
      story: hymn.story,
      lastPlayed: lastPlayed,
    );
  }

  factory RecentlyPlayedEntity.fromJson(Map<String, dynamic> json) {
    DateTime lastPlayed;
    final lastPlayedValue = json['lastPlayed'];

    if (lastPlayedValue is int) {
      lastPlayed = DateTime.fromMillisecondsSinceEpoch(lastPlayedValue);
    } else {
      lastPlayed = DateTime.now();
    }

    return RecentlyPlayedEntity(
      hymnNumber: json['number'] ?? '',
      title: json['title'] ?? '',
      lyrics: json['lyrics'] ?? '',
      author: json['author'] ?? '',
      composer: json['composer'] ?? '',
      style: json['style'] ?? '',
      sopranoFile: json['sopranoFile'] ?? '',
      altoFile: json['altoFile'] ?? '',
      tenorFile: json['tenorFile'] ?? '',
      bassFile: json['bassFile'] ?? '',
      countertenorFile: json['countertenorFile'],
      baritoneFile:
          json['baritoneFile'] ?? json['barritoneFile'], // Handle typo in JSON
      midiFile: json['midiFile'] ?? '',
      theme: json['theme'] ?? '',
      subtheme: json['subtheme'] ?? '',
      story: json['story'] ?? '',
      lastPlayed: lastPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': hymnNumber,
      'title': title,
      'lyrics': lyrics,
      'author': author,
      'composer': composer,
      'style': style,
      'sopranoFile': sopranoFile,
      'altoFile': altoFile,
      'tenorFile': tenorFile,
      'bassFile': bassFile,
      'countertenorFile': countertenorFile,
      'baritoneFile': baritoneFile,
      'midiFile': midiFile,
      'theme': theme,
      'subtheme': subtheme,
      'story': story,
      'lastPlayed': lastPlayed.millisecondsSinceEpoch,
    };
  }
}

@Entity()
class SettingEntity {
  @Id()
  int id = 0;

  @Unique()
  String key;

  String value;

  SettingEntity({
    this.id = 0,
    required this.key,
    required this.value,
  });

  factory SettingEntity.fromJson(Map<String, dynamic> json) {
    return SettingEntity(
      key: json['key'] ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
