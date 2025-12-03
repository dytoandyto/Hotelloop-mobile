// data/models/snap_token_model.dart
class SnapTokenModel {
  final String snapToken;
  final String snapUrl;
  final String? message;
  final String? error;

  SnapTokenModel({
    required this.snapToken,
    required this.snapUrl,
    this.message,
    this.error,
  });

  factory SnapTokenModel.fromJson(Map<String, dynamic> json) {
    // Sesuaikan parsing jika BE Anda membungkus data di key 'data' atau tidak.
    // Berdasarkan contoh respon Anda: { "snap_token": "...", "snap_url": "..." }
    final data = json['data'] ?? json;
    
    // Pastikan menerima snap_token dan snap_url
    return SnapTokenModel(
      snapToken: data['snap_token'] ?? '', 
      snapUrl: data['snap_url'] ?? '',
      message: json['message'],
      error: json['error'],
    );
  }
}