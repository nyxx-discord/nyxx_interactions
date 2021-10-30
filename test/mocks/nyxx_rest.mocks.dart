import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class NyxxRestMock extends Fake implements INyxxRest {
  @override
  ClientOptions get options => ClientOptions();
}
