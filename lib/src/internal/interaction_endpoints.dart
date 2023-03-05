import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_interactions/src/interactions.dart';

import 'package:nyxx_interactions/src/models/slash_command.dart';
import 'package:nyxx_interactions/src/models/slash_command_permission.dart';

abstract class IInteractionsEndpoints {
  /// Sends followup for interaction with given [token]. IMessage will be created with [builder]
  Future<IMessage> sendFollowup(String token, Snowflake applicationId, MessageBuilder builder, {bool hidden = false});

  /// Fetches followup message from API
  Future<IMessage> fetchFollowup(String token, Snowflake applicationId, Snowflake messageId);

  /// Acknowledges interaction that response can be sent within next 15 mins.
  /// Response will be ephemeral if [hidden] is set to true. To response to different interaction types
  /// (slash command, button...) [opCode] is used.
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode);

  /// Respond to interaction by editing original response. Used when interaction was acked before.
  Future<void> respondEditOriginal(String token, Snowflake applicationId, MessageBuilder builder, bool hidden);

  /// Respond to interaction by creating response. Used when interaction wasn't acked before.
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode);

  /// Respond to interaction with modal
  Future<void> respondModal(String token, String interactionId, ModalBuilder builder);

  /// Fetch original interaction response.
  Future<IMessage> fetchOriginalResponse(String token, Snowflake applicationId, String interactionId);

  /// Edits original interaction response using [builder]
  Future<IMessage> editOriginalResponse(String token, Snowflake applicationId, MessageBuilder builder);

  /// Deletes original interaction response
  Future<void> deleteOriginalResponse(String token, Snowflake applicationId, String interactionId);

  /// Deletes followup IMessage with given id
  Future<void> deleteFollowup(String token, Snowflake applicationId, Snowflake messageId);

  /// Edits followup IMessage with given [messageId]
  Future<IMessage> editFollowup(String token, Snowflake applicationId, Snowflake messageId, MessageBuilder builder);

  /// Fetches global commands of application
  Stream<ISlashCommand> fetchGlobalCommands(Snowflake applicationId, {bool withLocales = true});

  /// Fetches global command with given [commandId]
  Future<ISlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId);

  /// Edits global command with given [commandId] using [builder]
  Future<ISlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder);

  /// Deletes global command with given [commandId]
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId);

  /// Bulk overrides global commands. To delete all apps global commands pass empty list to [builders]
  Stream<ISlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders);

  /// Fetches all commands for given [guildId]
  Stream<ISlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId, {bool withLocales = true});

  /// Fetches single guild command with given [commandId]
  Future<ISlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);

  /// Edits single guild command with given [commandId]
  Future<ISlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder);

  /// Deletes guild command with given commandId]
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);

  /// Bulk overrides global commands. To delete all apps global commands pass empty list to [builders]
  Stream<ISlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Overrides permissions for guild commands
  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead.")
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Responds to autocomplete interaction
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders);

  /// Fetch the command permission overrides for a command in a guild.
  Future<ISlashCommandPermissionOverrides> fetchCommandOverrides(Snowflake commandId, Snowflake guildId);

  /// Fetch the permission overrides for all commands in a guild. The global overrides for that guild have an ID which is equal to the application ID.
  Future<Iterable<ISlashCommandPermissionOverrides>> fetchPermissionOverrides(Snowflake guildId);
}

extension InteractionRouteParts on IHttpRoute {
  /// Adds the [`interactions`](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response) part to this
  /// [IHttpRoute].
  void interactions({String? id, String? token}) => add(HttpRoutePart('interactions', [
        if (id != null) HttpRouteParam(id),
        if (token != null) HttpRouteParam(token),
      ]));

  /// Adds the [`callback`](https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response) part to this [IHttpRoute].
  void callback() => add(HttpRoutePart('callback'));

  /// Adds the [`commands`](https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands) part to this [IHttpRoute].
  void commands({String? id}) => add(HttpRoutePart('commands', [if (id != null) HttpRouteParam(id)]));
}

class InteractionsEndpoints implements IInteractionsEndpoints {
  final INyxx _client;
  final Interactions _interactions;

  final Logger _logger = Logger('Interactions');

  InteractionsEndpoints(this._client, this._interactions);

  // TODO: Make this public in nyxx to avoid duplication?
  Future<IHttpResponseSuccess> executeSafe(
    IHttpRoute route,
    String method, {
    dynamic body,
    bool auth = false,
    List<AttachmentBuilder> files = const [],
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _client.httpEndpoints.sendRawRequest(
      route,
      method,
      body: body,
      auth: auth,
      files: files,
      queryParams: queryParams,
    );

    if (response is! IHttpResponseSuccess) {
      return Future.error(response, StackTrace.current);
    }

    return response;
  }

  @override
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode) => executeSafe(
        IHttpRoute()
          ..interactions(id: interactionId, token: token)
          ..callback(),
        "POST",
        body: {
          "type": opCode,
          "data": {
            if (hidden) "flags": 1 << 6,
          }
        },
      );

  @override
  Future<void> deleteFollowup(String token, Snowflake applicationId, Snowflake messageId) => executeSafe(
        IHttpRoute()
          ..webhooks(id: applicationId.id.toString(), token: token)
          ..messages(id: messageId.id.toString()),
        "DELETE",
      );

  @override
  Future<void> deleteOriginalResponse(String token, Snowflake applicationId, String interactionId) => executeSafe(
        IHttpRoute()
          ..webhooks(id: applicationId.id.toString(), token: token)
          ..messages(id: '@original'),
        "DELETE",
      );

  @override
  Future<IMessage> editFollowup(String token, Snowflake applicationId, Snowflake messageId, MessageBuilder builder) async {
    final body = builder.build(_client.options.allowedMentions);

    final response = await executeSafe(
      IHttpRoute()
        ..webhooks(id: applicationId.id.toString(), token: token)
        ..messages(id: messageId.id.toString()),
      "PATCH",
      body: body,
    );

    return Message(_client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> editOriginalResponse(String token, Snowflake applicationId, MessageBuilder builder) async {
    final response = await executeSafe(
      IHttpRoute()
        ..webhooks(id: applicationId.id.toString(), token: token)
        ..messages(id: '@original'),
      "PATCH",
      body: builder.build(_client.options.allowedMentions),
    );

    return Message(_client, response.jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> fetchOriginalResponse(String token, Snowflake applicationId, String interactionId) async {
    final response = await executeSafe(
      IHttpRoute()
        ..webhooks(id: applicationId.id.toString(), token: token)
        ..messages(id: '@original'),
      "GET",
    );

    return Message(_client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> respondEditOriginal(String token, Snowflake applicationId, MessageBuilder builder, bool hidden) => executeSafe(
        IHttpRoute()
          ..webhooks(id: applicationId.id.toString(), token: token)
          ..messages(id: '@original'),
        "PATCH",
        body: {if (hidden) "flags": 1 << 6, ...builder.build(_client.options.allowedMentions)},
        files: builder.files ?? [],
      );

  @override
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode) => executeSafe(
        IHttpRoute()
          ..interactions(id: interactionId, token: token)
          ..callback(),
        "POST",
        body: {
          "type": respondOpCode,
          "data": {
            if (hidden) "flags": 1 << 6,
            ...builder.build(_client.options.allowedMentions),
          },
        },
        files: builder.files ?? [],
      );

  @override
  Future<IMessage> sendFollowup(String token, Snowflake applicationId, MessageBuilder builder, {bool hidden = false}) async {
    final response = await executeSafe(
      IHttpRoute()..webhooks(id: applicationId.id.toString(), token: token),
      "POST",
      body: {
        ...builder.build(_client.options.allowedMentions),
        if (hidden) 'flags': 1 << 6,
      },
      files: builder.files ?? [],
    );

    return Message(_client, response.jsonBody as RawApiMap);
  }

  @override
  Stream<ISlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..commands(),
      "PUT",
      body: [for (final builder in builders) builder.build()],
      auth: true,
    );

    for (final rawRes in response.jsonBody as List<dynamic>) {
      yield SlashCommand(rawRes as RawApiMap, _interactions);
    }
  }

  @override
  Stream<ISlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands(),
      "PUT",
      body: [for (final builder in builders) builder.build()],
      auth: true,
    );

    for (final rawRes in response.jsonBody as List<dynamic>) {
      yield SlashCommand(rawRes as RawApiMap, _interactions);
    }
  }

  @override
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId) => executeSafe(
        IHttpRoute()
          ..applications(id: applicationId.id.toString())
          ..commands(id: commandId.id.toString()),
        "DELETE",
        auth: true,
      );

  @override
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId) => executeSafe(
        IHttpRoute()
          ..applications(id: applicationId.id.toString())
          ..guilds(id: guildId.id.toString())
          ..commands(id: commandId.id.toString()),
        "DELETE",
        auth: true,
      );

  @override
  Future<ISlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder) async {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..commands(id: commandId.id.toString()),
      "PATCH",
      body: builder.build(),
      auth: true,
    );

    return SlashCommand(response.jsonBody as RawApiMap, _interactions);
  }

  @override
  Future<ISlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder) async {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands(id: commandId.id.toString()),
      "GET",
      body: builder.build(),
      auth: true,
    );

    return SlashCommand(response.jsonBody as RawApiMap, _interactions);
  }

  @override
  Future<ISlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId) async {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..commands(id: commandId.id.toString()),
      "GET",
      auth: true,
    );

    return SlashCommand(response.jsonBody as RawApiMap, _interactions);
  }

  @override
  Stream<ISlashCommand> fetchGlobalCommands(Snowflake applicationId, {bool withLocales = true}) async* {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..commands(),
      "GET",
      auth: true,
      queryParams: withLocales ? {'with_localizations': withLocales.toString()} : {},
    );

    for (final commandSlash in response.jsonBody as List<dynamic>) {
      yield SlashCommand(commandSlash as RawApiMap, _interactions);
    }
  }

  @override
  Future<ISlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId) async {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands(id: commandId.id.toString()),
      "GET",
      auth: true,
    );

    return SlashCommand(response.jsonBody as RawApiMap, _interactions);
  }

  @override
  Stream<ISlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId, {bool withLocales = true}) async* {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands(),
      "GET",
      auth: true,
      queryParams: withLocales ? {'with_localizations': withLocales.toString()} : {},
    );

    for (final commandSlash in response.jsonBody as List<dynamic>) {
      yield SlashCommand(commandSlash as RawApiMap, _interactions);
    }
  }

  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead.")
  Future<void> bulkOverrideGlobalCommandsPermissions(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async {
    final globalBody = builders
        .where((builder) => builder.permissions != null && builder.permissions!.isNotEmpty)
        .map((builder) => {
              "id": builder.id.toString(),
              "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
            })
        .toList();

    await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..commands()
        ..permissions(),
      "PUT",
      body: globalBody,
      auth: true,
    );
  }

  @override
  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead.")
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async {
    final guildBody = builders
        .where((b) => b.permissions != null && b.permissions!.isNotEmpty)
        .map((builder) => {
              "id": builder.id.toString(),
              "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
            })
        .toList();

    await executeSafe(
      IHttpRoute()
        ..applications(id: applicationId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands()
        ..permissions(),
      "PUT",
      body: guildBody,
      auth: true,
    );
  }

  @override
  Future<IMessage> fetchFollowup(String token, Snowflake applicationId, Snowflake messageId) async {
    final response = await executeSafe(
      IHttpRoute()
        ..webhooks(id: applicationId.id.toString(), token: token)
        ..messages(id: messageId.id.toString()),
      "GET",
      auth: true,
    );

    return Message(_client, response.jsonBody as RawApiMap);
  }

  @override
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders) async {
    final result = await executeSafe(
      IHttpRoute()
        ..interactions(id: interactionId.id.toString(), token: token)
        ..callback(),
      "POST",
      body: {
        "type": 8,
        "data": {
          "choices": [for (final builder in builders) builder.build()]
        }
      },
    );

    if (result is IHttpResponseError) {
      return Future.error(result);
    }
  }

  @override
  Future<void> respondModal(String token, String interactionId, ModalBuilder builder) => executeSafe(
        IHttpRoute()
          ..interactions(id: interactionId, token: token)
          ..callback(),
        "POST",
        body: {
          "type": 9,
          "data": {...builder.build()},
        },
      );

  @override
  Future<SlashCommandPermissionOverrides> fetchCommandOverrides(Snowflake commandId, Snowflake guildId) async {
    try {
      final response = await executeSafe(
        IHttpRoute()
          ..applications(id: _client.appId.id.toString())
          ..guilds(id: guildId.id.toString())
          ..commands(id: commandId.id.toString())
          ..permissions(),
        "GET",
        auth: true,
      );

      return SlashCommandPermissionOverrides(response.jsonBody as Map<String, dynamic>, _client);
    } on IHttpResponseError catch (response) {
      // 10066 = Unknown application command permissions
      // Means there are no overrides for this command... why is this an error, Discord?
      if (response.errorCode == 10066) {
        _logger.finest('Got error code 10066 on permissions for command $commandId in guild $guildId, returning empty permission overrides.');
        return SlashCommandPermissionOverrides.empty(commandId, _client);
      }

      rethrow;
    }
  }

  @override
  Future<List<ISlashCommandPermissionOverrides>> fetchPermissionOverrides(Snowflake guildId) async {
    final response = await executeSafe(
      IHttpRoute()
        ..applications(id: _client.appId.id.toString())
        ..guilds(id: guildId.id.toString())
        ..commands()
        ..permissions(),
      "GET",
      auth: true,
    );

    List<SlashCommandPermissionOverrides> overrides =
        (response.jsonBody as List<dynamic>).cast<RawApiMap>().map((d) => SlashCommandPermissionOverrides(d, _client)).toList();

    for (final override in overrides) {
      _interactions.permissionOverridesCache[guildId] ??= {};
      _interactions.permissionOverridesCache[guildId]![override.id] = override;
    }

    return overrides;
  }
}
