class PriceModel {
  final double weekdayPrice;
  final double weekendPrice;
  final String currency;

  PriceModel({
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.currency,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    // Parsing String/Decimal ke Double dengan aman
    final weekdayPriceStr = json['weekday_price']?.toString() ?? '0';
    final weekendPriceStr = json['weekend_price']?.toString() ?? '0';

    return PriceModel(
      weekdayPrice: double.tryParse(weekdayPriceStr) ?? 0.0,
      weekendPrice: double.tryParse(weekendPriceStr) ?? 0.0,
      currency: json['currency'] ?? 'IDR',
    );
  }
}