import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:nyxx_interactions/src/builders/modal_builder.dart';
import 'package:nyxx_interactions/src/models/interaction.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/internal/utils.dart';
import 'package:nyxx_interactions/src/models/interaction_option.dart';
import 'package:nyxx_interactions/src/builders/arg_choice_builder.dart';
import 'package:nyxx_interactions/src/exceptions/interaction_expired.dart';
import 'package:nyxx_interactions/src/exceptions/response_required.dart';
import 'package:nyxx_interactions/src/exceptions/already_responded.dart';
import 'package:nyxx/nyxx.dart';

abstract class IInteractionEvent<T extends IInteraction> {
  /// Reference to [INyxx]
  INyxx get client;

  /// Reference to [Interactions]
  Interactions get interactions;

  /// The interaction data, includes the args, name, guild, channel, etc.
  T get interaction;

  /// The DateTime the interaction was received by the Nyxx Client.
  DateTime get receivedAt;
}

abstract class InteractionEventAbstract<T extends IInteraction> implements IInteractionEvent<T> {
  /// Reference to [INyxx]
  @override
  INyxx get client => interactions.client;

  /// Reference to [Interactions]
  @override
  late final Interactions interactions;

  /// The interaction data, includes the args, name, guild, channel, etc.
  @override
  T get interaction;

  /// The DateTime the interaction was received by the Nyxx Client.
  @override
  final DateTime receivedAt = DateTime.now();

  final Logger logger = Logger("Interaction Event");

  InteractionEventAbstract(this.interactions);
}

abstract class IModalInteractionEvent implements InteractionEventWithAcknowledge<IModalInteraction> {}

class ModalInteractionEvent extends InteractionEventWithAcknowledge<IModalInteraction> implements IModalInteractionEvent {
  @override
  late final IModalInteraction interaction;

  @override
  int get _acknowledgeOpCode => 5;

  @override
  int get _respondOpcode => 4;

  ModalInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions) {
    interaction = ModalInteraction(interactions.client, raw);
  }
}

abstract class IAutocompleteInteractionEvent implements InteractionEventAbstract<ISlashCommandInteraction> {
  @override
  late final ISlashCommandInteraction interaction;

  /// Returns focused option of autocomplete
  IInteractionOption get focusedOption;

  /// List of autocomplete options
  late final Iterable<IInteractionOption> options;

  /// Responds to interaction
  Future<void> respond(List<ArgChoiceBuilder> builders);
}

class AutocompleteInteractionEvent extends InteractionEventAbstract<ISlashCommandInteraction> implements IAutocompleteInteractionEvent {
  @override
  late final ISlashCommandInteraction interaction;

  @override
  IInteractionOption get focusedOption => options.firstWhere((element) => element.isFocused);

  @override
  late final Iterable<IInteractionOption> options;

  AutocompleteInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions) {
    interaction = SlashCommandInteraction(client, raw);
    options = extractArgs(interaction.options);
  }

  @override
  Future<void> respond(List<ArgChoiceBuilder> builders) async {
    if (DateTime.now().difference(receivedAt).inSeconds > 3) {
      throw InteractionExpiredError.threeSecs();
    }

    return interactions.interactionsEndpoints.respondToAutocomplete(interaction.id, interaction.token, builders);
  }
}

abstract class IInteractionEventWithAcknowledge<T extends IInteraction> implements IInteractionEvent<T> {
  /// Create a followup message for an Interaction
  Future<IMessage> sendFollowup(MessageBuilder builder, {bool hidden = false});

  /// Edits followup message
  Future<IMessage> editFollowup(Snowflake messageId, MessageBuilder builder);

  /// Deletes followup message with given id
  Future<void> deleteFollowup(Snowflake messageId);

  /// Deletes original response
  Future<void> deleteOriginalResponse();

  /// Fetch followup message
  Future<IMessage> fetchFollowup(Snowflake messageId);

  /// Used to acknowledge a Interaction but not send any response yet.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  Future<void> acknowledge({bool hidden = false});

  /// Used to acknowledge a Interaction and send a response.
  /// Once this is sent you can then only send ChannelMessages.
  Future<void> respond(MessageBuilder builder, {bool hidden = false});

  /// Returns [Message] object of original interaction response
  Future<IMessage> getOriginalResponse();

  /// Edits original message response
  Future<IMessage> editOriginalResponse(MessageBuilder builder);
}

abstract class InteractionEventWithAcknowledge<T extends IInteraction> extends InteractionEventAbstract<T> implements IInteractionEventWithAcknowledge<T> {
  /// If the Client has sent a response to the Discord API. Once the API was received a response you cannot send another.
  bool _hasAcked = false;

  /// Opcode for acknowledging interaction
  int get _acknowledgeOpCode;

  /// Opcode for responding to interaction
  int get _respondOpcode;

  InteractionEventWithAcknowledge(Interactions interactions) : super(interactions);

  /// Create a followup message for an Interaction
  @override
  Future<IMessage> sendFollowup(MessageBuilder builder, {bool hidden = false}) async {
    if (!_hasAcked) {
      return Future.error(ResponseRequiredError());
    }
    logger.fine("Sending followup for interaction: ${interaction.id}");

    return interactions.interactionsEndpoints.sendFollowup(interaction.token, client.appId, builder, hidden: hidden);
  }

  /// Edits followup message
  @override
  Future<IMessage> editFollowup(Snowflake messageId, MessageBuilder builder) =>
      interactions.interactionsEndpoints.editFollowup(interaction.token, client.appId, messageId, builder);

  /// Deletes followup message with given id
  @override
  Future<void> deleteFollowup(Snowflake messageId) => interactions.interactionsEndpoints.deleteFollowup(interaction.token, client.appId, messageId);

  /// Deletes original response
  @override
  Future<void> deleteOriginalResponse() =>
      interactions.interactionsEndpoints.deleteOriginalResponse(interaction.token, client.appId, interaction.id.toString());

  /// Fetch followup message
  @override
  Future<IMessage> fetchFollowup(Snowflake messageId) async => interactions.interactionsEndpoints.fetchFollowup(interaction.token, client.appId, messageId);

  /// Used to acknowledge a Interaction but not send any response yet.
  /// Once this is sent you can then only send ChannelMessages.
  /// You can also set showSource to also print out the command the user entered.
  @override
  Future<void> acknowledge({bool hidden = false}) async {
    if (_hasAcked) {
      return Future.error(AlreadyRespondedError());
    }

    if (DateTime.now().isAfter(receivedAt.add(const Duration(seconds: 3)))) {
      return Future.error(InteractionExpiredError.threeSecs());
    }

    try {
      await interactions.interactionsEndpoints.acknowledge(interaction.token, interaction.id.toString(), hidden, _acknowledgeOpCode);
    } on IHttpResponseError catch (response) {
      // 40060 - Interaction has already been acknowledged
      // Catch in case of a desync between server and _hasAcked
      if (response.code == 40060) {
        throw AlreadyRespondedError();
      }

      rethrow;
    }

    logger.fine("Sending acknowledge for for interaction: ${interaction.id}");

    _hasAcked = true;
  }

  /// Used to acknowledge a Interaction and send a response.
  /// Once this is sent you can then only send ChannelMessages.
  @override
  Future<void> respond(MessageBuilder builder, {bool hidden = false}) async {
    final now = DateTime.now();
    if (_hasAcked && now.isAfter(receivedAt.add(const Duration(minutes: 15)))) {
      return Future.error(InteractionExpiredError.fifteenMins());
    } else if (!_hasAcked && now.isAfter(receivedAt.add(const Duration(seconds: 3)))) {
      return Future.error(InteractionExpiredError.threeSecs());
    }

    logger.fine("Sending respond for for interaction: ${interaction.id}");
    if (_hasAcked) {
      await interactions.interactionsEndpoints.respondEditOriginal(interaction.token, client.appId, builder, hidden);
    } else {
      if (!builder.canBeUsedAsNewMessage()) {
        return Future.error(ArgumentError("Cannot sent message when MessageBuilder doesn't have set either content, embed or files"));
      }

      await interactions.interactionsEndpoints.respondCreateResponse(interaction.token, interaction.id.toString(), builder, hidden, _respondOpcode);
    }

    _hasAcked = true;
  }

  /// Returns [IMessage] object of original interaction response
  @override
  Future<IMessage> getOriginalResponse() async =>
      interactions.interactionsEndpoints.fetchOriginalResponse(interaction.token, client.appId, interaction.id.toString());

  /// Edits original message response
  @override
  Future<IMessage> editOriginalResponse(MessageBuilder builder) =>
      interactions.interactionsEndpoints.editOriginalResponse(interaction.token, client.appId, builder);
}

abstract class ISlashCommandInteractionEvent with IModalResponseMixin implements InteractionEventWithAcknowledge<SlashCommandInteraction> {
  /// Returns args of interaction
  List<IInteractionOption> get args;

  /// Searches for arg with [name] in this interaction
  IInteractionOption getArg(String name);
}

/// Event for slash commands
class SlashCommandInteractionEvent extends InteractionEventWithAcknowledge<SlashCommandInteraction>
    with ModalResponseMixin
    implements ISlashCommandInteractionEvent {
  /// Interaction data for slash command
  @override
  late final SlashCommandInteraction interaction;

  @override
  int get _acknowledgeOpCode => 5;

  @override
  int get _respondOpcode => 4;

  /// Returns args of interaction
  @override
  List<IInteractionOption> get args => UnmodifiableListView(extractArgs(interaction.options));

  /// Searches for arg with [name] in this interaction.
  ///
  /// Throws if [name] was not found in this interaction; if you want to look up the value of [name] and return `null` if it was not provided, use
  /// [interaction.getArg] instead.
  @override
  IInteractionOption getArg(String name) => args.firstWhere((element) => element.name == name);

  SlashCommandInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions) {
    interaction = SlashCommandInteraction(client, raw);
  }
}

abstract class IComponentInteractionEvent<T extends IComponentInteraction> implements IInteractionEventWithAcknowledge<T> {}

/// Generic event for component interactions
abstract class ComponentInteractionEvent<T extends IComponentInteraction> extends InteractionEventWithAcknowledge<T> implements IComponentInteractionEvent<T> {
  /// Interaction data for slash command
  @override
  T get interaction;

  @override
  int get _acknowledgeOpCode => 6;

  @override
  int get _respondOpcode => 7;

  ComponentInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions);
}

abstract class IButtonInteractionEvent with IModalResponseMixin implements IComponentInteractionEvent<IButtonInteraction> {}

/// Interaction event for button events
class ButtonInteractionEvent extends ComponentInteractionEvent<IButtonInteraction> with ModalResponseMixin implements IButtonInteractionEvent {
  @override
  late final IButtonInteraction interaction;

  ButtonInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = ButtonInteraction(client, raw);
  }
}

abstract class IMultiselectInteractionEvent implements ComponentInteractionEvent<IMultiselectInteraction> {}

/// Interaction event for dropdown events
class MultiselectInteractionEvent extends ComponentInteractionEvent<IMultiselectInteraction> implements IMultiselectInteractionEvent {
  @override
  late final IMultiselectInteraction interaction;

  MultiselectInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = MultiselectInteraction(client, raw);
  }
}

abstract class IUserMultiSelectInteractionEvent implements ComponentInteractionEvent<IUserMultiSelectInteraction> {}

class UserMultiSelectInteractionEvent extends ComponentInteractionEvent<IUserMultiSelectInteraction> implements IUserMultiSelectInteractionEvent {
  @override
  late final IUserMultiSelectInteraction interaction;

  UserMultiSelectInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = UserMultiSelectInteraction(client, raw);
  }
}

abstract class IRoleMultiSelectInteractionEvent implements ComponentInteractionEvent<IRoleMultiSelectInteraction> {}

class RoleMultiSelectInteractionEvent extends ComponentInteractionEvent<IRoleMultiSelectInteraction> implements IRoleMultiSelectInteractionEvent {
  @override
  late final IRoleMultiSelectInteraction interaction;

  RoleMultiSelectInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = RoleMultiSelectInteraction(client, raw);
  }
}

abstract class IMentionableMultiSelectInteractionEvent implements ComponentInteractionEvent<IMentionableMultiSelectInteraction> {}

class MentionableMultiSelectInteractionEvent extends ComponentInteractionEvent<IMentionableMultiSelectInteraction>
    implements IMentionableMultiSelectInteractionEvent {
  @override
  late final IMentionableMultiSelectInteraction interaction;

  MentionableMultiSelectInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = MentionableMultiSelectInteraction(client, raw);
  }
}

abstract class IChannelMultiSelectInteractionEvent implements ComponentInteractionEvent<IChannelMultiSelectInteraction> {}

class ChannelMultiSelectInteractionEvent extends ComponentInteractionEvent<IChannelMultiSelectInteraction> implements IChannelMultiSelectInteractionEvent {
  @override
  late final IChannelMultiSelectInteraction interaction;

  ChannelMultiSelectInteractionEvent(Interactions interactions, RawApiMap raw) : super(interactions, raw) {
    interaction = ChannelMultiSelectInteraction(client, raw);
  }
}

mixin IModalResponseMixin {
  IInteractions get interactions;
  IInteraction get interaction;

  Future<void> respondModal(ModalBuilder builder);
}

mixin ModalResponseMixin implements IModalResponseMixin {
  @override
  Future<void> respondModal(ModalBuilder builder) => interactions.interactionsEndpoints.respondModal(interaction.token, interaction.id.toString(), builder);
}
