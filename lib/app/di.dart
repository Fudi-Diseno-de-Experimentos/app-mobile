import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/core/network/auth_interceptor.dart';
import 'package:app_mobile/features/analytics/di/analytics_dependency_injector.dart';
import 'package:app_mobile/features/announcements/di/announcement_dependency_injector.dart';
import 'package:app_mobile/features/chat/di/chat_dependency_injector.dart';
import 'package:app_mobile/features/company/di/company_dependency_injector.dart';
import 'package:app_mobile/features/events/di/event_dependency_injector.dart';
import 'package:app_mobile/features/iam/di/iam_dependency_injector.dart';
import 'package:app_mobile/features/profile/di/profile_dependency_injector.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  final tokenStore = TokenStore(storage: sl());
  await tokenStore.init();
  sl.registerLazySingleton(() => tokenStore);
  sl.registerLazySingleton(() => AuthInterceptor(tokenStore: sl()));
  sl.registerLazySingleton(() {
    final apiClient = ApiClient(dio: sl());
    apiClient.addAuthInterceptor(sl());
    return apiClient;
  });

  // Features
  initIamDependencies();
  initProfileDependencies();
  initAnnouncementDependencies();
  initEventDependencies();
  initAnalyticsDependencies();
  initChatDependencies();
  initCompanyDependencies();
}
