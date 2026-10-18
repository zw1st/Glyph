import 'package:get_it/get_it.dart';
import 'package:glyph/data/database/app_database.dart';
import 'package:glyph/data/ml/ocr_service.dart';
import 'package:glyph/data/repo/doc_repo.dart';
import 'package:glyph/domain/repo_interface/doc_repo_interface.dart';
import 'package:logger/logger.dart';

import '../data/database/dao/doc_dao.dart';
import '../data/database/dao/page_dao.dart';
import '../data/file_storage/storage_service.dart';
import '../data/ml/engine_factory.dart';
import '../data/ml/ml_kit_ocr_service.dart';
import '../data/ml/tesseract_ocr_service.dart';
import '../data/repo/page_repo.dart';
import '../domain/repo_interface/page_repo_interface.dart';
import '../presentation/screens/home_screen/cubit/home_cubit.dart';

final locator = GetIt.instance;

Future<void> setupDependencyInjection() async {
  locator.registerLazySingleton<Logger>(() => Logger());

  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  locator.registerLazySingleton<PageDao>(() => PageDao(locator<AppDatabase>()));

  locator.registerLazySingleton<DocDao>(() => DocDao(locator<AppDatabase>()));

  locator.registerLazySingleton<StorageService>(() => StorageService());

  locator.registerLazySingleton<OcrService>(
    () => MlKitOcrService(),
    instanceName: 'mlKit',
  );

  locator.registerLazySingleton<OcrService>(
    () => TesseractOcrService(),
    instanceName: 'tesseract',
  );

  locator.registerLazySingleton<OcrServiceFactory>(
    () => OcrServiceFactory(
      mlKit: locator<OcrService>(instanceName: 'mlKit'),
      tesseract: locator<OcrService>(instanceName: 'tesseract'),
    ),
  );

  locator.registerLazySingleton<PageRepoInterface>(
    () => PageRepo(
      pageDao: locator<PageDao>(),
      storageService: locator<StorageService>(),
      ocrServiceFactory: locator<OcrServiceFactory>(),
      logger: locator<Logger>(),
    ),
  );

  locator.registerLazySingleton<DocRepoInterface>(
    () => DocRepo(
      docDao: locator<DocDao>(),
      pageDao: locator<PageDao>(),
      storageService: locator<StorageService>(),
    ),
  );

  locator.registerFactory<HomeCubit>(
    () => HomeCubit(docRepo: locator<DocRepoInterface>()),
  );
}
