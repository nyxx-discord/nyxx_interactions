import 'package:nyxx/nyxx.dart';
// ignore: implementation_imports
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/slash_command_permission.dart';

abstract class ISlashCommand implements SnowflakeEntity, Mentionable {
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
  @Deprecated('Use canBeUsedInDm and requiredPermissions instead')
  bool get defaultPermissions;

  /// Whether this slash command can be used in a DM channel with the bot.
  bool get canBeUsedInDm;

  /// A set of permissions required by users in guilds to execute this command.
  ///
  /// The integer to use for a permission can be obtained by using [PermissionsConstants]. If a member has any of the permissions combined with the bitwise OR
  /// operator, they will be allowed to execute the command.
  int get requiredPermissions;

  /// If this command is a guild command, the permission overrides attached to this command, `null` otherwise.
  Cacheable<Snowflake, ISlashCommandPermissionOverrides>? get permissionOverrides;

  /// The localized names of the command.
  Map<Locale, String>? get localizationsName;

  /// The localized descriptions of the command.
  Map<Locale, String>? get localizationsDescription;

  /// Get the permission overrides for this command in a specific guild.
  Cacheable<Snowflake, ISlashCommandPermissionOverrides> getPermissionOverridesInGuild(Snowflake guildId);
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
  @Deprecated('Use canBeUsedInDm and requiredPermissions instead')
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
  late final Map<Locale, String>? localizationsName;

  @override
  late final Map<Locale, String>? localizationsDescription;

  @override
  late final Cacheable<Snowflake, ISlashCommandPermissionOverrides>? permissionOverrides;

  final Interactions _interactions;

  @override
  String get mention => '</$path:$id>';

  String path = '';

  /// Creates an instance of [SlashCommand]
  SlashCommand(RawApiMap raw, this._interactions) : super(Snowflake(raw["id"])) {
    applicationId = Snowflake(raw["application_id"]);
    name = raw["name"] as String;
    description = raw["description"] as String;
    type = SlashCommandType(raw["type"] as int? ?? 1);
    guild = raw["guild_id"] != null ? GuildCacheable(_interactions.client, Snowflake(raw["guild_id"])) : null;
    canBeUsedInDm = raw["dm_permission"] as bool? ?? true;
    requiredPermissions = int.parse(raw["default_member_permissions"] as String? ?? "0");
    localizationsName = (raw['name_localizations'] as RawApiMap?)?.map((key, value) => MapEntry(Locale.deserialize(key), value.toString()));
    localizationsDescription = (raw['description_localizations'] as RawApiMap?)?.map((key, value) => MapEntry(Locale.deserialize(key), value.toString()));

    if (guild != null) {
      permissionOverrides = SlashCommandPermissionOverridesCacheable(id, guild!.id, _interactions);
    }

    defaultPermissions = raw["default_permission"] as bool? ?? true;

    path = name;

    options = [
      if (raw["options"] != null)
        for (final optionRaw in raw["options"]) CommandOption(optionRaw as RawApiMap, this, path)
    ];
  }

  @override
  Cacheable<Snowflake, ISlashCommandPermissionOverrides> getPermissionOverridesInGuild(Snowflake guildId) =>
      SlashCommandPermissionOverridesCacheable(id, guildId, _interactions);
}
