import 'package:nyxx/nyxx.dart';

/// Used to define permissions for a particular command.
@Deprecated('Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead')
abstract class CommandPermissionBuilderAbstract extends Builder {
  int get type;

  /// The ID of the Role or User to give permissions too
  final Snowflake id;

  /// Does the role have permission to use the command
  final bool hasPermission;

  CommandPermissionBuilderAbstract(this.id, {this.hasPermission = true});

  /// A permission for a single user that can be used in [SlashCommandBuilder]
  factory CommandPermissionBuilderAbstract.user(Snowflake id, {bool hasPermission = true}) => UserCommandPermissionBuilder(id, hasPermission: hasPermission);

  /// A permission for a single role that can be used in [SlashCommandBuilder]
  factory CommandPermissionBuilderAbstract.role(Snowflake id, {bool hasPermission = true}) => RoleCommandPermissionBuilder(id, hasPermission: hasPermission);
}

/// A permission for a single role that can be used in [SlashCommandBuilder]
@Deprecated('Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead')
class RoleCommandPermissionBuilder extends CommandPermissionBuilderAbstract {
  @override
  late final int type = 1;

  /// A permission for a single role that can be used in [SlashCommandBuilder]
  RoleCommandPermissionBuilder(Snowflake id, {bool hasPermission = true}) : super(id, hasPermission: hasPermission);

  @override
  RawApiMap build() => {"id": id.toString(), "type": type, "permission": hasPermission};
}

/// A permission for a single user that can be used in [SlashCommandBuilder]
@Deprecated('Use SlashCommandBuilder.canBeUsedInDm and SlashCommandBuilder.requiredPermissions instead')
class UserCommandPermissionBuilder extends CommandPermissionBuilderAbstract {
  @override
  late final int type = 2;

  /// A permission for a single user that can be used in [SlashCommandBuilder]
  UserCommandPermissionBuilder(Snowflake id, {bool hasPermission = true}) : super(id, hasPermission: hasPermission);

  @override
  RawApiMap build() => {"id": id.toString(), "type": type, "permission": hasPermission};
}
