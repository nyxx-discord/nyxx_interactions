import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:nyxx_interactions/src/builders/arg_choice_builder.dart';
import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';
import 'package:nyxx_interactions/src/builders/command_option_builder.dart';
import 'package:nyxx_interactions/src/internal/sync/commands_sync.dart';

/// Manually define command syncing rules
class LockFileCommandSync implements ICommandsSync {
  const LockFileCommandSync();

  @override
  FutureOr<bool> shouldSync(Iterable<SlashCommandBuilder> commands) async {
    File lockFile = File('./nyxx_interactions.lock');

    Map<String, String> hashes = {
      for (final command in commands) command.name: generateBuilderHash(command).bytes.map((e) => e.toRadixString(16)).join(),
    };

    if (!lockFile.existsSync()) {
      lockFile.writeAsStringSync(jsonEncode(hashes));
      return true;
    }

    try {
      Map<String, String> lockFileContents = (jsonDecode(lockFile.readAsStringSync()) as Map<dynamic, dynamic>).cast<String, String>();

      for (final entry in hashes.entries) {
        if (lockFileContents[entry.key] != entry.value) {
          return false;
        }
      }
    } on FormatException {
      lockFile.writeAsStringSync(jsonEncode(hashes));
      return true;
    }

    return false;
  }
}

Digest generateBuilderHash(SlashCommandBuilder builder) {
  return sha256.convert([
    ...utf8.encode(builder.name),
    0, // Delimiter
    ...utf8.encode(builder.description ?? ''),
    0, // Delimiter
    builder.guild?.id ?? 0,
    ...builder.options.map((o) => generateOptionHash(o).bytes).expand((e) => e),
    builder.type.value,
    builder.canBeUsedInDm ? 0 : 1,
    builder.requiredPermissions ?? 0,
  ]);
}

Digest generateOptionHash(CommandOptionBuilder builder) {
  return sha256.convert([
    ...utf8.encode(builder.name),
    0,
    ...utf8.encode(builder.description),
    0,
    builder.defaultArg ? 0 : 1,
    builder.required ? 0 : 1,
    if (builder.choices != null) ...builder.choices!.map((e) => generateChoicesHash(e).bytes).expand((e) => e),
    if (builder.options != null) ...builder.options!.map((o) => generateOptionHash(o).bytes).expand((e) => e),
    if (builder.channelTypes != null) ...builder.channelTypes!.map((e) => e.value),
    builder.autoComplete ? 0 : 1,
    if (builder.min != null) builder.min.hashCode,
    if (builder.max != null) builder.max.hashCode,
  ]);
}

Digest generateChoicesHash(ArgChoiceBuilder builder) {
  return sha256.convert([
    ...utf8.encode(builder.name),
    0,
    ...utf8.encode(builder.value.toString()),
    0,
  ]);
}
