import 'dart:async';

import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/events/interaction_event.dart';
import 'package:nyxx_interactions/src/models/slash_command.dart';

abstract class IEventController implements Disposable {
  /// Emitted when a slash command is sent.
  Stream<ISlashCommandInteractionEvent> get onSlashCommand;

  /// Emitted when a button interaction is received.
  Stream<IButtonInteractionEvent> get onButtonEvent;

  /// Emitted when a dropdown interaction is received.
  Stream<IMultiselectInteractionEvent> get onMultiselectEvent;

  /// Emitted when a user interaction multi select is received.
  Stream<IUserSelectInteractionEvent> get onUserMultiSelect;

  /// Emitted when a role interaction multi select is received.
  Stream<IRoleSelectInteractionEvent> get onRoleMultiSelect;

  /// Emitted when a mentionable interaction multi select is received.
  Stream<IMentionableSelectInteractionEvent> get onMentionableMultiSelect;

  /// Emitted when a channel interaction multi select is received.
  Stream<IChannelSelectInteractionEvent> get onChannelMultiSelect;

  /// Emitted when a slash command is created by the user.
  Stream<ISlashCommand> get onSlashCommandCreated;

  /// Emitted when a slash command is created by the user.
  Stream<IAutocompleteInteractionEvent> get onAutocompleteEvent;

  /// Emitted when a modal interaction is received.
  Stream<IModalInteractionEvent> get onModalEvent;
}

class EventController implements IEventController {
  /// Emitted when a slash command is sent.
  @override
  late final Stream<ISlashCommandInteractionEvent> onSlashCommand;

  /// Emitted when a button interaction is received.
  @override
  late final Stream<IButtonInteractionEvent> onButtonEvent;

  /// Emitted when a dropdown interaction is received.
  @override
  late final Stream<IMultiselectInteractionEvent> onMultiselectEvent;

  /// Emitted when a user interaction multi select is received
  @override
  late final Stream<IUserSelectInteractionEvent> onUserMultiSelect;

  /// Emitted when a role interaction multi select is received.
  @override
  late final Stream<IRoleSelectInteractionEvent> onRoleMultiSelect;

  /// Emitted when a mentionable interaction multi select is received.
  @override
  late final Stream<IMentionableSelectInteractionEvent> onMentionableMultiSelect;

  /// Emitted when a channel interaction multi select is received.
  @override
  late final Stream<IChannelSelectInteractionEvent> onChannelMultiSelect;

  /// Emitted when a slash command is created by the user.
  @override
  late final Stream<ISlashCommand> onSlashCommandCreated;

  @override
  late final Stream<IModalInteractionEvent> onModalEvent;

  /// Emitted when a slash command is created by the user.
  @override
  late final Stream<IAutocompleteInteractionEvent> onAutocompleteEvent;

  late final StreamController<ISlashCommandInteractionEvent> onSlashCommandController;
  late final StreamController<ISlashCommand> onSlashCommandCreatedController;
  late final StreamController<IButtonInteractionEvent> onButtonEventController;
  late final StreamController<IMultiselectInteractionEvent> onMultiselectEventController;
  late final StreamController<IUserSelectInteractionEvent> onUserMultiSelectController;
  late final StreamController<IRoleSelectInteractionEvent> onRoleMultiSelectController;
  late final StreamController<IMentionableSelectInteractionEvent> onMentionableMultiSelectController;
  late final StreamController<IChannelSelectInteractionEvent> onChannelMultiSelectController;
  late final StreamController<IAutocompleteInteractionEvent> onAutocompleteEventController;
  late final StreamController<IModalInteractionEvent> onModalEventController;

  /// Creates an instance of [EventController]
  EventController() {
    onSlashCommandController = StreamController.broadcast();
    onSlashCommand = onSlashCommandController.stream;

    onSlashCommandCreatedController = StreamController.broadcast();
    onSlashCommandCreated = onSlashCommandCreatedController.stream;

    onButtonEventController = StreamController.broadcast();
    onButtonEvent = onButtonEventController.stream;

    onMultiselectEventController = StreamController.broadcast();
    onMultiselectEvent = onMultiselectEventController.stream;
    onUserMultiSelectController = StreamController.broadcast();
    onUserMultiSelect = onUserMultiSelectController.stream;
    onRoleMultiSelectController = StreamController.broadcast();
    onRoleMultiSelect = onRoleMultiSelectController.stream;
    onMentionableMultiSelectController = StreamController.broadcast();
    onMentionableMultiSelect = onMentionableMultiSelectController.stream;
    onChannelMultiSelectController = StreamController.broadcast();
    onChannelMultiSelect = onChannelMultiSelectController.stream;

    onAutocompleteEventController = StreamController.broadcast();
    onAutocompleteEvent = onAutocompleteEventController.stream;

    onModalEventController = StreamController.broadcast();
    onModalEvent = onModalEventController.stream;
  }

  @override
  Future<void> dispose() async {
    await onSlashCommandController.close();
    await onSlashCommandCreatedController.close();
    await onButtonEventController.close();
    await onMultiselectEventController.close();
    await onAutocompleteEventController.close();
    await onUserMultiSelectController.close();
    await onRoleMultiSelectController.close();
    await onMentionableMultiSelectController.close();
    await onChannelMultiSelectController.close();
  }
}
