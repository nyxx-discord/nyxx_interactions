import 'package:nyxx/nyxx.dart';
// ignore: implementation_imports
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/slash_command_permission.dart';

abstract class ISlashCommand implements SnowflakeEntity {
  /// Unique id of the parent application
  Snowflake get applicationId;

  /// Command name to be shown to the user in the Slash Command UI
  String get name;

  /// Command description shown to the user in the Slash Command UI
  String get description;

  /// The arguments that the command takes
  List<ICommandOption> get options;

  /// The type of command
  SlashCommandType get type;

  /// Guild id of the command, if not global
  Cacheable<Snowflake, IGuild>? get guild;

  /// Whether the command is enabled by default when the app is added to a guild
  @Deprecated('Use canBeUsedInDm and requiresPermissions instead')
  bool get defaultPermissions;

  /// Whether this slash command can be used in a DM channel with the bot.
  bool get canBeUsedInDm;

  /// A set of permissions required by users in guilds to execute this command.
  ///
  /// The integer to use for a permission can be obtained by using [PermissionsConstants]. If a member has any of the permissions combined with the bitwise OR
  /// operator, they will be allowed to execute the command.
  int get requiredPermissions;

  Cacheable<Snowflake, ISlashCommandPermissionOverrides> get permissionOverrides;
}

/// Represents slash command that is returned from Discord API.
class SlashCommand extends SnowflakeEntity implements ISlashCommand {
  /// Unique id of the parent application
  @override
  late final Snowflake applicationId;

  /// Command name to be shown to the user in the Slash Command UI
  @override
  late final String name;

  /// Command description shown to the user in the Slash Command UI
  @override
  late final String description;

  /// The arguments that the command takes
  @override
  late final List<ICommandOption> options;

  /// The type of command
  @override
  late final SlashCommandType type;

  /// Guild id of the command, if not global
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Whether the command is enabled by default when the app is added to a guild
  @override
  @Deprecated('Use canBeUsedInDm and requiresPermissions instead')
  late final bool defaultPermissions;

  /// Whether this slash command can be used in a DM channel with the bot.
  @override
  late final bool canBeUsedInDm;

  /// A set of permissions required by users in guilds to execute this command.
  ///
  /// The integer to use for a permission can be obtained by using [PermissionsConstants]. If a member has any of the permissions combined with the bitwise OR
  /// operator, they will be allowed to execute the command.
  @override
  late final int requiredPermissions;

  @override
  late final Cacheable<Snowflake, ISlashCommandPermissionOverrides> permissionOverrides;

  /// Creates an instance of [SlashCommand]
  SlashCommand(RawApiMap raw, Interactions interactions) : super(Snowflake(raw["id"])) {
    applicationId = Snowflake(raw["application_id"]);
    name = raw["name"] as String;
    description = raw["description"] as String;
    type = SlashCommandType(raw["type"] as int? ?? 1);
    guild = raw["guild_id"] != null ? GuildCacheable(interactions.client, Snowflake(raw["guild_id"])) : null;
    canBeUsedInDm = raw["dm_permission"] as bool? ?? true;
    requiredPermissions = int.parse(raw["default_member_permissions"] as String? ?? "0");
    permissionOverrides = SlashCommandPermissionOverridesCacheable(id, Snowflake(raw["guild_id"]), interactions);

    defaultPermissions = raw["default_permission"] as bool? ?? true;

    options = [
      if (raw["options"] != null)
        for (final optionRaw in raw["options"]) CommandOption(optionRaw as RawApiMap)
    ];
  }
}
