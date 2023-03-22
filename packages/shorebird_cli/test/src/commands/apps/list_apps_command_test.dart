import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shorebird_cli/src/auth/auth.dart';
import 'package:shorebird_cli/src/auth/session.dart';
import 'package:shorebird_cli/src/commands/commands.dart';
import 'package:shorebird_code_push_client/shorebird_code_push_client.dart';
import 'package:test/test.dart';

class _MockAuth extends Mock implements Auth {}

class _MockCodePushClient extends Mock implements CodePushClient {}

class _MockLogger extends Mock implements Logger {}

void main() {
  group('list', () {
    const session = Session(apiKey: 'test-api-key');

    late Auth auth;
    late CodePushClient codePushClient;
    late Logger logger;

    late ListAppsCommand command;

    setUp(() {
      auth = _MockAuth();
      codePushClient = _MockCodePushClient();
      logger = _MockLogger();
      command = ListAppsCommand(
        auth: auth,
        buildCodePushClient: ({required String apiKey, Uri? hostedUri}) {
          return codePushClient;
        },
        logger: logger,
      );

      when(() => auth.currentSession).thenReturn(session);
    });

    test('description is correct', () {
      expect(command.description, equals('List all apps using Shorebird.'));
    });

    test('returns ExitCode.noUser when not logged in', () async {
      when(() => auth.currentSession).thenReturn(null);
      expect(await command.run(), ExitCode.noUser.code);
    });

    test('returns ExitCode.software when unable to get apps', () async {
      when(() => codePushClient.getApps()).thenThrow(Exception());
      expect(await command.run(), ExitCode.software.code);
    });

    test('returns ExitCode.success when apps are empty', () async {
      when(() => codePushClient.getApps()).thenAnswer((_) async => []);
      expect(await command.run(), ExitCode.success.code);
      verify(() => logger.info('(empty)')).called(1);
    });

    test('returns ExitCode.success when apps are not empty', () async {
      final apps = [
        const AppMetadata(
          appId: '30370f27-dbf1-4673-8b20-fb096e38dffa',
          displayName: 'Shorebird Counter',
          latestReleaseVersion: '1.0.0',
          latestPatchNumber: 1,
        ),
      ];
      when(() => codePushClient.getApps()).thenAnswer((_) async => apps);
      expect(await command.run(), ExitCode.success.code);
      verify(
        () => logger.info(
          '''Shorebird Counter: v1.0.0 (patch #1) (30370f27-dbf1-4673-8b20-fb096e38dffa)''',
        ),
      ).called(1);
    });
  });
}
