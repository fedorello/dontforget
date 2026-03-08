import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../features/profiles/data/repositories/profiles_repository_impl.dart';
import '../../features/profiles/domain/repositories/profiles_repository.dart';
import '../../features/medicines/data/repositories/medicines_repository_impl.dart';
import '../../features/medicines/domain/repositories/medicines_repository.dart';
import '../../features/shopping/data/repositories/shopping_repository_impl.dart';
import '../../features/shopping/domain/repositories/shopping_repository.dart';
import '../../features/todos/data/repositories/todos_repository_impl.dart';
import '../../features/todos/domain/repositories/todos_repository.dart';
import '../../features/profiles/presentation/cubit/profiles_cubit.dart';
import '../../features/medicines/presentation/cubit/medicines_cubit.dart';
import '../../features/shopping/presentation/cubit/shopping_cubit.dart';
import '../../features/shopping/presentation/cubit/shopping_list_cubit.dart';
import '../../features/todos/presentation/cubit/todos_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<ApiClient>(ApiClient());

  // Repositories
  getIt.registerLazySingleton<ProfilesRepository>(
    () => ProfilesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<MedicinesRepository>(
    () => MedicinesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<TodosRepository>(
    () => TodosRepositoryImpl(getIt()),
  );

  // Cubits (factories — new instance each time)
  getIt.registerFactory(() => ProfilesCubit(getIt()));
  getIt.registerFactory(() => MedicinesCubit(getIt()));
  getIt.registerFactory(() => ShoppingCubit(getIt()));
  getIt.registerFactory(() => ShoppingListCubit(getIt()));
  getIt.registerFactory(() => TodosCubit(getIt()));
  getIt.registerFactory(() => DashboardCubit(getIt(), getIt()));
}
