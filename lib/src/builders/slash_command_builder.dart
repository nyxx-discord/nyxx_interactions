import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/builders/command_option_builder.dart';
import 'package:nyxx_interactions/src/builders/command_permission_builder.dart';
import 'package:nyxx_interactions/src/models/slash_command_type.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/internal/utils.dart';
import 'package:nyxx_interactions/src/typedefs.dart';

/// A slash command, can only be instantiated through a method on [IInteractions]
class SlashCommandBuilder extends Builder {
  /// The commands ID that is defined on registration and used for permission syncing.
  late final Snowflake _id;

  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// The command names to be shown to the user in the Slash Command UI by specified locales.
  /// See the [available locales](https://discord.com/developers/docs/reference#locales) for a list of available locales.
  /// The key is the locale and the value is the name of the command in that locale.
  /// Values follow the same constraints as [name] (`^[\w-]{1,32}$`).
  ///
  /// An example:
  /// {@template slashcommand.builder.example}
  /// ```dart
  /// final scb = SlashCommandBuilder(
  ///   'hello',
  ///   'Hello World!',
  ///   [],
  ///   localizationsName: {
  ///     'fr': 'salut',
  ///     'de': 'hallo',
  ///   },
  ///   localizationsDescription: {
  ///     'fr': 'Salut le monde !',
  ///     'de': 'Hallo Welt!',
  ///   },
  /// );
  /// ```
  /// {@endtemplate}
  /// {@template discord.override.link}
  ///
  /// At this time, the localized feature is still in developement, so you you must set [an override] on your discord client.
  ///
  /// The override is `feature/web-slash-commands-localization` that you can get [here].
  ///
  /// [an override]: https://support.discord.com/hc/de/articles/360030114991
  /// [here]: https://discord.com/__development/link?s=qTpnDQLUm66XsoBawqlEcXO3G9jPncSIJy9OSKnIcSk%3D.eyJ0YXJnZXRCdWlsZE92ZXJyaWRlIjp7ImRpc2NvcmRfd2ViIjp7InR5cGUiOiJicmFuY2giLCJpZCI6ImZlYXR1cmUvd2ViLXNsYXNoLWNvbW1hbmQtbG9jYWxpemF0aW9uIn19LCJyZWxlYXNlQ2hhbm5lbCI6bnVsbCwidmFsaWRGb3JVc2VySWRzIjpbXSwiYWxsb3dMb2dnZWRPdXQiOmZhbHNlLCJleHBpcmVzQXQiOiJGcmksIDIwIE1heSAyMDIyIDE4OjA2OjU5IEdNVCJ9
  /// {@endtemplate}
  ///
  final Map<String, String>? localizationsName;

  /// Command description shown to the user in the Slash Command UI
  final String? description;

  /// The command descriptions to be shown to the user in the Slash Command UI by specified locales.
  /// See the [available locales](https://discord.com/developers/docs/reference#locales) for a list of available locales.
  /// The key is the locale and the value is the description of the command in that locale.
  /// Values follow the same constraints as [description].
  ///
  /// An example:
  /// {@macro slashcommand.builder.example}
  /// {@macro discord.override.link}
  final Map<String, String>? localizationsDescription;

  /// If people can use the command by default or if they need permissions to use it.
  @Deprecated('Use canBeUsedInDm and requiredPermissions instead')
  final bool defaultPermissions;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  Snowflake? guild;

  /// The arguments that the command takes
  List<CommandOptionBuilder> options;

  /// Permission overrides for the command
  @Deprecated('Use canBeUsedInDm and requiredPermissions instead')
  List<CommandPermissionBuilderAbstract>? permissions;

  /// Target of slash command if different that SlashCommandTarget.chat - slash command will
  /// become context menu in appropriate context
  SlashCommandType type;

  /// Handler for SlashCommandBuilder
  SlashCommandHandler? handler;

  /// Whether this slash command can be used in a DM channel with the bot.
  final bool canBeUsedInDm;

  /// A set of permissions required by users in guilds to execute this command.
  ///
  /// The integer to use for a permission can be obtained by using [PermissionsConstants]. If a member has any of the permissions combined with the bitwise OR
  /// operator, they will be allowed to execute the command.
  int? requiredPermissions;

  /// A slash command, can only be instantiated through a method on [IInteractions]
  SlashCommandBuilder(
    this.name,
    this.description,
    this.options, {
    this.canBeUsedInDm = true,
    this.requiredPermissions,
    this.guild,
    this.type = SlashCommandType.chat,
    @Deprecated('Use canBeUsedInDm and requiredPermissions instead') this.defaultPermissions = true,
    @Deprecated('Use canBeUsedInDm and requiredPermissions instead') this.permissions,
    this.localizationsName,
    this.localizationsDescription,
  }) {
    if (!slashCommandNameRegex.hasMatch(name)) {
      throw ArgumentError("Command name has to match regex: ${slashCommandNameRegex.pattern}");
    }

    if (description == null && type == SlashCommandType.chat) {
      throw ArgumentError("Normal slash command needs to have description");
    }

    if (description != null && type != SlashCommandType.chat) {
      throw ArgumentError("Context menus cannot have description");
    }
  }

  @override
  RawApiMap build() => {
        "name": name,
        if (type == SlashCommandType.chat) "description": description,
        if (options.isNotEmpty) "options": options.map((e) => e.build()).toList(),
        "type": type.value,
        "dm_permission": canBeUsedInDm,
        if (requiredPermissions != null) "default_member_permissions": requiredPermissions.toString(),
        if (localizationsName != null) "name_localizations": localizationsName,
        if (localizationsDescription != null) "description_localizations": localizationsDescription,
        "default_permission": defaultPermissions,
      };

  void setId(Snowflake id) => _id = id;

  Snowflake get id => _id;

  /// Register a permission
  @Deprecated('Use canBeUsedInDm and requiresPermissions instead')
  void addPermission(CommandPermissionBuilderAbstract permission) {
    permissions ??= [];

    permissions!.add(permission);
  }

  /// Registers handler for command. Note command cannot have handler if there are options present
  void registerHandler(SlashCommandHandler handler) {
    if (options.any((element) => element.type == CommandOptionType.subCommand || element.type == CommandOptionType.subCommandGroup)) {
      throw ArgumentError("Cannot register handler for slash command if command have subcommand or subcommandgroup");
    }

    this.handler = handler;
  }
}
