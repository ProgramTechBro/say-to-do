import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iso_languages/iso_languages.dart' as iso;

class LanguageScreenController extends GetxController {
  RxMap<String, String> selectedLanguage = RxMap<String, String>({
    'title': 'English',
    'code': 'en',
  });
  RxList<Map<String, String>> allLanguages = <Map<String, String>>[].obs;
  RxList<Map<String, String>> filteredLanguages = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguages();
    _loadSavedLanguage();
    saveLanguageSelection();
  }
  void _loadLanguages() {
    final List<Map<String, String>> topLanguages = [
      {'title': 'English', 'code': 'en'},
      {'title': 'Arabic', 'code': 'ar'},
      {'title': 'Spanish', 'code': 'es'},
      {'title': 'French', 'code': 'fr'},
      {'title': 'German', 'code': 'de'},
      {'title': 'Chinese', 'code': 'zh'},
      {'title': 'Japanese', 'code': 'ja'},
      {'title': 'Russian', 'code': 'ru'},
      {'title': 'Urdu', 'code': 'ur-PK'},
    ];
    final List<Map<String, String>> pakLanguages = [
      {'title': 'Punjabi', 'code': 'pa-PK'},
      {'title': 'Balochi', 'code': 'bal-PK'},
      {'title': 'Pashto', 'code': 'ps-PK'},
      {'title': 'Saraiki', 'code': 'skr-PK'},
      {'title': 'Hindi', 'code': 'hi'},
      {'title': 'Brahui', 'code': 'brh-PK'},
    ];
    final isoCodes = [
      'it',
      'pt',
      'ko',
      'bn',
      'fa',
      'tr',
      'id',
      'vi',
      'th',
      'ms',
      'sw',
      'uk',
      'pl',
      'ro',
      'nl',
      'sv',
      'fi',
      'no',
      'da',
      'cs',
      'el',
      'he',
      'hu',
      'sk',
      'sl',
      'hr',
      'lt',
      'lv',
      'et',
      'bg',
      'sr',
      'ta',
      'te',
      'kn',
      'ml',
      'gu',
      'mr',
      'ne',
      'si',
      'sd',
      'am',
      'az',
      'be',
      'bs',
      'eu',
      'gl',
      'hy',
      'ka',
      'kk',
      'km',
      'ky',
      'lo',
      'mn',
      'my',
      'ny',
      'or',
      'rw',
      'so',
      'tg',
      'uz',
      'xh',
      'zu',
    ];
    final existingCodes =
    topLanguages.map((l) => l['code']).toSet()
      ..addAll(pakLanguages.map((l) => l['code']));

    final List<Map<String, String>> remainingLanguages = [];
    for (var code in isoCodes) {
      if (!existingCodes.contains(code)) {
        final name = iso.isoLanguage(shortName: code);
        remainingLanguages.add({'title': name, 'code': code});
      }
    }
    allLanguages.value = [
      ...topLanguages,
      ...pakLanguages,
      ...remainingLanguages,
    ];
    filteredLanguages.value = allLanguages;
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('voice_language_code');
    final title = prefs.getString('voice_language_title');
    if (code != null && title != null) {
      selectedLanguage.value = {'code': code, 'title': title};
    }
  }

  Future<void> setSelectedLanguage(Map<String, String> lang) async {
    selectedLanguage.value = {'code': lang['code']!, 'title': lang['title']!};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_language_code', lang['code']!);
    await prefs.setString('voice_language_title', lang['title']!);
  }

  Future<void> saveLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_selected', true);
  }

  void filterLanguages(String query) {
    if (query.isEmpty) {
      filteredLanguages.value = allLanguages;
    } else {
      filteredLanguages.value =
          allLanguages
              .where(
                (lang) =>
                lang['title']!.toLowerCase().contains(query.toLowerCase()),
          )
              .toList();
    }
  }
}