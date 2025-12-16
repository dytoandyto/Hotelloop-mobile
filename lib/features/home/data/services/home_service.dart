// lib/features/home/data/services/home_service.dart
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hotel_response.dart';

class HomeService {
  final Dio dio;

  HomeService(this.dio);

  Future<HotelResponse> getHotels() async {
    try {
      // Endpoint /hotels sesuai Laravel Resource
      final response = await dio.get('/hotels');

      if (response.statusCode == 200 && response.data != null) {
        return HotelResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load hotels');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw e.response!.data['message'] ?? 'Failed to load hotels data';
      }
      throw Exception('Network error or connection refused: $e');
    }
  }

  Future<HotelResponse> _fetchLocalHotels() async {
    print('Menggunakan data MOCK lokal...');
    try {
      // 1. Simulasi penundaan jaringan (Opsional, agar terlihat seperti API)
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. Baca string JSON dari aset
      final String jsonString = await rootBundle.loadString(
        'assets/mock/hotels.json',
      );

      // 3. Decode string JSON menjadi Map
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);

      // 4. Proses response yang didapat dari JSON lokal
      return HotelResponse.fromJson(jsonResponse);
    } catch (e) {
      print('Error loading local JSON or parsing: $e');
      throw Exception('Gagal memuat data hotel dari JSON lokal: $e');
    }
  }
}
