import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _imagesDirectoryName = 'images';

  final Random _random = Random.secure();

  Future<Directory> _getImagesDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      p.join(appDirectory.path, _imagesDirectoryName),
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    return imagesDirectory;
  }

  /// Копирует изображение в приватное хранилище приложения.
  /// Возвращает абсолютный путь к сохранённому файлу.
  Future<String> saveImage({required File source}) async {
    if (!await source.exists()) {
      throw FileSystemException('Исходное изображение не найдено', source.path);
    }

    final extension = p.extension(source.path).toLowerCase();

    if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
      throw UnsupportedError('Поддерживаются только изображения JPEG и PNG');
    }

    final directory = await _getImagesDirectory();

    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_'
        '${_random.nextInt(1 << 32)}$extension';

    final destination = File(p.join(directory.path, fileName));

    await source.copy(destination.path);

    return destination.path;
  }

  /// Удаляет файл, если он существует.
  Future<void> deleteFile({required String path}) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteFiles({required Iterable<String> paths}) async {
    for (final path in paths) {
      await deleteFile(path: path);
    }
  }

  Future<bool> fileExists({required String path}) {
    return File(path).exists();
  }

  Future<String> exportText({
    required String fileName,
    required String text,
  }) async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final exportDirectory = Directory(p.join(appDirectory.path, 'exports'));

    await exportDirectory.create(recursive: true);

    // Убираем путь из имени файла и заменяем расширение на .txt.
    final safeName = p
        .basenameWithoutExtension(fileName)
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');

    final file = File(p.join(exportDirectory.path, '$safeName.txt'));

    await file.writeAsString(text, encoding: utf8, flush: true);

    return file.path;
  }
}
