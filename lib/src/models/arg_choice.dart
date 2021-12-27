import 'package:nyxx/nyxx.dart';

abstract class IArgChoice {
  /// Name of choice
  String get name;

  /// Value of choice
  dynamic get value;
}

/// Choice that user can pick from. For [CommandOptionType.integer] or [CommandOptionType.string]
class ArgChoice implements IArgChoice {
  /// Name of choice
  @override
  late final String name;

  /// Value of choice
  @override
  late final dynamic value;

  /// Creates na instance of [ArgChoice]
  ArgChoice(RawApiMap raw) {
    name = raw["name"] as String;
    value = raw["value"];
  }
}
