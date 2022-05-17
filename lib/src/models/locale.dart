enum Locale {
  danish('da'),
  german('de'),
  englishUk('en-GB'),
  englishUs('en-US'),
  spanish('es-ES'),
  french('fr'),
  croatian('hr'),
  italian('it'),
  lithuanian('lt'),
  hungarian('hu'),
  dutch('nl'),
  norwegian('no'),
  polish('pl'),
  portugueseBrazilian('pt-BR'),
  romanian('ro'),
  finnish('fi'),
  swedish('sv-SE'),
  vietnamese('vi'),
  turkish('tr'),
  czech('cs'),
  greek('el'),
  bulgarian('bg'),
  russian('ru'),
  ukrainian('uk'),
  hindi('hi'),
  thai('th'),
  chineseChina('zh-CN'),
  japanese('ja'),
  chineseTaiwan('zh-TW'),
  korean('ko');

  final String name;
  const Locale(this.name);

  @override
  String toString() => name;
}
