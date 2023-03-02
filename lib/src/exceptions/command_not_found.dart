import 'package:nyxx_interactions/nyxx_interactions.dart';

/// An error thrown when an interaction is received but nyxx_interactions cannot find a matching command model.
///
/// Normally this indicates that a desync between nyxx_interactions and Discord has occurred. Make sure you call [IInteractions.sync] and that there are no
/// guild commands left undeleted.
class CommandNotFoundException implements Exception {
  /// The interaction containing the unknown command.
  final ISlashCommandInteraction interaction;

  /// Create a new [CommandNotFoundException].
  CommandNotFoundException(this.interaction);

  @override
  String toString() => 'Command not found: ${interaction.commandId}';
}
