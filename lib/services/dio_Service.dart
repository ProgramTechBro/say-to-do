import 'package:dio/dio.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  late Dio dio;

  DioService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '',
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
  Dio get client => dio;
}
