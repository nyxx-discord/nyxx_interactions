import "dart:io";

import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:nyxx/nyxx.dart";

void main() {
  final bot = Nyxx(Platform.environment["BOT_TOKEN"]!, GatewayIntents.allUnprivileged);

  Interactions(bot)
    // ..registerSlashCommand(SlashCommandBuilder("test", "This is command group test", [
    //   CommandOptionBuilder(CommandOptionType.string, "group1", "this is subcommand group", autoComplete: true)
    // ], guild: 302360552993456135.toSnowflake()))
    ..registerSlashCommand(SlashCommandBuilder("testfiles", "This is command group test", [], guild: 302360552993456135.toSnowflake())
      ..registerHandler((p0) async {
        final builder = ComponentMessageBuilder()
          ..content = "this is content"
          ..addAttachment(AttachmentBuilder.path("/home/lusha/Pictures/dragraceundergambling.jpg"))
          ..addComponentRow(ComponentRowBuilder()
            ..addComponent(LinkButtonBuilder("This is discord link", "discord://-/channels/@me/"))
          );
        await p0.respond(builder, hidden: true);
        await p0.sendFollowup(builder);
      })
    )
    // ..registerAutocompleteHandler("group1", (event) => event.respond([ArgChoiceBuilder("test", "test")]))
    ..syncOnReady();

//   Interactions(bot)
//     ..registerSlashCommand(
//         SlashCommandBuilder("itest", "This is test command", [
//           CommandOptionBuilder(
//               CommandOptionType.subCommand, "testi", "This is testi", options: [CommandOptionBuilder(CommandOptionType.user, "user", "this is user")])
//                 ..registerHandler((event) {
//                   event.acknowledge();
//                   event.respond(MessageBuilder.content("This is respond"));
//                 })
//           // CommandOptionBuilder(
//           //     CommandOptionType.subCommand, "testii", "This is testi")
//           //   ..registerHandler((event) async {
//           //     await event.acknowledge(hidden: true);
//           //
//           //     await event.respond(MessageBuilder.content("This is respond1"));
//           //   })
//         ], guild: 302360552993456135.toSnowflake())
//     )..registerSlashCommand(
//       SlashCommandBuilder(
//           "buttontest", "This is command for testing buttons", [],
//           guild: 302360552993456135.toSnowflake())
//         ..registerHandler((event) async {
//           await event.acknowledge();
//
//           final select = MultiselectBuilder("testid", [
//             MultiselectOptionBuilder("Example label", "123")
//               ..emoji = UnicodeEmoji("💕"),
//             MultiselectOptionBuilder("Example label 2", "1233"),
//           ]);
//
//           await event.respond(ComponentMessageBuilder()
//             ..content = "Buttons"
//             ..components = [
//               [
//                 ButtonBuilder(
//                     "Disappearing button", "testowyu", ComponentStyle.danger)
//               ],
//               [select]
//             ]);
//         })
//   )
//   ..registerButtonHandler("testowyu", (event) async {
//     // await event.respond(ButtonMessageBuilder()..buttons = []..content = "new content");
//     await event.acknowledge();
//     await event.respond(ComponentMessageBuilder()
//       ..content = "This is test if it works"
//       ..components = []);
//   })
//   ..registerMultiselectHandler("testid", (event) async {
//     await event.respond(MessageBuilder.content("Responded"));
//   })
//   ..syncOnReady();
//   // ..registerHandler("reply", "This is test command",
//   //     [CommandOptionBuilder(CommandOptionType.subCommand, "test1", "This is description"), CommandOptionBuilder(CommandOptionType.subCommand, "test2", "this is test")], guild: 302360552993456135.toSnowflake(),
//   //     handler: (event) async {
//   //   await event.acknowledge();
//   //
//   //   final subCommand = event.subCommand;
//   //
//   //   if (subCommand == null) {
//   //     return;
//   //   }
//   //
//   //   Future.delayed(const Duration(seconds: 10), () async {
//   //     await event.respond(content: subCommand.name, hidden: true);
//   //
//   //     await event.sendFollowup(content: "Test followup");
//   //   });
//   // });
// // }
}
