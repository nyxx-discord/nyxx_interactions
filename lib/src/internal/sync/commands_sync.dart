import 'dart:async';

import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';

/// Used to make multiple methods of checking if the slash commands have been edited since last update
abstract class ICommandsSync {
  /// Should the commands & perms be synced?
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands);
}
