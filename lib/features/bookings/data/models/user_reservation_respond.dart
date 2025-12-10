// // lib/features/bookings/data/models/user_reservations_response.dart
// import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';

// class UserReservationsResponse {
//   final List<ReservationModel> reservations;
//   final String? message;

//   UserReservationsResponse({required this.reservations, this.message});

//   factory UserReservationsResponse.fromJson(Map<String, dynamic> json) {
//     // API kamu mengembalikan list reservasi di root key 'data'
//     final List<dynamic> rawList = json['data'] as List? ?? [];

//     final List<ReservationModel> reservations = rawList
//         .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
//         .toList();

//     return UserReservationsResponse(
//       reservations: reservations,
//       message: json['message'],
//     );
//   }
// }