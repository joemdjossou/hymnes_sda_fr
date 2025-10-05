import 'package:equatable/equatable.dart';

class Hymn extends Equatable {
  final String number;
  final String title;
  final String lyrics;
  final String author;
  final String composer;
  final String style;
  final String sopranoFile;
  final String altoFile;
  final String tenorFile;
  final String bassFile;
  final String? countertenorFile;
  final String? baritoneFile;
  final String midiFile;
  final String theme;
  final String subtheme;
  final String story;

  const Hymn({
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

  @override
  List<Object?> get props => [
        number,
        title,
        lyrics,
        author,
        composer,
        style,
        sopranoFile,
        altoFile,
        tenorFile,
        bassFile,
        countertenorFile,
        baritoneFile,
        midiFile,
        theme,
        subtheme,
        story,
      ];

  Hymn copyWith({
    String? number,
    String? title,
    String? lyrics,
    String? author,
    String? composer,
    String? style,
    String? sopranoFile,
    String? altoFile,
    String? tenorFile,
    String? bassFile,
    String? countertenorFile,
    String? baritoneFile,
    String? midiFile,
    String? theme,
    String? subtheme,
    String? story,
  }) {
    return Hymn(
      number: number ?? this.number,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      author: author ?? this.author,
      composer: composer ?? this.composer,
      style: style ?? this.style,
      sopranoFile: sopranoFile ?? this.sopranoFile,
      altoFile: altoFile ?? this.altoFile,
      tenorFile: tenorFile ?? this.tenorFile,
      bassFile: bassFile ?? this.bassFile,
      countertenorFile: countertenorFile ?? this.countertenorFile,
      baritoneFile: baritoneFile ?? this.baritoneFile,
      midiFile: midiFile ?? this.midiFile,
      theme: theme ?? this.theme,
      subtheme: subtheme ?? this.subtheme,
      story: story ?? this.story,
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

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
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
}
