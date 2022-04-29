import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/src/interactions.dart';

class SlashCommandPermissionType extends IEnum<int> {
  static const SlashCommandPermissionType role = SlashCommandPermissionType._(1);
  static const SlashCommandPermissionType user = SlashCommandPermissionType._(2);
  static const SlashCommandPermissionType channel = SlashCommandPermissionType._(3);

  const SlashCommandPermissionType._(int value) : super(value);
}

abstract class ISlashCommandPermissionOverride {
  SlashCommandPermissionType get type;
  Snowflake get id;
  bool get allowed;
  bool get isEveryone;
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

abstract class ISlashCommandPermissionOverrides implements SnowflakeEntity {
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
