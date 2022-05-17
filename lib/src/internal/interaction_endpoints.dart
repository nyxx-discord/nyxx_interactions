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
  Future<ISlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, {bool withLocales = true});

  /// Edits single guild command with given [commandId]
  Future<ISlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder);

  /// Deletes guild command with given commandId]
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId);

  /// Bulk overrides global commands. To delete all apps global commands pass empty list to [builders]
  Stream<ISlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Overrides permissions for guild commands
  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiresPermissions instead.")
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders);

  /// Responds to autocomplete interaction
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders);

  /// Fetch the command permission overrides for a command in a guild.
  Future<ISlashCommandPermissionOverrides> fetchCommandOverrides(Snowflake commandId, Snowflake guildId);
}

class InteractionsEndpoints implements IInteractionsEndpoints {
  final INyxx _client;
  final Interactions _interactions;

  InteractionsEndpoints(this._client, this._interactions);

  @override
  Future<void> acknowledge(String token, String interactionId, bool hidden, int opCode) async {
    final url = "/interactions/$interactionId/$token/callback";
    final response = await _client.httpEndpoints.sendRawRequest(url, "POST", body: {
      "type": opCode,
      "data": {
        if (hidden) "flags": 1 << 6,
      }
    });

    if (response is IHttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> deleteFollowup(String token, Snowflake applicationId, Snowflake messageId) =>
      _client.httpEndpoints.sendRawRequest("webhooks/$applicationId/$token/messages/$messageId", "DELETE");

  @override
  Future<void> deleteOriginalResponse(String token, Snowflake applicationId, String interactionId) async {
    final url = "/webhooks/$applicationId/$token/messages/@original";
    const method = "DELETE";

    final response = await _client.httpEndpoints.sendRawRequest(url, method);
    if (response is IHttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IMessage> editFollowup(String token, Snowflake applicationId, Snowflake messageId, MessageBuilder builder) async {
    final url = "/webhooks/$applicationId/$token/messages/$messageId";
    final body = builder.build(_client.options.allowedMentions);

    final response = await _client.httpEndpoints.sendRawRequest(url, "PATCH", body: body);
    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return Message(_client, (response as IHttpResponseSucess).jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> editOriginalResponse(String token, Snowflake applicationId, MessageBuilder builder) async {
    final response = await _client.httpEndpoints
        .sendRawRequest("/webhooks/$applicationId/$token/messages/@original", "PATCH", body: builder.build(_client.options.allowedMentions));

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return Message(_client, (response as IHttpResponseSucess).jsonBody as RawApiMap);
  }

  @override
  Future<IMessage> fetchOriginalResponse(String token, Snowflake applicationId, String interactionId) async {
    final response = await _client.httpEndpoints.sendRawRequest("/webhooks/$applicationId/$token/messages/@original", "GET");

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return Message(_client, (response as IHttpResponseSucess).jsonBody as RawApiMap);
  }

  @override
  Future<void> respondEditOriginal(String token, Snowflake applicationId, MessageBuilder builder, bool hidden) async {
    final response = await _client.httpEndpoints.sendRawRequest("/webhooks/$applicationId/$token/messages/@original", "PATCH",
        body: {if (hidden) "flags": 1 << 6, ...builder.build(_client.options.allowedMentions)}, files: builder.files ?? []);

    if (response is IHttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<void> respondCreateResponse(String token, String interactionId, MessageBuilder builder, bool hidden, int respondOpCode) async {
    final response = await _client.httpEndpoints.sendRawRequest("/interactions/${interactionId.toString()}/$token/callback", "POST",
        body: {
          "type": respondOpCode,
          "data": {if (hidden) "flags": 1 << 6, ...builder.build(_client.options.allowedMentions)},
        },
        files: builder.files ?? []);

    if (response is IHttpResponseError) {
      return Future.error(response);
    }
  }

  @override
  Future<IMessage> sendFollowup(String token, Snowflake applicationId, MessageBuilder builder, {bool hidden = false}) async {
    final response = await _client.httpEndpoints.sendRawRequest("/webhooks/$applicationId/$token", "POST",
        body: {
          ...builder.build(_client.options.allowedMentions),
          if (hidden) 'flags': 1 << 6,
        },
        files: builder.files ?? []);

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return Message(_client, (response as IHttpResponseSucess).jsonBody as RawApiMap);
  }

  @override
  Stream<ISlashCommand> bulkOverrideGlobalCommands(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await _client.httpEndpoints
        .sendRawRequest("/applications/$applicationId/commands", "PUT", body: [for (final builder in builders) builder.build()], auth: true);

    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawRes in (response as IHttpResponseSucess).jsonBody as List<dynamic>) {
      yield SlashCommand(rawRes as RawApiMap, _interactions);
    }
  }

  @override
  Stream<ISlashCommand> bulkOverrideGuildCommands(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async* {
    final response = await _client.httpEndpoints
        .sendRawRequest("/applications/$applicationId/guilds/$guildId/commands", "PUT", body: [for (final builder in builders) builder.build()], auth: true);
    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final rawRes in (response as IHttpResponseSucess).jsonBody as List<dynamic>) {
      yield SlashCommand(rawRes as RawApiMap, _interactions);
    }
  }

  @override
  Future<void> deleteGlobalCommand(Snowflake applicationId, Snowflake commandId) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/commands/$commandId", "DELETE", auth: true);

    if (response is IHttpResponseSucess) {
      return Future.error(response);
    }
  }

  @override
  Future<void> deleteGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/guilds/$guildId/commands/$commandId", "DELETE", auth: true);

    if (response is IHttpResponseSucess) {
      return Future.error(response);
    }
  }

  @override
  Future<ISlashCommand> editGlobalCommand(Snowflake applicationId, Snowflake commandId, SlashCommandBuilder builder) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/commands/$commandId", "PATCH", body: builder.build(), auth: true);

    if (response is IHttpResponseSucess) {
      return Future.error(response);
    }

    return SlashCommand((response as IHttpResponseSucess).jsonBody as RawApiMap, _interactions);
  }

  @override
  Future<ISlashCommand> editGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, SlashCommandBuilder builder) async {
    final response = await _client.httpEndpoints
        .sendRawRequest("/applications/$applicationId/guilds/$guildId/commands/$commandId", "GET", body: builder.build(), auth: true);

    if (response is IHttpResponseSucess) {
      return Future.error(response);
    }

    return SlashCommand((response as IHttpResponseSucess).jsonBody as RawApiMap, _interactions);
  }

  @override
  Future<ISlashCommand> fetchGlobalCommand(Snowflake applicationId, Snowflake commandId) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/commands/$commandId", "GET", auth: true);

    if (response is IHttpResponseSucess) {
      return Future.error(response);
    }

    return SlashCommand((response as IHttpResponseSucess).jsonBody as RawApiMap, _interactions);
  }

  @override
  Stream<ISlashCommand> fetchGlobalCommands(Snowflake applicationId, {bool withLocales = true}) async* {
    final response = await _client.httpEndpoints.sendRawRequest(
      "/applications/$applicationId/commands",
      "GET",
      auth: true,
      queryParams: withLocales ? {'with_localizations': withLocales.toString()} : {},
    );

    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final commandSlash in (response as IHttpResponseSucess).jsonBody as List<dynamic>) {
      yield SlashCommand(commandSlash as RawApiMap, _interactions);
    }
  }

  @override
  Future<ISlashCommand> fetchGuildCommand(Snowflake applicationId, Snowflake commandId, Snowflake guildId, {bool withLocales = true}) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/guilds/$guildId/commands/$commandId", "GET", auth: true);

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return SlashCommand((response as IHttpResponseSucess).jsonBody as RawApiMap, _interactions);
  }

  @override
  Stream<ISlashCommand> fetchGuildCommands(Snowflake applicationId, Snowflake guildId, {bool withLocales = true}) async* {
    final response = await _client.httpEndpoints.sendRawRequest(
      "/applications/$applicationId/guilds/$guildId/commands",
      "GET",
      auth: true,
      queryParams: withLocales ? {'with_localizations': withLocales.toString()} : {},
    );

    if (response is IHttpResponseError) {
      yield* Stream.error(response);
    }

    for (final commandSlash in (response as IHttpResponseSucess).jsonBody as List<dynamic>) {
      yield SlashCommand(commandSlash as RawApiMap, _interactions);
    }
  }

  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiresPermissions instead.")
  Future<void> bulkOverrideGlobalCommandsPermissions(Snowflake applicationId, Iterable<SlashCommandBuilder> builders) async {
    final globalBody = builders
        .where((builder) => builder.permissions != null && builder.permissions!.isNotEmpty)
        .map((builder) => {
              "id": builder.id.toString(),
              "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
            })
        .toList();

    await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/commands/permissions", "PUT", body: globalBody, auth: true);
  }

  @override
  @Deprecated("This endpoint requires OAuth2 authentication, which nyxx_interactions doesn't support."
      " Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiresPermissions instead.")
  Future<void> bulkOverrideGuildCommandsPermissions(Snowflake applicationId, Snowflake guildId, Iterable<SlashCommandBuilder> builders) async {
    final guildBody = builders
        .where((b) => b.permissions != null && b.permissions!.isNotEmpty)
        .map((builder) => {
              "id": builder.id.toString(),
              "permissions": [for (final permsBuilder in builder.permissions!) permsBuilder.build()]
            })
        .toList();

    await _client.httpEndpoints.sendRawRequest("/applications/$applicationId/guilds/$guildId/commands/permissions", "PUT", body: guildBody, auth: true);
  }

  @override
  Future<IMessage> fetchFollowup(String token, Snowflake applicationId, Snowflake messageId) async {
    final result = await _client.httpEndpoints.sendRawRequest("/webhooks/$applicationId/$token/messages/${messageId.toString()}", "GET", auth: true);

    if (result is IHttpResponseError) {
      return Future.error(result);
    }

    return Message(_client, (result as IHttpResponseSucess).jsonBody as RawApiMap);
  }

  @override
  Future<void> respondToAutocomplete(Snowflake interactionId, String token, List<ArgChoiceBuilder> builders) async {
    final result = await _client.httpEndpoints.sendRawRequest("/interactions/${interactionId.toString()}/$token/callback", "POST", body: {
      "type": 8,
      "data": {
        "choices": [for (final builder in builders) builder.build()]
      }
    });

    if (result is IHttpResponseError) {
      return Future.error(result);
    }
  }

  @override
  Future<void> respondModal(String token, String interactionId, ModalBuilder builder) async {
    final response = await _client.httpEndpoints.sendRawRequest("/interactions/${interactionId.toString()}/$token/callback", "POST", body: {
      "type": 9,
      "data": {...builder.build()},
    });

    if (response is IHttpResponseError) {
      return Future.error(response);
    }
  }

  /// Fetch the command permission overrides for a command in a guild.
  @override
  Future<SlashCommandPermissionOverrides> fetchCommandOverrides(Snowflake commandId, Snowflake guildId) async {
    final response = await _client.httpEndpoints.sendRawRequest("/applications/${_client.appId}/guilds/$guildId/commands/$commandId/permissions", "GET");

    if (response is IHttpResponseError) {
      return Future.error(response);
    }

    return SlashCommandPermissionOverrides((response as IHttpResponseSucess).jsonBody as Map<String, dynamic>, _client);
  }
}
