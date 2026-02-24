class FamilyMember {
  final String id;
  final String displayName;
  final int birthYear;

  const FamilyMember({
    required this.id,
    required this.displayName,
    required this.birthYear,
  });

  int get age => DateTime.now().year - birthYear;

  int get recommendedKcal {
    final a = age;
    if (a >= 50) return 2200;
    if (a >= 30) return 2400;
    if (a >= 18) return 2600;
    if (a >= 14) return 2600;
    if (a >= 10) return 2200;
    return 1800;
  }

  double get recommendedProtein {
    final a = age;
    if (a >= 18) return 56.0;
    if (a >= 14) return 65.0;
    if (a >= 10) return 50.0;
    return 40.0;
  }

  int get calorieWarningPct {
    final a = age;
    if (a >= 18) return 75;
    if (a >= 14) return 80;
    return 85;
  }
}

class MonthInfo {
  final int month;
  final int year;
  final int weekdayCount;
  final int weekendCount;
  final int totalDays;

  const MonthInfo({
    required this.month,
    required this.year,
    required this.weekdayCount,
    required this.weekendCount,
    required this.totalDays,
  });
}

class BudgetData {
  static const String fatherName = 'Daddy';
  static const String appPassword = 'fent2026';

  static const List<FamilyMember> members = [
    FamilyMember(id: 'dad', displayName: 'Daddy', birthYear: 1980),
    FamilyMember(id: 'maxim', displayName: 'Maxim', birthYear: 2011),
    FamilyMember(id: 'cynthia', displayName: 'Cynthia', birthYear: 2010),
  ];

  static FamilyMember getMember(String id) =>
      members.firstWhere((m) => m.id == id);

  static const Map<int, MonthInfo> months = {
    3: MonthInfo(
        month: 3,
        year: 2026,
        weekdayCount: 22,
        weekendCount: 9,
        totalDays: 31),
    4: MonthInfo(
        month: 4,
        year: 2026,
        weekdayCount: 22,
        weekendCount: 8,
        totalDays: 30),
    5: MonthInfo(
        month: 5,
        year: 2026,
        weekdayCount: 21,
        weekendCount: 10,
        totalDays: 31),
  };

  static const List<String> priceKeys = [
    'sprouts',
    'lunch',
    'dinner',
    'proteinPacket',
    'proteinPuttyos',
    'tuna',
    'breakfast',
    'banana',
    'milk',
  ];

  static const List<String> priceEmojis = [
    '\u{1F96C}',
    '\u{1F371}',
    '\u{1F37D}\u{FE0F}',
    '\u{1F4AA}',
    '\u{1F95B}',
    '\u{1F41F}',
    '\u{1F963}',
    '\u{1F34C}',
    '\u{1F9C0}',
  ];

  // Nutrition per item: [kcal, protein, fat, carb]
  static const Map<String, List<double>> nutrition = {
    'sprouts': [30, 3.0, 0.2, 4.0],
    'lunch': [500, 22.0, 16.0, 55.0],
    'dinner': [450, 18.0, 14.0, 50.0],
    'proteinPacket': [120, 24.0, 1.5, 3.0],
    'proteinPuttyos': [150, 15.0, 5.0, 12.0],
    'tuna': [190, 30.0, 7.0, 0.0],
    'breakfast': [350, 10.0, 7.0, 58.0],
    'banana': [110, 1.3, 0.4, 27.0],
    'milk': [100, 12.0, 4.0, 3.0],
  };

  static const Map<int, Map<String, int>> defaultBasePrices = {
    3: {
      'sprouts': 400,
      'lunch': 2000,
      'dinner': 1400,
      'proteinPacket': 1100,
      'proteinPuttyos': 500,
      'tuna': 600,
      'breakfast': 350,
      'banana': 150,
      'milk': 200,
    },
    4: {
      'sprouts': 420,
      'lunch': 2100,
      'dinner': 1450,
      'proteinPacket': 1100,
      'proteinPuttyos': 520,
      'tuna': 610,
      'breakfast': 360,
      'banana': 160,
      'milk': 210,
    },
    5: {
      'sprouts': 430,
      'lunch': 2150,
      'dinner': 1500,
      'proteinPacket': 1150,
      'proteinPuttyos': 530,
      'tuna': 620,
      'breakfast': 370,
      'banana': 160,
      'milk': 220,
    },
  };

  static const Set<String> defaultUncoveredItems = {
    'proteinPacket',
    'proteinPuttyos'
  };

  static const int defaultMonthlyAllowance = 120000;
  static const int defaultWeeklyAllowance = 20000;

  static const Map<String, double> exchangeRates = {
    'EUR': 0.0025,
    'USD': 0.0027,
  };
}
