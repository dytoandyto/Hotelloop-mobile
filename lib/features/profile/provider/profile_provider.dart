import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/profile/data/services/profile_services.dart';
import '../../auth/data/models/user_model.dart';

// Provider yang mengambil detail user berdasarkan ID
final userDetailsProvider = FutureProvider.family<UserModel, int>((ref, userId) async {
  final service = ref.read(profileServiceProvider);
  return service.fetchUserDetails(userId);
});