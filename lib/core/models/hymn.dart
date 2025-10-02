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
  final String midiFile;

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
    required this.midiFile,
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
        midiFile,
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
    String? midiFile,
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
      midiFile: midiFile ?? this.midiFile,
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
      'midiFile': midiFile,
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
      midiFile: json['midiFile'] ?? '',
    );
  }
}
