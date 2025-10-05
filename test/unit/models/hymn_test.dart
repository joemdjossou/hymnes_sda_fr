import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';

void main() {
  group('Hymn Model Tests', () {
    late Hymn hymn;

    setUp(() {
      hymn = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics content',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Traditional',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );
    });

    test('should create hymn with all properties', () {
      expect(hymn.number, '1');
      expect(hymn.title, 'Test Hymn');
      expect(hymn.lyrics, 'Test lyrics content');
      expect(hymn.author, 'Test Author');
      expect(hymn.composer, 'Test Composer');
      expect(hymn.style, 'Traditional');
      expect(hymn.sopranoFile, 'soprano.mp3');
      expect(hymn.altoFile, 'alto.mp3');
      expect(hymn.tenorFile, 'tenor.mp3');
      expect(hymn.bassFile, 'bass.mp3');
      expect(hymn.midiFile, 'midi.mid');
      expect(hymn.theme, 'Test Theme');
      expect(hymn.subtheme, 'Test Subtheme');
      expect(hymn.story, 'Test story');
    });

    test('should convert hymn to JSON', () {
      final json = hymn.toJson();

      expect(json['number'], '1');
      expect(json['title'], 'Test Hymn');
      expect(json['lyrics'], 'Test lyrics content');
      expect(json['author'], 'Test Author');
      expect(json['composer'], 'Test Composer');
      expect(json['style'], 'Traditional');
      expect(json['sopranoFile'], 'soprano.mp3');
      expect(json['altoFile'], 'alto.mp3');
      expect(json['tenorFile'], 'tenor.mp3');
      expect(json['bassFile'], 'bass.mp3');
      expect(json['midiFile'], 'midi.mid');
      expect(json['theme'], 'Test Theme');
      expect(json['subtheme'], 'Test Subtheme');
      expect(json['story'], 'Test story');
    });

    test('should create hymn from JSON', () {
      final json = {
        'number': '2',
        'title': 'Another Hymn',
        'lyrics': 'Another lyrics content',
        'author': 'Another Author',
        'composer': 'Another Composer',
        'style': 'Modern',
        'sopranoFile': 'soprano2.mp3',
        'altoFile': 'alto2.mp3',
        'tenorFile': 'tenor2.mp3',
        'bassFile': 'bass2.mp3',
        'midiFile': 'midi2.mid',
        'theme': 'Another Theme',
        'subtheme': 'Another Subtheme',
        'story': 'Another story',
      };

      final createdHymn = Hymn.fromJson(json);

      expect(createdHymn.number, '2');
      expect(createdHymn.title, 'Another Hymn');
      expect(createdHymn.lyrics, 'Another lyrics content');
      expect(createdHymn.author, 'Another Author');
      expect(createdHymn.composer, 'Another Composer');
      expect(createdHymn.style, 'Modern');
      expect(createdHymn.sopranoFile, 'soprano2.mp3');
      expect(createdHymn.altoFile, 'alto2.mp3');
      expect(createdHymn.tenorFile, 'tenor2.mp3');
      expect(createdHymn.bassFile, 'bass2.mp3');
      expect(createdHymn.midiFile, 'midi2.mid');
      expect(createdHymn.theme, 'Another Theme');
      expect(createdHymn.subtheme, 'Another Subtheme');
      expect(createdHymn.story, 'Another story');
    });

    test('should handle empty files', () {
      final hymnWithEmptyFiles = Hymn(
        number: '3',
        title: 'Hymn without files',
        lyrics: 'Test lyrics',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Traditional',
        sopranoFile: '',
        altoFile: '',
        tenorFile: '',
        bassFile: '',
        midiFile: '',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      expect(hymnWithEmptyFiles.sopranoFile, isEmpty);
      expect(hymnWithEmptyFiles.altoFile, isEmpty);
      expect(hymnWithEmptyFiles.tenorFile, isEmpty);
      expect(hymnWithEmptyFiles.bassFile, isEmpty);
      expect(hymnWithEmptyFiles.midiFile, isEmpty);
    });

    test('should be equal when properties are the same', () {
      final hymn1 = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics content',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Traditional',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      final hymn2 = Hymn(
        number: '1',
        title: 'Test Hymn',
        lyrics: 'Test lyrics content',
        author: 'Test Author',
        composer: 'Test Composer',
        style: 'Traditional',
        sopranoFile: 'soprano.mp3',
        altoFile: 'alto.mp3',
        tenorFile: 'tenor.mp3',
        bassFile: 'bass.mp3',
        midiFile: 'midi.mid',
        theme: 'Test Theme',
        subtheme: 'Test Subtheme',
        story: 'Test story',
      );

      expect(hymn1, equals(hymn2));
    });
  });
}
