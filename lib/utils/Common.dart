String getCountryCodeFromLanguage(String code) {
  final languageCode = code.contains('-') ? code.split('-').first : code;
  final Map<String, String> languageToCountry = {
    'en': 'us',
    'zh': 'cn',
    'ja': 'jp',
    'hi': 'in',
    'ur': 'pk',
    'pa': 'pk',
    'bal': 'pk',
    'ps': 'pk',
    'skr': 'pk',
    'ko': 'kr',
    'fa': 'ir',
    'sw': 'tz',
    'uk': 'ua',
    'da': 'dk',
    'cs': 'cz',
    'el': 'gr',
    'he': 'il',
    'ta': 'in',
    'te': 'in',
    'ml': 'in',
    'gu': 'in',
    'mr': 'in',
    'or': 'in',
    'am': 'et',
    'hy': 'am',
    'ka': 'ge',
    'kk': 'kz',
    'lo': 'la',
    'ny': 'mw',
    'xh': 'za',
    'zu': 'za',
  };
  return languageToCountry[languageCode] ??
      (code.contains('-') ? code.split('-').last : code);
}

