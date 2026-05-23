import 'package:flutter_test/flutter_test.dart';
import 'package:moonfin/playback/media_kit_player_backend.dart';
import 'package:moonfin/preference/preference_constants.dart';

void main() {
  group('MediaKitPlayerBackend passthrough codec synthesis', () {
    test('returns empty codecs for downmix mode', () {
      final codecs = MediaKitPlayerBackend.passthroughCodecsFromPreferences(
        audioBehavior: AudioBehavior.downmixToStereo,
        ac3Enabled: true,
        dtsEnabled: true,
        trueHdEnabled: true,
      );

      expect(codecs, isEmpty);
    });

    test('maps enabled codec toggles to mpv passthrough codec names', () {
      final codecs = MediaKitPlayerBackend.passthroughCodecsFromPreferences(
        audioBehavior: AudioBehavior.directStream,
        ac3Enabled: true,
        dtsEnabled: true,
        trueHdEnabled: true,
      );

      expect(codecs, equals(<String>['ac3', 'eac3', 'dts', 'truehd']));
    });

    test('excludes disabled codec toggles', () {
      final codecs = MediaKitPlayerBackend.passthroughCodecsFromPreferences(
        audioBehavior: AudioBehavior.directStream,
        ac3Enabled: false,
        dtsEnabled: false,
        trueHdEnabled: true,
      );

      expect(codecs, equals(<String>['truehd']));
    });
  });

  group('MediaKitPlayerBackend passthrough property synthesis', () {
    test('builds audio-spdif and audio-exclusive on desktop path', () {
      final props = MediaKitPlayerBackend
          .passthroughMpvPropertiesFromPreferences(
            audioBehavior: AudioBehavior.directStream,
            ac3Enabled: true,
            dtsEnabled: false,
            trueHdEnabled: true,
            includeAudioExclusive: true,
          );

      expect(props['audio-spdif'], equals('ac3,eac3,truehd'));
      expect(props['audio-exclusive'], equals('yes'));
    });

    test('disables exclusive when no passthrough codecs remain', () {
      final props = MediaKitPlayerBackend
          .passthroughMpvPropertiesFromPreferences(
            audioBehavior: AudioBehavior.downmixToStereo,
            ac3Enabled: true,
            dtsEnabled: true,
            trueHdEnabled: true,
            includeAudioExclusive: true,
          );

      expect(props['audio-spdif'], isEmpty);
      expect(props['audio-exclusive'], equals('no'));
    });

    test('omits audio-exclusive on non-desktop path', () {
      final props = MediaKitPlayerBackend
          .passthroughMpvPropertiesFromPreferences(
            audioBehavior: AudioBehavior.directStream,
            ac3Enabled: true,
            dtsEnabled: true,
            trueHdEnabled: false,
            includeAudioExclusive: false,
          );

      expect(props['audio-spdif'], equals('ac3,eac3,dts'));
      expect(props.containsKey('audio-exclusive'), isFalse);
    });
  });
}
