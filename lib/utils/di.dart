import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

final locator = GetIt.instance;

Future<void> setupDependencyInjection() async {
  locator.registerLazySingleton<Logger>(() => Logger());
}
