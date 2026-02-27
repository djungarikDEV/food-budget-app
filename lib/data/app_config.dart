import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:food_budget_app/data/budget_data.dart';
import 'package:intl/intl.dart';

class AppConfig {
  int monthlyAllowance;
  int weeklyAllowance;
  String currency;
  String? gistId;
  String? githubToken;

  // memberId -> month -> item key -> price override from default
  Map<String, Map<int, Map<String, int>>> memberBasePrices;

  // memberId -> month -> weekday(1-5) -> item key -> price override
  Map<String, Map<int, Map<int, Map<String, int>>>> memberWeekdayOverrides;

  // memberId -> set of uncovered item keys
  Map<String, Set<String>> memberUncoveredItems;

  AppConfig({
    this.monthlyAllowance = BudgetData.defaultMonthlyAllowance,
    this.weeklyAllowance = BudgetData.defaultWeeklyAllowance,
    this.currency = 'HUF',
    this.gistId,
    this.githubToken,
    Map<String, Map<int, Map<String, int>>>? memberBasePrices,
    Map<String, Map<int, Map<int, Map<String, int>>>>? memberWeekdayOverrides,
    Map<String, Set<String>>? memberUncoveredItems,
  })  : memberBasePrices = memberBasePrices ?? {},
        memberWeekdayOverrides = memberWeekdayOverrides ?? {},
        memberUncoveredItems = memberUncoveredItems ??
            {
              for (final m in BudgetData.members)
                m.id: Set<String>.from(BudgetData.defaultUncoveredItems),
            };

  // Get effective base prices for a member in a month
  Map<String, int> getBasePrices(String memberId, int month) {
    final defaults =
        Map<String, int>.from(BudgetData.defaultBasePrices[month] ?? {});
    final overrides = memberBasePrices[memberId]?[month];
    if (overrides != null) {
      defaults.addAll(overrides);
    }
    return defaults;
  }

  // Get effective prices for a member on a specific weekday
  Map<String, int> getPricesForWeekday(
      String memberId, int month, int weekday) {
    final base = getBasePrices(memberId, month);
    final overrides = memberWeekdayOverrides[memberId]?[month]?[weekday];
    if (overrides != null) {
      base.addAll(overrides);
    }
    return base;
  }

  // Get prices to display: if weekday is null, return base; otherwise weekday
  Map<String, int> getEffectivePrices(
      String memberId, int month, int? weekday) {
    if (weekday == null) return getBasePrices(memberId, month);
    return getPricesForWeekday(memberId, month, weekday);
  }

  // Check if a price is from base or overridden for a weekday
  bool isBasePrice(String memberId, int month, int weekday, String itemKey) {
    return memberWeekdayOverrides[memberId]?[month]?[weekday]?[itemKey] ==
        null;
  }

  bool isUncovered(String memberId, String itemKey) {
    return memberUncoveredItems[memberId]?.contains(itemKey) ?? false;
  }

  void setWeekdayPrice(
      String memberId, int month, int weekday, String itemKey, int price) {
    memberWeekdayOverrides.putIfAbsent(memberId, () => {});
    memberWeekdayOverrides[memberId]!.putIfAbsent(month, () => {});
    memberWeekdayOverrides[memberId]![month]!.putIfAbsent(weekday, () => {});
    memberWeekdayOverrides[memberId]![month]![weekday]![itemKey] = price;
  }

  void resetWeekdayPrice(
      String memberId, int month, int weekday, String itemKey) {
    memberWeekdayOverrides[memberId]?[month]?[weekday]?.remove(itemKey);
  }

  void setBasePrice(String memberId, int month, String itemKey, int price) {
    memberBasePrices.putIfAbsent(memberId, () => {});
    memberBasePrices[memberId]!.putIfAbsent(month, () => {});
    memberBasePrices[memberId]![month]![itemKey] = price;
  }

  void toggleUncovered(String memberId, String itemKey) {
    memberUncoveredItems.putIfAbsent(memberId, () => {});
    if (memberUncoveredItems[memberId]!.contains(itemKey)) {
      memberUncoveredItems[memberId]!.remove(itemKey);
    } else {
      memberUncoveredItems[memberId]!.add(itemKey);
    }
  }

  int dailyTotal(String memberId, int month, [int? weekday]) {
    return getEffectivePrices(memberId, month, weekday)
        .values
        .fold(0, (s, p) => s + p);
  }

  int coveredDailyTotal(String memberId, int month, [int? weekday]) {
    final prices = getEffectivePrices(memberId, month, weekday);
    return prices.entries
        .where((e) => !isUncovered(memberId, e.key))
        .fold(0, (s, e) => s + e.value);
  }

  int uncoveredDailyTotal(String memberId, int month, [int? weekday]) {
    final prices = getEffectivePrices(memberId, month, weekday);
    return prices.entries
        .where((e) => isUncovered(memberId, e.key))
        .fold(0, (s, e) => s + e.value);
  }

  int monthlyTotal(String memberId, int month) {
    final monthInfo = BudgetData.months[month]!;
    return coveredDailyTotal(memberId, month) * monthInfo.weekdayCount;
  }

  String formatPrice(int hufPrice, NumberFormat formatter) {
    switch (currency) {
      case 'EUR':
        return '\u20AC${(hufPrice * 0.0025).toStringAsFixed(1)}';
      case 'USD':
        return '\$${(hufPrice * 0.0027).toStringAsFixed(1)}';
      default:
        return '${formatter.format(hufPrice)} Ft';
    }
  }

  String get currencySymbol {
    switch (currency) {
      case 'EUR':
        return '\u20AC';
      case 'USD':
        return '\$';
      default:
        return 'Ft';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyAllowance': monthlyAllowance,
      'weeklyAllowance': weeklyAllowance,
      'currency': currency,
      'gistId': gistId,
      'githubToken': githubToken,
      'memberBasePrices': memberBasePrices.map((k, v) => MapEntry(
          k, v.map((mk, mv) => MapEntry(mk.toString(), mv)))),
      'memberWeekdayOverrides': memberWeekdayOverrides.map((k, v) => MapEntry(
          k,
          v.map((mk, mv) => MapEntry(mk.toString(),
              mv.map((wk, wv) => MapEntry(wk.toString(), wv)))))),
      'memberUncoveredItems':
          memberUncoveredItems.map((k, v) => MapEntry(k, v.toList())),
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final basePrices = <String, Map<int, Map<String, int>>>{};
    if (json['memberBasePrices'] is Map) {
      for (final entry in (json['memberBasePrices'] as Map).entries) {
        basePrices[entry.key as String] = {};
        for (final monthEntry in (entry.value as Map).entries) {
          basePrices[entry.key]![int.parse(monthEntry.key.toString())] =
              Map<String, int>.from(monthEntry.value);
        }
      }
    }

    final weekdayOverrides =
        <String, Map<int, Map<int, Map<String, int>>>>{};
    if (json['memberWeekdayOverrides'] is Map) {
      for (final entry in (json['memberWeekdayOverrides'] as Map).entries) {
        weekdayOverrides[entry.key as String] = {};
        for (final monthEntry in (entry.value as Map).entries) {
          final month = int.parse(monthEntry.key.toString());
          weekdayOverrides[entry.key]![month] = {};
          for (final wdEntry in (monthEntry.value as Map).entries) {
            weekdayOverrides[entry.key]![month]![
                int.parse(wdEntry.key.toString())] =
                Map<String, int>.from(wdEntry.value);
          }
        }
      }
    }

    final uncoveredItems = <String, Set<String>>{};
    if (json['memberUncoveredItems'] is Map) {
      for (final entry in (json['memberUncoveredItems'] as Map).entries) {
        uncoveredItems[entry.key as String] =
            Set<String>.from(entry.value as List);
      }
    }

    return AppConfig(
      monthlyAllowance:
          json['monthlyAllowance'] ?? BudgetData.defaultMonthlyAllowance,
      weeklyAllowance:
          json['weeklyAllowance'] ?? BudgetData.defaultWeeklyAllowance,
      currency: json['currency'] ?? 'HUF',
      gistId: json['gistId'],
      githubToken: json['githubToken'],
      memberBasePrices: basePrices,
      memberWeekdayOverrides: weekdayOverrides,
      memberUncoveredItems: uncoveredItems,
    );
  }

  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('appConfig');
    if (jsonStr != null) {
      try {
        return AppConfig.fromJson(jsonDecode(jsonStr));
      } catch (_) {
        return AppConfig();
      }
    }
    return AppConfig();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appConfig', jsonEncode(toJson()));
    _syncToGist();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') == BudgetData.appPassword;
  }

  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  static Future<String?> getSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedProfile');
  }

  static Future<void> saveSelectedProfile(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedProfile', memberId);
  }

  Future<void> _syncToGist() async {
    if (githubToken == null || githubToken!.isEmpty) return;
    try {
      final content = const JsonEncoder.withIndent('  ').convert(toJson());
      final headers = {
        'Authorization': 'token $githubToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'files': {
          'food-budget-config.json': {'content': content}
        },
        'public': true,
        'description': 'Food Budget App Config',
      });

      if (gistId != null && gistId!.isNotEmpty) {
        await http.patch(
          Uri.parse('https://api.github.com/gists/$gistId'),
          headers: headers,
          body: body,
        );
      } else {
        final response = await http.post(
          Uri.parse('https://api.github.com/gists'),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          gistId = data['id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('appConfig', jsonEncode(toJson()));
        }
      }
    } catch (_) {
      // Silently fail - local storage is the primary
    }
  }

  Future<bool> loadFromGist() async {
    if (gistId == null || gistId!.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$gistId'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileContent =
            data['files']?['food-budget-config.json']?['content'];
        if (fileContent != null) {
          final config = AppConfig.fromJson(jsonDecode(fileContent));
          monthlyAllowance = config.monthlyAllowance;
          weeklyAllowance = config.weeklyAllowance;
          currency = config.currency;
          memberBasePrices = config.memberBasePrices;
          memberWeekdayOverrides = config.memberWeekdayOverrides;
          memberUncoveredItems = config.memberUncoveredItems;
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
