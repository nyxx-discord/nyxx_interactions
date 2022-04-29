import 'dart:async';

import 'package:nyxx_interactions/src/internal/sync/commands_sync.dart';
import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';

/// Manually define command syncing rules
class ManualCommandSync implements ICommandsSync {
  /// If commands should be overridden on next run.
  final bool sync;

  /// Manually define command syncing rules
  const ManualCommandSync({this.sync = true});

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) => sync;
}
