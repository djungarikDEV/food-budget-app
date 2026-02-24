class MonthData {
  final int month;
  final int year;
  final int weekdayCount;
  final int weekendCount;
  final int totalDays;
  int sproutsPrice;
  int lunchPrice;
  int dinnerPrice;
  int proteinPacketPrice;
  int proteinPuttyosPrice;
  int tunaPrice;
  int breakfastPrice;
  int bananaPrice;
  int milkPrice;

  MonthData({
    required this.month,
    required this.year,
    required this.weekdayCount,
    required this.weekendCount,
    required this.totalDays,
    required this.sproutsPrice,
    required this.lunchPrice,
    required this.dinnerPrice,
    required this.proteinPacketPrice,
    required this.proteinPuttyosPrice,
    required this.tunaPrice,
    required this.breakfastPrice,
    required this.bananaPrice,
    required this.milkPrice,
  });

  int get dailyTotal =>
      sproutsPrice +
      lunchPrice +
      dinnerPrice +
      proteinPacketPrice +
      proteinPuttyosPrice +
      tunaPrice +
      breakfastPrice +
      bananaPrice +
      milkPrice;

  int get monthlyTotal => weekdayCount * dailyTotal;

  List<int> get prices => [
        sproutsPrice,
        lunchPrice,
        dinnerPrice,
        proteinPacketPrice,
        proteinPuttyosPrice,
        tunaPrice,
        breakfastPrice,
        bananaPrice,
        milkPrice,
      ];

  void setPrice(int index, int value) {
    switch (index) {
      case 0: sproutsPrice = value;
      case 1: lunchPrice = value;
      case 2: dinnerPrice = value;
      case 3: proteinPacketPrice = value;
      case 4: proteinPuttyosPrice = value;
      case 5: tunaPrice = value;
      case 6: breakfastPrice = value;
      case 7: bananaPrice = value;
      case 8: milkPrice = value;
    }
  }
}

class BudgetData {
  static const String fatherName = 'István';

  static final Map<int, MonthData> months = {
    3: MonthData(
      month: 3, year: 2026,
      weekdayCount: 22, weekendCount: 9, totalDays: 31,
      sproutsPrice: 400, lunchPrice: 2000, dinnerPrice: 1400,
      proteinPacketPrice: 1100, proteinPuttyosPrice: 500, tunaPrice: 600,
      breakfastPrice: 350, bananaPrice: 150, milkPrice: 200,
    ),
    4: MonthData(
      month: 4, year: 2026,
      weekdayCount: 22, weekendCount: 8, totalDays: 30,
      sproutsPrice: 420, lunchPrice: 2100, dinnerPrice: 1450,
      proteinPacketPrice: 1100, proteinPuttyosPrice: 520, tunaPrice: 610,
      breakfastPrice: 360, bananaPrice: 160, milkPrice: 210,
    ),
    5: MonthData(
      month: 5, year: 2026,
      weekdayCount: 21, weekendCount: 10, totalDays: 31,
      sproutsPrice: 430, lunchPrice: 2150, dinnerPrice: 1500,
      proteinPacketPrice: 1150, proteinPuttyosPrice: 530, tunaPrice: 620,
      breakfastPrice: 370, bananaPrice: 160, milkPrice: 220,
    ),
  };

  static const List<String> priceKeys = [
    'sprouts', 'lunch', 'dinner', 'proteinPacket', 'proteinPuttyos', 'tuna',
    'breakfast', 'banana', 'milk',
  ];

  static const List<String> priceEmojis = [
    '🥬', '🍱', '🍽️', '💪', '🥛', '🐟', '🥣', '🍌', '🧀',
  ];
}
