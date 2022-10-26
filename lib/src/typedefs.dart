import 'dart:async';

import 'package:nyxx_interactions/src/events/interaction_event.dart';

/// Function that will handle execution of slash command interaction event
typedef SlashCommandHandler = FutureOr<void> Function(ISlashCommandInteractionEvent);

/// Function that will handle execution of button interaction event
typedef ButtonInteractionHandler = FutureOr<void> Function(IButtonInteractionEvent);

/// Function that will handle execution of dropdown event
typedef MultiselectInteractionHandler = FutureOr<void> Function(IMultiselectInteractionEvent);

/// Function that will handle execution of button interaction event
typedef AutocompleteInteractionHandler = FutureOr<void> Function(IAutocompleteInteractionEvent);

/// Function that will handle execution of user dropdown event
typedef UserSelectInteractionHandler = FutureOr<void> Function(IUserSelectInteractionEvent); 

/// Function that will handle execution of role dropdown event
typedef RoleSelectInteractionHandler = FutureOr<void> Function(IRoleSelectInteractionEvent); 

/// Function that will handle execution of mentionable dropdown event
typedef MentionableSelectInteractionHandler = FutureOr<void> Function(IMentionableSelectInteractionEvent); 

/// Function that will handle execution of channel dropdown event
typedef ChannelSelectInteractionHandler = FutureOr<void> Function(IChannelSelectInteractionEvent); 
