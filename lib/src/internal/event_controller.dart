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

  /// Emitted when a slash command is created by the user.
  Stream<ISlashCommand> get onSlashCommandCreated;

  /// Emitted when a slash command is created by the user.
  Stream<IAutocompleteInteractionEvent> get onAutocompleteEvent;
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

  /// Emitted when a slash command is created by the user.
  @override
  late final Stream<ISlashCommand> onSlashCommandCreated;

  /// Emitted when a slash command is created by the user.
  @override
  late final Stream<IAutocompleteInteractionEvent> onAutocompleteEvent;

  /// Emitted when a a slash command is sent.
  late final StreamController<ISlashCommandInteractionEvent> onSlashCommandController;

  /// Emitted when a a slash command is sent.
  late final StreamController<ISlashCommand> onSlashCommandCreatedController;

  /// Emitted when button event is sent
  late final StreamController<IButtonInteractionEvent> onButtonEventController;

  /// Emitted when dropdown event is sent
  late final StreamController<IMultiselectInteractionEvent> onMultiselectEventController;

  /// Emitted when autocomplete interaction event is sent
  late final StreamController<IAutocompleteInteractionEvent> onAutocompleteEventController;

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
