import 'package:shorebird_cli/src/command.dart';
import 'package:shorebird_cli/src/commands/commands.dart';

/// {@template account_command}
/// `shorebird account`
///  Manage your Shorebird account.
/// {@endtemplate}
class AccountCommand extends ShorebirdCommand {
  /// {@macro account_command}
  AccountCommand({required super.logger, super.auth}) {
    addSubcommand(CreateAccountCommand(logger: logger));
    addSubcommand(SubscribeAccountCommand(logger: logger));
  }

  @override
  String get name => 'account';

  @override
  String get description => 'Manage your Shorebird account.';
}
