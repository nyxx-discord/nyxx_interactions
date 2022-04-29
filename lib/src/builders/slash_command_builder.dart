import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/builders/command_option_builder.dart';
import 'package:nyxx_interactions/src/builders/command_permission_builder.dart';

import 'package:nyxx_interactions/src/models/slash_command_type.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/internal/utils.dart';
import 'package:nyxx_interactions/src/typedefs.dart';

/// A slash command, can only be instantiated through a method on [Interactions]
class SlashCommandBuilder extends Builder {
  /// The commands ID that is defined on registration and used for permission syncing.
  late final Snowflake _id;

  /// Command name to be shown to the user in the Slash Command UI
  final String name;

  /// Command description shown to the user in the Slash Command UI
  final String? description;

  /// If people can use the command by default or if they need permissions to use it.
  @Deprecated('Use canBeUsedInDm and requiresPermissions instead')
  final bool defaultPermissions;

  /// The guild that the slash Command is registered in. This can be null if its a global command.
  Snowflake? guild;

  /// The arguments that the command takes
  List<CommandOptionBuilder> options;

  /// Permission overrides for the command
  @Deprecated('Use canBeUsedInDm and requiresPermissions instead')
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
  /// The integer to use for a permission can be obtained by using [PermissionsConstants]. While the bitwise OR operator is used to combine permissions, members
  /// will require *all* of the permissions to execute the command.
  // TODO: rename to `permissions` once the current `permissions` is removed.
  final int requiredPermissions;

  /// A slash command, can only be instantiated through a method on [Interactions]
  SlashCommandBuilder(
    this.name,
    this.description,
    this.options, {
    this.canBeUsedInDm = true,
    this.requiredPermissions = 0, // 0 = no permissions required
    this.guild,
    this.type = SlashCommandType.chat,
    this.defaultPermissions = true,
    this.permissions,
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
        "default_member_permissions": requiredPermissions.toString(),
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
