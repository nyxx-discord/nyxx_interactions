import 'package:nyxx/nyxx.dart';

/// Type of the slash command. Since context menus reuses slash commands
/// backed, slash commands cna have different types based on context.
class SlashCommandType extends IEnum<int> {
  /// Normal slash command, invoked from chat
  static const SlashCommandType chat = SlashCommandType(1);

  /// Context menu when right clicking on user
  static const SlashCommandType user = SlashCommandType(2);

  /// Context menu when right clicking on message
  static const SlashCommandType message = SlashCommandType(3);

  /// Creates instance of [SlashCommandType] from [value]
  const SlashCommandType(int value) : super(value);
}
