import 'dart:async';

import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/events/interaction_event.dart';
import 'package:nyxx_interactions/src/models/slash_command.dart';
import 'package:nyxx_interactions/src/interactions.dart';

abstract class IEventController implements Disposable {
  /// Emitted when a slash command is sent.
  Stream<SlashCommandInteractionEvent> get onSlashCommand;

  /// Emitted when a button interaction is received.
  Stream<ButtonInteractionEvent> get onButtonEvent;

  /// Emitted when a dropdown interaction is received.
  Stream<MultiselectInteractionEvent> get onMultiselectEvent;

  /// Emitted when a slash command is created by the user.
  Stream<SlashCommand> get onSlashCommandCreated;

  /// Emitted when a slash command is created by the user.
  Stream<AutocompleteInteractionEvent> get onAutocompleteEvent;
}

class EventController implements IEventController {
  /// Emitted when a slash command is sent.
  late final Stream<SlashCommandInteractionEvent> onSlashCommand;

  /// Emitted when a button interaction is received.
  late final Stream<ButtonInteractionEvent> onButtonEvent;

  /// Emitted when a dropdown interaction is received.
  late final Stream<MultiselectInteractionEvent> onMultiselectEvent;

  /// Emitted when a slash command is created by the user.
  late final Stream<SlashCommand> onSlashCommandCreated;

  /// Emitted when a slash command is created by the user.
  late final Stream<AutocompleteInteractionEvent> onAutocompleteEvent;

  /// Emitted when a a slash command is sent.
  late final StreamController<SlashCommandInteractionEvent> onSlashCommandController;

  /// Emitted when a a slash command is sent.
  late final StreamController<SlashCommand> onSlashCommandCreatedController;

  /// Emitted when button event is sent
  late final StreamController<ButtonInteractionEvent> onButtonEventController;

  /// Emitted when dropdown event is sent
  late final StreamController<MultiselectInteractionEvent> onMultiselectEventController;

  /// Emitted when autocomplete interaction event is sent
  late final StreamController<AutocompleteInteractionEvent> onAutocompleteEventController;

  /// Creates na instance of [EventController]
  EventController() {
    onSlashCommandController = StreamController.broadcast();
    onSlashCommand = onSlashCommandController.stream;

    onSlashCommandCreatedController = StreamController.broadcast();
    onSlashCommandCreated = onSlashCommandCreatedController.stream;

    onButtonEventController = StreamController.broadcast();
    onButtonEvent = onButtonEventController.stream;

    onMultiselectEventController = StreamController.broadcast();
    onMultiselectEvent = onMultiselectEventController.stream;

    onAutocompleteEventController = StreamController.broadcast();
    onAutocompleteEvent = onAutocompleteEventController.stream;
  }

  @override
  Future<void> dispose() async {
    await onSlashCommandController.close();
    await onSlashCommandCreatedController.close();
    await onButtonEventController.close();
    await onMultiselectEventController.close();
    await onAutocompleteEventController.close();
  }
}
