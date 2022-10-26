import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/components/message_component.dart';

import 'package:nyxx_interactions/src/models/interaction_option.dart';
import 'package:nyxx_interactions/src/models/interaction_data_resolved.dart';

abstract class IInteraction implements SnowflakeEntity {
  /// Reference to bot instance.
  INyxx get client;

  /// The type of the interaction received.
  int get type;

  /// The guild the command was sent in.
  Cacheable<Snowflake, IGuild>? get guild;

  /// The channel the command was sent in.
  Cacheable<Snowflake, ITextChannel> get channel;

  /// The member who sent the interaction
  IMember? get memberAuthor;

  /// Permission of member who sent the interaction. Will be set if [memberAuthor]
  /// is not null
  IPermissions? get memberAuthorPermissions;

  /// The user who sent the interaction.
  IUser? get userAuthor;

  /// Token to send requests
  String get token;

  /// Version of interactions api
  int get version;

  /// The selected language of the invoking user
  String? get locale;

  /// The preferred locale of the guild this interaction was created in, if any.
  String? get guildLocale;
}

/// The Interaction data. e.g channel, guild and member
class Interaction extends SnowflakeEntity implements IInteraction {
  /// Reference to bot instance.
  @override
  final INyxx client;

  /// The type of the interaction received.
  @override
  late final int type;

  /// The guild the command was sent in.
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// The channel the command was sent in.
  @override
  late final Cacheable<Snowflake, ITextChannel> channel;

  /// The member who sent the interaction
  @override
  late final IMember? memberAuthor;

  /// Permission of member who sent the interaction. Will be set if [memberAuthor]
  /// is not null
  @override
  late final IPermissions? memberAuthorPermissions;

  /// The user who sent the interaction.
  @override
  late final IUser? userAuthor;

  /// Token to send requests
  @override
  late final String token;

  /// Version of interactions api
  @override
  late final int version;

  @override
  late final String? locale;

  @override
  late final String? guildLocale;

  /// Creates na instance of [Interaction]
  Interaction(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    type = raw["type"] as int;

    if (raw["guild_id"] != null) {
      guild = GuildCacheable(
        client,
        Snowflake(raw["guild_id"]),
      );
    } else {
      guild = null;
    }

    channel = CacheableTextChannel(
      client,
      Snowflake(raw["channel_id"]),
    );

    if (raw["member"] != null) {
      memberAuthor = Member(client, raw["member"] as RawApiMap, Snowflake(raw["guild_id"]));
      memberAuthorPermissions = Permissions(int.parse(raw["member"]["permissions"] as String));
    } else {
      memberAuthor = null;
      memberAuthorPermissions = null;
    }

    if (raw["user"] != null) {
      userAuthor = User(client, raw["user"] as RawApiMap);
    } else if (raw["member"]["user"] != null) {
      userAuthor = User(client, raw["member"]["user"] as RawApiMap);
    } else {
      userAuthor = null;
    }

    token = raw["token"] as String;
    version = raw["version"] as int;
    locale = raw['locale'] as String?;

    guildLocale = raw['guild_locale'] as String?;
  }
}

abstract class IModalInteraction implements IInteraction {
  /// Custom id of modal
  String get customId;

  /// List of components submitted
  List<List<IMessageComponent>> get components;
}

class ModalInteraction extends Interaction implements IModalInteraction {
  @override
  late final List<List<IMessageComponent>> components;

  @override
  late final String customId;

  ModalInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    customId = raw['data']['custom_id'] as String;

    if (raw['data']["components"] != null) {
      components = [
        for (final rawRow in raw['data']["components"])
          [for (final componentRaw in rawRow["components"]) MessageComponent.deserialize(componentRaw as RawApiMap)]
      ];
    } else {
      components = [];
    }
  }
}

abstract class ISlashCommandInteraction implements IInteraction {
  /// Name of interaction
  String get name;

  /// Args of the interaction
  Iterable<IInteractionOption> get options;

  /// Id of command
  late final Snowflake commandId;

  /// Additional data for command
  late final IInteractionSlashDataResolved? resolved;

  /// Id of the target entity (only present in message or user interactions)
  Snowflake? get targetId;
}

/// Interaction for slash command
class SlashCommandInteraction extends Interaction implements ISlashCommandInteraction {
  /// Name of interaction
  @override
  late final String name;

  /// Args of the interaction
  @override
  late final Iterable<IInteractionOption> options;

  /// Id of command
  @override
  late final Snowflake commandId;

  /// Additional data for command
  @override
  late final IInteractionSlashDataResolved? resolved;

  @override
  late final Snowflake? targetId;

  /// Creates na instance of [SlashCommandInteraction]
  SlashCommandInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    name = raw["data"]["name"] as String;
    options = [
      if (raw["data"]["options"] != null)
        for (final option in raw["data"]["options"] as List<dynamic>) InteractionOption(option as RawApiMap)
    ];
    commandId = Snowflake(raw["data"]["id"]);

    resolved = raw["data"]["resolved"] != null ? InteractionSlashDataResolved(raw["data"]["resolved"] as RawApiMap, guild?.id, client) : null;

    targetId = raw["data"]["target_id"] != null ? Snowflake(raw["data"]["target_id"]) : null;
  }

  /// Allows to fetch argument value by argument name
  dynamic getArg(String name) {
    try {
      return options.firstWhere((element) => element.name == name).value;
    } on Error {
      return null;
    }
  }
}

abstract class IComponentInteraction implements IInteraction {
  /// Custom id of component interaction
  String get customId;

  /// The message that the button was pressed on.
  IMessage? get message;
}

/// Interaction for button, dropdown, etc.
abstract class ComponentInteraction extends Interaction implements IComponentInteraction {
  /// Custom id of component interaction
  @override
  late final String customId;

  /// The message that the button was pressed on.
  @override
  late final IMessage? message;

  /// Creates na instance of [ComponentInteraction]
  ComponentInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    customId = raw["data"]["custom_id"] as String;

    // Discord doesn't include guild's id in the message object even if its a guild message but is included in the data so its been added to the object so that guild message can be used if the interaction is from a guild.
    message = Message(client, {...raw["message"], if (guild != null) "guild_id": guild!.id.toString()});
  }
}

abstract class IButtonInteraction implements IComponentInteraction {}

/// Interaction invoked when button is pressed
class ButtonInteraction extends ComponentInteraction implements IButtonInteraction {
  ButtonInteraction(INyxx client, Map<String, dynamic> raw) : super(client, raw);
}

abstract class IMultiselectInteraction implements IComponentInteraction {
  /// Values selected by the user
  List<String> get values;
}

/// Interaction when multi select is triggered
class MultiselectInteraction extends ComponentInteraction implements IMultiselectInteraction {
  /// Values selected by the user
  @override
  late final List<String> values;

  /// Creates na instance of [MultiselectInteraction]
  MultiselectInteraction(INyxx client, Map<String, dynamic> raw) : super(client, raw) {
    values = (raw["data"]["values"] as List<dynamic>).cast<String>();
  }
}

abstract class IResolvedSelectInteraction implements IComponentInteraction {
  /// Iterable of all ids selectionned.
  Iterable<Snowflake> get values;
}

abstract class ResolvedSelectInteraction extends ComponentInteraction implements IResolvedSelectInteraction {
  @override
  late final Iterable<Snowflake> values;

  ResolvedSelectInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    values = (raw['data']['values'] as List).cast<String>().map(Snowflake.new);
  }
}

abstract class IUserSelectInteraction implements IResolvedSelectInteraction {
  /// The users that were selected.
  Iterable<IUser> get users;

  /// The [IMember]s attached to the [users].
  Iterable<IMember> get members;
}

class UserSelectInteraction extends ResolvedSelectInteraction implements IUserSelectInteraction {
  @override
  late final Iterable<IUser> users;
  @override
  late final Iterable<IMember> members;

  UserSelectInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    final resolved = InteractionDataResolved(raw['data']['resolved'] as RawApiMap, guild?.id, client);
    users = resolved.users;
    members = resolved.members;
  }
}

abstract class IRoleSelectInteraction implements IResolvedSelectInteraction {
  /// The roles that were selected.
  Iterable<IRole> get roles;
}

class RoleSelectInteraction extends ResolvedSelectInteraction implements IRoleSelectInteraction {
  @override
  late final Iterable<IRole> roles;

  RoleSelectInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    final resolved = InteractionDataResolved(raw['data']['resolved'] as RawApiMap, guild?.id, client);
    roles = resolved.roles;
  }
}

abstract class IMentionableSelectInteraction implements IResolvedSelectInteraction {
  /// The mentionables that were selected.
  Iterable<Mentionable> get mentionables;
}

class MentionableSelectInteraction extends ResolvedSelectInteraction implements IMentionableSelectInteraction {
  @override
  late final Iterable<Mentionable> mentionables;

  MentionableSelectInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    final resolved = InteractionDataResolved(raw['data']['resolved'] as RawApiMap, guild?.id, client);
    mentionables = [
      ...{...resolved.users, ...resolved.members},
      ...resolved.roles
    ];
  }
}

abstract class IChannelSelectInteraction implements IResolvedSelectInteraction {
  /// The channels that were selected.
  Iterable<IPartialChannel> get channels;
}

class ChannelSelectInteraction extends ResolvedSelectInteraction implements IChannelSelectInteraction {
  @override
  late final Iterable<IPartialChannel> channels;

  ChannelSelectInteraction(INyxx client, RawApiMap raw) : super(client, raw) {
    final resolved = InteractionDataResolved(raw['data']['resolved'] as RawApiMap, guild?.id, client);
    channels = resolved.channels;
  }
}
