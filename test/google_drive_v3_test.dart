import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_drive_v3/google_drive_v3.dart';

void main() {
  const MethodChannel channel = MethodChannel('google_drive_v3');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GoogleDriveV3.platformVersion, '42');
  });
}
