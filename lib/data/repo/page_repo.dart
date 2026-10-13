import 'dart:io';

import 'package:glyph/data/file_storage/storage_service.dart';
import 'package:logger/logger.dart';

import '../../domain/models/page_model.dart';
import '../../domain/repo_interface/page_repo_interface.dart';
import '../../utils/result_pattern.dart';
import '../database/app_database.dart';
import '../database/dao/page_dao.dart';

typedef PreparePage =
    Future<({String imagePath, String recognizedText})> Function(int docId);

class PageRepo implements PageRepoInterface {
  PageRepo({
    required PageDao pageDao,
    required StorageService storageService,
    required Logger logger,
    DateTime Function()? clock,
  }) : _pageDao = pageDao,
       _storageService = storageService,
       _logger = logger,
       _clock = clock ?? DateTime.now;

  final PageDao _pageDao;
  final StorageService _storageService;
  final DateTime Function() _clock;
  final Logger _logger;

  @override
  Future<Result<PageModel>> createPage({
    required int docId,
    required File sourceFile,
  }) async {
    String? imagePath;
    try {
      imagePath = await _storageService.saveImage(source: sourceFile);

      final pageId = await _pageDao.createPage(
        docId: docId,
        imagePath: imagePath,
        recognizedText: "", //TODO сделать сервис распознавания
        createdAt: _clock(),
      );

      final row = await _pageDao.getPageById(pageId);
      if (row == null) {
        throw StateError('Created page was not found');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      if (imagePath != null) {
        try {
          await _storageService.deleteFile(path: imagePath);
        } catch (_) {
          _logger.e("Не удалось удалить документ из ФХ");
        }
      }
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<PageModel>>> readPages({
    required int docId,
    String? search,
  }) async {
    try {
      final rows = await _pageDao.readPages(docId: docId, search: search);

      return Result.ok(rows.map(_toModel).toList());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PageModel>> editText({
    required int pageId,
    required String newText,
  }) async {
    try {
      final updated = await _pageDao.editText(pageId: pageId, newText: newText);

      if (!updated) {
        throw StateError('Page $pageId was not found');
      }

      final row = await _pageDao.getPageById(pageId);
      if (row == null) {
        throw StateError('Page $pageId was not found after editing');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PageModel>> resetText({required int pageId}) async {
    try {
      final updated = await _pageDao.resetText(pageId: pageId);

      if (!updated) {
        throw StateError('Page $pageId was not found');
      }

      final row = await _pageDao.getPageById(pageId);
      if (row == null) {
        throw StateError('Page $pageId was not found after reset');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deletePage({required int pageId}) async {
    try {
      final page = await _pageDao.getPageById(pageId);
      if (page == null) {
        throw StateError('Page $pageId was not found');
      }

      final deleted = await _pageDao.deletePage(pageId);
      if (deleted == 0) {
        throw StateError('Page $pageId was not deleted');
      }

      await _storageService.deleteFile(path: page.imagePath);

      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PageModel>> movePage({
    required int pageId,
    required int newPosition,
  }) async {
    try {
      final updated = await _pageDao.movePage(
        pageId: pageId,
        newPosition: newPosition,
      );

      if (!updated) {
        throw StateError('Page $pageId was not found');
      }

      final row = await _pageDao.getPageById(pageId);
      if (row == null) {
        throw StateError('Page $pageId was not found after moving');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  PageModel _toModel(PageRow row) {
    return PageModel(
      id: row.id,
      position: row.position,
      folderId: row.docId,
      imagePath: row.imagePath,
      recognizedText: row.recognizedText,
      text: row.editedText,
      createdAt: row.createdAt,
    );
  }
}
