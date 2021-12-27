import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";

void main() {
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  IInteractions.create(WebsocketInteractionBackend(bot))
    ..registerSlashCommand(
        SlashCommandBuilder("itest", "This is test command", [
          CommandOptionBuilder(CommandOptionType.subCommand, "subtest", "This is sub test")
            ..registerHandler((event) => event.respond(MessageBuilder.content("This is example command")))
        ], guild: 302360552993456135.toSnowflake())
    )..syncOnReady();
}
