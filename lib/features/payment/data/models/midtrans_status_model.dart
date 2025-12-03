// data/models/midtrans_status_model.dart
class MidtransStatusModel {
  final String transactionId;
  final String orderId;
  final String grossAmount;
  final String transactionStatus;
  final String paymentType;

  MidtransStatusModel({
    required this.transactionId,
    required this.orderId,
    required this.grossAmount,
    required this.transactionStatus,
    required this.paymentType,
  });

  factory MidtransStatusModel.fromJson(Map<String, dynamic> json) {
    return MidtransStatusModel(
      transactionId: json['transaction_id'] ?? 'N/A',
      orderId: json['order_id'] ?? 'N/A',
      grossAmount: json['gross_amount'] ?? '0',
      transactionStatus: json['transaction_status'] ?? 'unknown',
      paymentType: json['payment_type'] ?? 'unknown',
    );
  }
}