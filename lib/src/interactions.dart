import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/src/backend/interaction_backend.dart';

import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';
import 'package:nyxx_interactions/src/internal/interaction_endpoints.dart';
import 'package:nyxx_interactions/src/internal/event_controller.dart';
import 'package:nyxx_interactions/src/models/slash_command.dart';
import 'package:nyxx_interactions/src/internal/sync/commands_sync.dart';
import 'package:nyxx_interactions/src/internal/sync/manual_command_sync.dart';
import 'package:nyxx_interactions/src/internal/utils.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/typedefs.dart';
import 'package:nyxx_interactions/src/events/interaction_event.dart';

abstract class IInteractions {
  IEventController get events;

  /// Reference to client
  INyxx get client;

  InteractionBackend get backend;

  /// Commands registered by bot
  Iterable<ISlashCommand> get commands;

  /// All interaction endpoints that can be accessed.
  IInteractionsEndpoints get interactionsEndpoints;

  /// Syncs commands builders with discord after client is ready.
  void syncOnReady({ICommandsSync syncRule = const ManualCommandSync()});

  /// Syncs command builders with discord immediately.
  /// Warning: Client could not be ready at the function execution.
  /// Use [syncOnReady] for proper behavior
  Future<void> sync({ICommandsSync syncRule = const ManualCommandSync()});

  /// Registers callback for button event for given [id]
  void registerAutocompleteHandler(String id, AutocompleteInteractionHandler handler);

  /// Registers callback for button event for given [id]
  void registerButtonHandler(String id, ButtonInteractionHandler handler);

  /// Register callback for dropdown event for given [id]
  void registerMultiselectHandler(String id, MultiselectInteractionHandler handler);

  /// Allows to register new [SlashCommandBuilder]
  void registerSlashCommand(SlashCommandBuilder slashCommandBuilder);

  /// Register callback for slash command event for given [id]
  void registerSlashCommandHandler(String id, SlashCommandHandler handler);

  /// Deletes global command
  Future<void> deleteGlobalCommand(Snowflake commandId);

  /// Deletes guild command
  Future<void> deleteGuildCommand(Snowflake commandId, Snowflake guildId);

  /// Fetches all global bots command
  Stream<ISlashCommand> fetchGlobalCommands();

  /// Fetches all guild commands for given guild
  Stream<ISlashCommand> fetchGuildCommands(Snowflake guildId);
}

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions implements IInteractions {
  static const _interactionCreateCommand = "INTERACTION_CREATE";

  final Logger _logger = Logger("Interactions");
  final _commandBuilders = <SlashCommandBuilder>[];
  final _commands = <ISlashCommand>[];
  final _commandHandlers = <String, SlashCommandHandler>{};
  final _buttonHandlers = <String, ButtonInteractionHandler>{};
  final _autocompleteHandlers = <String, AutocompleteInteractionHandler>{};
  final _multiselectHandlers = <String, MultiselectInteractionHandler>{};

  @override
  late final IEventController events;

  /// Reference to client
  @override
  INyxx get client => backend.client;

  @override
  final InteractionBackend backend;

  /// Commands registered by bot
  @override
  Iterable<ISlashCommand> get commands => UnmodifiableListView(_commands);

  /// All interaction endpoints that can be accessed.
  @override
  late final IInteractionsEndpoints interactionsEndpoints;

  /// Create new instance of the interactions class.
  Interactions(this.backend) {
    events = EventController();
    interactionsEndpoints = InteractionsEndpoints(client);

    _logger.info("Interactions ready");

    backend.getStream().listen((rawData) {
      if (rawData["op"] == 0 && rawData["t"] == _interactionCreateCommand) {
        _logger.fine("Received interaction event: [$rawData]");

        final type = rawData["d"]["type"] as int;

        switch (type) {
          case 2:
            (events as EventController).onSlashCommandController.add(SlashCommandInteractionEvent(this, rawData["d"] as RawApiMap));
            break;
          case 3:
            final componentType = rawData["d"]["data"]["component_type"] as int;

            switch (componentType) {
              case 2:
                (events as EventController).onButtonEventController.add(ButtonInteractionEvent(this, rawData["d"] as Map<String, dynamic>));
                break;
              case 3:
                (events as EventController).onMultiselectEventController.add(MultiselectInteractionEvent(this, rawData["d"] as Map<String, dynamic>));
                break;
              default:
                _logger.warning("Unknown componentType type: [$componentType]; Payload: ${jsonEncode(rawData)}");
            }
            break;
          case 4:
            (events as EventController).onAutocompleteEventController.add(AutocompleteInteractionEvent(this, rawData["d"] as Map<String, dynamic>));
            break;
          default:
            _logger.warning("Unknown interaction type: [$type]; Payload: ${jsonEncode(rawData)}");
        }
      }
    });
  }

  /// Syncs commands builders with discord after client is ready.
  @override
  void syncOnReady({ICommandsSync syncRule = const ManualCommandSync()}) {
    // client.onReady.listen((_) async {
    //   await sync(syncRule: syncRule);
    // });
  }

  /// Syncs command builders with discord immediately.
  /// Warning: Client could not be ready at the function execution.
  /// Use [syncOnReady] for proper behavior
  @override
  Future<void> sync({ICommandsSync syncRule = const ManualCommandSync()}) async {
    if (!await syncRule.shouldSync(_commandBuilders)) {
      return;
    }

    final commandPartition = partition<SlashCommandBuilder>(_commandBuilders, (element) => element.guild == null);
    final globalCommands = commandPartition.first;
    final groupedGuildCommands = groupSlashCommandBuilders(commandPartition.last);

    final globalCommandsResponse = await interactionsEndpoints.bulkOverrideGlobalCommands(client.appId, globalCommands).toList();

    _extractCommandIds(globalCommandsResponse);
    _registerCommandHandlers(globalCommandsResponse, globalCommands);

    for (final entry in groupedGuildCommands.entries) {
      final response = await interactionsEndpoints.bulkOverrideGuildCommands(client.appId, entry.key, entry.value).toList();

      _extractCommandIds(response);
      _registerCommandHandlers(response, entry.value);
      await interactionsEndpoints.bulkOverrideGuildCommandsPermissions(client.appId, entry.key, entry.value);
    }

    _commandBuilders.clear(); // Cleanup after registering command since we don't need this anymore
    _logger.info("Finished bulk overriding slash commands and permissions");

    if (_commands.isNotEmpty) {
      events.onSlashCommand.listen((event) async {
        final commandHash = determineInteractionCommandHandler(event.interaction);

        _logger.info("Executing command with hash [$commandHash]");
        if (_commandHandlers.containsKey(commandHash)) {
          await _commandHandlers[commandHash]!(event);
        }
      });

      _logger.info("Finished registering ${_commandHandlers.length} commands!");
    }

    if (_buttonHandlers.isNotEmpty) {
      events.onButtonEvent.listen((event) {
        if (_buttonHandlers.containsKey(event.interaction.customId)) {
          _logger.info("Executing button with id [${event.interaction.customId}]");
          _buttonHandlers[event.interaction.customId]!(event);
        } else {
          _logger.warning("Received event for unknown button: ${event.interaction.customId}");
        }
      });
    }

    if (_multiselectHandlers.isNotEmpty) {
      events.onMultiselectEvent.listen((event) {
        if (_multiselectHandlers.containsKey(event.interaction.customId)) {
          _logger.info("Executing multiselect with id [${event.interaction.customId}]");
          _multiselectHandlers[event.interaction.customId]!(event);
        } else {
          _logger.warning("Received event for unknown dropdown: ${event.interaction.customId}");
        }
      });
    }

    if (_autocompleteHandlers.isNotEmpty) {
      events.onAutocompleteEvent.listen((event) {
        final name = event.focusedOption.name;

        if (_autocompleteHandlers.containsKey(name)) {
          _logger.info("Executing autocomplete with id [$name]");
          _autocompleteHandlers[name]!(event);
        } else {
          _logger.warning("Received event for unknown dropdown: $name");
        }
      });
    }
  }

  /// Registers callback for button event for given [id]
  @override
  void registerAutocompleteHandler(String id, AutocompleteInteractionHandler handler) => _autocompleteHandlers[id] = handler;

  /// Registers callback for button event for given [id]
  @override
  void registerButtonHandler(String id, ButtonInteractionHandler handler) => _buttonHandlers[id] = handler;

  /// Register callback for dropdown event for given [id]
  @override
  void registerMultiselectHandler(String id, MultiselectInteractionHandler handler) => _multiselectHandlers[id] = handler;

  /// Allows to register new [SlashCommandBuilder]
  @override
  void registerSlashCommand(SlashCommandBuilder slashCommandBuilder) => _commandBuilders.add(slashCommandBuilder);

  /// Register callback for slash command event for given [id]
  @override
  void registerSlashCommandHandler(String id, SlashCommandHandler handler) => _commandHandlers[id] = handler;

  /// Deletes global command
  @override
  Future<void> deleteGlobalCommand(Snowflake commandId) => interactionsEndpoints.deleteGlobalCommand(client.appId, commandId);

  /// Deletes guild command
  @override
  Future<void> deleteGuildCommand(Snowflake commandId, Snowflake guildId) => interactionsEndpoints.deleteGuildCommand(client.appId, commandId, guildId);

  /// Fetches all global bots command
  @override
  Stream<ISlashCommand> fetchGlobalCommands() => interactionsEndpoints.fetchGlobalCommands(client.appId);

  /// Fetches all guild commands for given guild
  @override
  Stream<ISlashCommand> fetchGuildCommands(Snowflake guildId) => interactionsEndpoints.fetchGuildCommands(client.appId, guildId);

  void _extractCommandIds(List<ISlashCommand> commands) {
    for (final slashCommand in commands) {
      _commandBuilders.firstWhere((element) => element.name == slashCommand.name && element.guild == slashCommand.guild?.id).setId(slashCommand.id);
    }
  }

  void _registerCommandHandlers(List<ISlashCommand> registeredSlashCommands, Iterable<SlashCommandBuilder> builders) {
    for (final registeredCommand in registeredSlashCommands) {
      final matchingBuilder = builders.firstWhere((element) => element.name.toLowerCase() == registeredCommand.name);
      _assignCommandToHandler(matchingBuilder, registeredCommand);

      _commands.add(registeredCommand);
    }
  }

  void _assignCommandToHandler(SlashCommandBuilder builder, ISlashCommand command) {
    final commandHashPrefix = "${command.id}|${command.name}";

    var allowRootHandler = true;

    final subCommands = builder.options.where((element) => element.type == CommandOptionType.subCommand);
    if (subCommands.isNotEmpty) {
      for (final subCommand in subCommands) {
        if (subCommand.handler == null) {
          continue;
        }

        _commandHandlers["$commandHashPrefix|${subCommand.name}"] = subCommand.handler!;
      }

      allowRootHandler = false;
    }

    final subCommandGroups = builder.options.where((element) => element.type == CommandOptionType.subCommandGroup);
    if (subCommandGroups.isNotEmpty) {
      for (final subCommandGroup in subCommandGroups) {
        final subCommands = subCommandGroup.options?.where((element) => element.type == CommandOptionType.subCommand) ?? [];

        for (final subCommand in subCommands) {
          if (subCommand.handler == null) {
            continue;
          }

          _commandHandlers["$commandHashPrefix|${subCommandGroup.name}|${subCommand.name}"] = subCommand.handler!;
        }
      }

      allowRootHandler = false;
    }

    if (!allowRootHandler) {
      return;
    }

    if (builder.handler != null) {
      _commandHandlers[commandHashPrefix] = builder.handler!;
    }
  }
}
