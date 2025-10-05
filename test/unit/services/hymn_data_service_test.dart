import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/core/services/hymn_data_service.dart';

void main() {
  group('HymnDataService Tests', () {
    late HymnDataService hymnDataService;

    setUp(() {
      hymnDataService = HymnDataService();
    });

    test('should load hymns from assets', () async {
      // Mock the rootBundle.loadString method
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/data/hymns.json') {
            return '''
            [
              {
                "number": "1",
                "title": "Test Hymn 1",
                "lyrics": "Test lyrics 1",
                "author": "Test Author 1",
                "composer": "Test Composer 1",
                "style": "Traditional",
                "sopranoFile": "soprano1.mp3",
                "altoFile": "alto1.mp3",
                "tenorFile": "tenor1.mp3",
                "bassFile": "bass1.mp3",
                "midiFile": "midi1.mid",
                "theme": "Test Theme 1",
                "subtheme": "Test Subtheme 1",
                "story": "Test story 1"
              },
              {
                "number": "2",
                "title": "Test Hymn 2",
                "lyrics": "Test lyrics 2",
                "author": "Test Author 2",
                "composer": "Test Composer 2",
                "style": "Modern",
                "sopranoFile": "soprano2.mp3",
                "altoFile": "alto2.mp3",
                "tenorFile": "tenor2.mp3",
                "bassFile": "bass2.mp3",
                "midiFile": "midi2.mid",
                "theme": "Test Theme 2",
                "subtheme": "Test Subtheme 2",
                "story": "Test story 2"
              }
            ]
            ''';
          }
          return null;
        },
      );

      final hymns = await hymnDataService.getHymns();

      expect(hymns, isA<List<Hymn>>());
      expect(hymns.length, 2);
      expect(hymns[0].number, '1');
      expect(hymns[0].title, 'Test Hymn 1');
      expect(hymns[1].number, '2');
      expect(hymns[1].title, 'Test Hymn 2');
    });

    test('should handle empty hymns data', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/data/hymns.json') {
            return '[]';
          }
          return null;
        },
      );

      final hymns = await hymnDataService.getHymns();

      expect(hymns, isA<List<Hymn>>());
      expect(hymns.length, 0);
    });

    test('should handle malformed JSON', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/data/hymns.json') {
            return 'invalid json';
          }
          return null;
        },
      );

      expect(() => hymnDataService.getHymns(), throwsA(isA<Exception>()));
    });

    test('should handle missing asset file', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/data/hymns.json') {
            throw PlatformException(code: 'NOT_FOUND');
          }
          return null;
        },
      );

      expect(
          () => hymnDataService.getHymns(), throwsA(isA<PlatformException>()));
    });

    test('should handle hymns with missing optional fields', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/data/hymns.json') {
            return '''
            [
              {
                "number": "1",
                "title": "Test Hymn",
                "lyrics": "Test lyrics",
                "author": "Test Author",
                "composer": "Test Composer",
                "style": "Traditional",
                "sopranoFile": "",
                "altoFile": "",
                "tenorFile": "",
                "bassFile": "",
                "midiFile": "",
                "theme": "Test Theme",
                "subtheme": "Test Subtheme",
                "story": "Test story"
              }
            ]
            ''';
          }
          return null;
        },
      );

      final hymns = await hymnDataService.getHymns();

      expect(hymns.length, 1);
      expect(hymns[0].sopranoFile, isEmpty);
      expect(hymns[0].altoFile, isEmpty);
      expect(hymns[0].tenorFile, isEmpty);
      expect(hymns[0].bassFile, isEmpty);
      expect(hymns[0].midiFile, isEmpty);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('flutter/assets'), null);
    });
  });
}
