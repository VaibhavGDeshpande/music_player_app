import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../config/constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
            responseType: ResponseType.json,
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final sessionCookie = await SecureStorage.getSession();
              if (sessionCookie != null && sessionCookie.isNotEmpty) {
                options.headers['Cookie'] = sessionCookie;
              }
              debugPrint('[API] >> ${options.method} ${options.uri}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint(
                '[API] << ${response.statusCode} ${response.requestOptions.uri}',
              );
              return handler.next(response);
            },
            onError: (DioException e, handler) {
              debugPrint(
                '[API] !! ERROR ${e.requestOptions.uri} => ${e.message}',
              );
              if (e.response != null) {
                debugPrint('[API] !! Response: ${e.response?.data}');
              }
              return handler.next(e);
            },
          ),
        );

  static Dio get dio => _dio;
}
