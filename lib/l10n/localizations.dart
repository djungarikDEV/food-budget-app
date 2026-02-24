import 'app_hu.dart';
import 'app_en.dart';

class AppLocalizations {
  AppLocalizations(this._locale);

  final String _locale;

  Map<String, String> get _strings => _locale == 'hu' ? hu : en;

  String t(String key, [Map<String, String>? params]) {
    var text = _strings[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        text = text.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return text;
  }
}
