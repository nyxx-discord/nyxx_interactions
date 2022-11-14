import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/attachment.dart';

abstract class IPartialChannel implements SnowflakeEntity, IChannel {
  /// Channel name
  String get name;

  /// Type of channel
  @Deprecated('Use "channelType" instead')
  ChannelType get type;

  /// Permissions of user in channel
  IPermissions get permissions;
}

/// Partial channel object for interactions
class PartialChannel extends SnowflakeEntity implements IPartialChannel {
  /// Channel name
  @override
  late final String name;

  /// Type of channel
  @override
  late final ChannelType channelType;

  @override
  late final ChannelType type = channelType;

  /// Permissions of user in channel
  @override
  late final IPermissions permissions;

  @override
  final INyxx client;

  /// Creates an instance of [PartialChannel]
  PartialChannel(RawApiMap raw, this.client) : super(Snowflake(raw["id"])) {
    name = raw["name"] as String;
    channelType = ChannelType.from(raw["type"] as int);
    permissions = Permissions(int.parse(raw["permissions"].toString()));
  }

  @override
  Future<void> delete() => client.httpEndpoints.deleteChannel(id);

  @override
  Future<void> dispose() async {}
}

abstract class IInteractionDataResolved {
  /// Resolved [IUser]s
  Iterable<IUser> get users;

  /// Resolved [IMember]s
  Iterable<IMember> get members;

  /// Resolved [IRole]s
  Iterable<IRole> get roles;

  /// Resolved [IPartialChannel]s
  Iterable<IPartialChannel> get channels;
}

abstract class IInteractionSlashDataResolved implements IInteractionDataResolved {
  /// Resolved [IMessage] objects
  Iterable<IMessage> get messages;

  /// Resolved [IAttachment] objects
  Iterable<IAttachment> get attachments;
}

class InteractionDataResolved implements IInteractionDataResolved {
  @override
  late final Iterable<IPartialChannel> channels;

  @override
  late final Iterable<IMember> members;

  @override
  late final Iterable<IRole> roles;

  @override
  late final Iterable<IUser> users;

  InteractionDataResolved(RawApiMap raw, Snowflake? guildId, INyxx client) {
    users = [
      if (raw["users"] != null)
        for (final rawUserEntry in (raw["users"] as RawApiMap).entries)
          if (client.cacheOptions.userCachePolicyLocation.objectConstructor)
            client.users.putIfAbsent(Snowflake(rawUserEntry.value['id']), () => User(client, rawUserEntry.value as RawApiMap))
          else
            User(client, rawUserEntry.value as RawApiMap)
    ];

    members = [];

    if (raw["members"] != null) {
      for (final rawMemberEntry in (raw["members"] as RawApiMap).entries) {
        final member = Member(
          client,
          {
            ...rawMemberEntry.value as RawApiMap,
            "user": {"id": rawMemberEntry.key}
          },
          guildId!,
        );
        if (client.cacheOptions.memberCachePolicyLocation.objectConstructor && client.cacheOptions.memberCachePolicy.canCache(member)) {
          client.guilds[guildId]?.members.putIfAbsent(member.id, () => member);
          (members as List<IMember>).add(member);
        } else {
          (members as List<IMember>).add(member);
        }
      }
    }

    roles = [];

    if (raw["roles"] != null) {
      for (final rawRoleEntry in (raw["roles"] as RawApiMap).entries) {
        final role = Role(client, rawRoleEntry.value as RawApiMap, guildId!);

        client.guilds[guildId]?.roles.putIfAbsent(role.id, () => role);

        (roles as List<IRole>).add(role);
      }
    }

    channels = [];

    if (raw["channels"] != null) {
      for (final rawChannelEntry in (raw["channels"] as RawApiMap).entries) {
        final channel = PartialChannel(rawChannelEntry.value as RawApiMap, client);

        if (client.cacheOptions.channelCachePolicyLocation.objectConstructor && client.cacheOptions.channelCachePolicy.canCache(channel)) {
          client.channels.putIfAbsent(channel.id, () => channel);
          (channels as List<IPartialChannel>).add(channel);
        } else {
          (channels as List<IPartialChannel>).add(channel);
        }
      }
    }
  }
}

/// Additional data for slash command
class InteractionSlashDataResolved extends InteractionDataResolved implements IInteractionSlashDataResolved {
  @override
  late final Iterable<IMessage> messages;

  @override
  late final Iterable<IAttachment> attachments;

  /// Creates na instance of [InteractionDataResolved]
  InteractionSlashDataResolved(RawApiMap raw, Snowflake? guildId, INyxx client) : super(raw, guildId, client) {
    messages = [
      if (raw['messages'] != null)
        for (final rawMessageEntry in (raw['messages'] as RawApiMap).entries) Message(client, rawMessageEntry.value as RawApiMap)
    ];

    attachments = [
      if (raw['attachments'] != null)
        for (final rawAttachmentEntry in (raw['attachments'] as RawApiMap).entries) Attachment(rawAttachmentEntry.value as RawApiMap)
    ];
  }
}
