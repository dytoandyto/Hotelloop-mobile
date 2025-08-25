import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  final storage = TokenStorage();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await storage.deleteToken();

          // Optional: trigger app-wide logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Show a dialog or redirect to login screen
            debugPrint("Token expired, redirecting to login");
          });
        }
        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
