import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';

main() {
  test("RoleCommandPermissionBuilder", () {
    final builder = CommandPermissionBuilderAbstract.role(Snowflake.zero());

    final expectedResult = {"id": '0', "type": 1, "permission": true};

    expect(builder.build(), equals(expectedResult));
  });

  test("RoleCommandPermissionBuilder", () {
    final builder = CommandPermissionBuilderAbstract.user(Snowflake.zero(), hasPermission: false);

    final expectedResult = {"id": '0', "type": 2, "permission": false};

    expect(builder.build(), equals(expectedResult));
  });
}
