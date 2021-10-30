import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';

main() {
  test("manual sync", () async {
    final manualSyncTrue = ManualCommandSync(sync: true);
    expect(await manualSyncTrue.shouldSync([]), isTrue);

    final manualSyncFalse = ManualCommandSync(sync: false);
    expect(await manualSyncFalse.shouldSync([]), isFalse);
  });
}
