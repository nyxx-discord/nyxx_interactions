import 'dart:async';

import 'package:nyxx_interactions/nyxx_interactions.dart';

/// Function that will handle execution of slash command interaction event
typedef SlashCommandHandler = FutureOr<void> Function(ISlashCommandInteractionEvent);

/// Function that will handle execution of button interaction event
typedef ButtonInteractionHandler = FutureOr<void> Function(IButtonInteractionEvent);

/// Function that will handle execution of dropdown event
typedef MultiselectInteractionHandler = FutureOr<void> Function(IMultiselectInteractionEvent);

/// Function that will handle execution of button interaction event
typedef AutocompleteInteractionHandler = FutureOr<void> Function(IAutocompleteInteractionEvent);
