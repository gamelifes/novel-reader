import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://api.aixdzs.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));
  }

  Dio get dio {
    if (!_dio.options.headers.containsKey('Content-Type')) {
      initialize();
    }
    return _dio;
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
