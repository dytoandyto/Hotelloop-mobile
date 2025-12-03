import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/dio/dio_provider.dart';
import '../data/models/room_type_model.dart';

// Provider Service
final roomTypeServiceProvider = Provider<RoomTypeService>((ref) {
  final dio = ref.read(dioProvider);
  return RoomTypeService(dio);
});

// StateNotifier untuk List Room Types
class RoomTypeNotifier extends StateNotifier<AsyncValue<List<RoomTypeModel>>> {
  final RoomTypeService _service;
  RoomTypeNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> fetchRoomTypes(int hotelId) async {
    state = const AsyncValue.loading();
    try {
      final List<RoomTypeModel> list = await _service.getRoomTypes(hotelId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Family Provider untuk mengambil Room Types berdasarkan Hotel ID
final roomTypeNotifierProvider = StateNotifierProvider.family<
    RoomTypeNotifier,
    AsyncValue<List<RoomTypeModel>>,
    int // Argumen: hotelId
>((ref, hotelId) {
  final service = ref.watch(roomTypeServiceProvider);
  final notifier = RoomTypeNotifier(service);
  notifier.fetchRoomTypes(hotelId);
  return notifier;
});


class RoomTypeService {
  final Dio dio;
  RoomTypeService(this.dio);

  Future<List<RoomTypeModel>> getRoomTypes(int hotelId) async {
    try {
      // Endpoint: /api/room-types?hotel_id={hotelId}
      final response = await dio.get('/room-types', queryParameters: {'hotel_id': hotelId}); 

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> roomTypeData = response.data['data']['data'] as List? ?? [];
        
        return roomTypeData.map((json) => RoomTypeModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat tipe kamar: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network Error: ${e.response?.statusCode ?? 'Connection Failed'}');
      }
      throw Exception('Kesalahan tak terduga saat fetch room types: $e');
    }
  }
}