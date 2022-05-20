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

  /// Deserializes the [name] into a [Locale]. If the [name] is not a valid locale, 
  /// returns the [Locale.englishUs] as it is considered the default locale from Discord.
  static Locale deserialize(String name) {
    return values.firstWhere((e) => e.name == name, orElse: () => Locale.englishUs);
  }

  @override
  String toString() => name;
}
