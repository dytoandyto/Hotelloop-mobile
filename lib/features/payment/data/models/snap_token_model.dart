//lib/features/payment/data/models/snap_token_model.dart
class SnapTokenModel {
  final String snapToken;
  final String snapUrl;

  SnapTokenModel({
    required this.snapToken,
    required this.snapUrl,
  });

  factory SnapTokenModel.fromJson(Map<String, dynamic> json) {
    return SnapTokenModel(
      snapToken: json['snap_token'],
      snapUrl: json['snap_url'],
    );
  }
}
