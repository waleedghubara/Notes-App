// ignore_for_file: avoid_print

import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // تحديد نوع المحتوى فقط إذا لم تكن FormData
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    final token = await SecureCacheHelper().getData(key: ApiKey.token);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('✅ Token Added: FOODAPI $token');
    } else {
      print('⚠️ No token found in secure storage');
    }

    super.onRequest(options, handler);
  }
}
