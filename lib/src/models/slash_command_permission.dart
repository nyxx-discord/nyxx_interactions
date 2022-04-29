import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/src/interactions.dart';

/// The type of entiity that a command permission override is targeting.
class SlashCommandPermissionType extends IEnum<int> {
  /// The permission override applies to a role.
  static const SlashCommandPermissionType role = SlashCommandPermissionType._(1);

  /// The permission override applies to a user.
  static const SlashCommandPermissionType user = SlashCommandPermissionType._(2);

  /// The permission override applies to a channel.
  static const SlashCommandPermissionType channel = SlashCommandPermissionType._(3);

  const SlashCommandPermissionType._(int value) : super(value);
}

/// A single permission override for a command.
abstract class ISlashCommandPermissionOverride {
  /// The type of this override.
  SlashCommandPermissionType get type;

  /// The ID of the entity targeted by this override.
  Snowflake get id;

  /// Whether this override allows or denies the command permission.
  bool get allowed;

  /// Whether this override represents all users in a guild.
  bool get isEveryone;

  /// Whether this override represents all channels in a guild.
  bool get isAllChannels;
}

class SlashCommandPermissionOverride implements ISlashCommandPermissionOverride {
  @override
  late final SlashCommandPermissionType type;
  @override
  late final Snowflake id;
  @override
  late final bool allowed;
  @override
  late final bool isEveryone;
  @override
  late final bool isAllChannels;

  SlashCommandPermissionOverride(RawApiMap raw, Snowflake guildId, INyxx client) {
    type = SlashCommandPermissionType._(raw['type'] as int);
    id = Snowflake(raw['id'] as String);
    allowed = raw['permission'] as bool;

    isEveryone = id == guildId;
    isAllChannels = id == guildId.id - 1;
  }
}

/// A collection of permission overrides attached to a slash command.
abstract class ISlashCommandPermissionOverrides implements SnowflakeEntity {
  /// The permissions attached to the command.
  List<SlashCommandPermissionOverride> get permissionOverrides;
}

class SlashCommandPermissionOverrides extends SnowflakeEntity implements ISlashCommandPermissionOverrides {
  @override
  late final List<SlashCommandPermissionOverride> permissionOverrides;

  SlashCommandPermissionOverrides(RawApiMap raw, INyxx client) : super(Snowflake(raw['id'])) {
    permissionOverrides = [
      for (final override in (raw['permissions'] as List<dynamic>).cast<Map<String, dynamic>>())
        SlashCommandPermissionOverride(override, Snowflake(raw["guild_id"]), client),
    ];
  }
}

class SlashCommandPermissionOverridesCacheable extends Cacheable<Snowflake, SlashCommandPermissionOverrides> {
  final Snowflake guildId;
  final Interactions interactions;

  SlashCommandPermissionOverridesCacheable(Snowflake id, this.guildId, this.interactions) : super(interactions.client, id);

  @override
  Future<SlashCommandPermissionOverrides> download() async {
    SlashCommandPermissionOverrides fetchedOverrides =
        await interactions.interactionsEndpoints.fetchCommandOverrides(id, guildId) as SlashCommandPermissionOverrides;

    interactions.permissionOverridesCache[guildId] ??= {};
    interactions.permissionOverridesCache[guildId]![id] = fetchedOverrides;

    return fetchedOverrides;
  }

  @override
  SlashCommandPermissionOverrides? getFromCache() => interactions.permissionOverridesCache[guildId]?[id];
}
