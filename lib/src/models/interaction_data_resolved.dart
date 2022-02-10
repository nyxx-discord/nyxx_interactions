import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/attachment.dart';

abstract class IPartialChannel implements SnowflakeEntity {
  /// Channel name
  String get name;

  /// Type of channel
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
  late final ChannelType type;

  /// Permissions of user in channel
  @override
  late final IPermissions permissions;

  /// Creates na instance of [PartialChannel]
  PartialChannel(RawApiMap raw) : super(Snowflake(raw["id"])) {
    name = raw["name"] as String;
    type = ChannelType.from(raw["type"] as int);
    permissions = Permissions(int.parse(raw["permissions"].toString()));
  }
}

abstract class IInteractionDataResolved {
  /// Resolved [User]s
  Iterable<IUser> get users;

  /// Resolved [Member]s
  Iterable<IMember> get members;

  /// Resolved [Role]s
  Iterable<IRole> get roles;

  /// Resolved [PartialChannel]s
  Iterable<IPartialChannel> get channels;

  /// Resolved [IMessage] objects
  Iterable<IMessage> get messages;

  /// Resolved [IAttachment] objects
  Iterable<IAttachment> get attachments;
}

/// Additional data for slash command
class InteractionDataResolved implements IInteractionDataResolved {
  @override
  late final Iterable<IUser> users;

  @override
  late final Iterable<IMember> members;

  @override
  late final Iterable<IRole> roles;

  @override
  late final Iterable<IPartialChannel> channels;

  @override
  late final Iterable<IMessage> messages;

  @override
  late final Iterable<IAttachment> attachments;

  /// Creates na instance of [InteractionDataResolved]
  InteractionDataResolved(RawApiMap raw, Snowflake? guildId, INyxx client) {
    users = [
      if (raw["users"] != null)
        for (final rawUserEntry in (raw["users"] as RawApiMap).entries) User(client, rawUserEntry.value as RawApiMap)
    ];

    members = [
      if (raw["members"] != null)
        for (final rawMemberEntry in (raw["members"] as RawApiMap).entries)
          Member(
              client,
              {
                ...rawMemberEntry.value as RawApiMap,
                "user": {"id": rawMemberEntry.key}
              },
              guildId!)
    ];

    roles = [
      if (raw["roles"] != null)
        for (final rawRoleEntry in (raw["roles"] as RawApiMap).entries) Role(client, rawRoleEntry.value as RawApiMap, guildId!)
    ];

    channels = [
      if (raw["channels"] != null)
        for (final rawChannelEntry in (raw["channels"] as RawApiMap).entries) PartialChannel(rawChannelEntry.value as RawApiMap)
    ];

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
