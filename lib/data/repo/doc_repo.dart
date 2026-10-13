import 'package:glyph/data/file_storage/storage_service.dart';

import '../../domain/models/doc_model.dart';
import '../../domain/repo_interface/doc_repo_interface.dart';
import '../../utils/result_pattern.dart';
import '../database/app_database.dart';
import '../database/dao/doc_dao.dart';
import '../database/dao/page_dao.dart';

class DocRepo implements DocRepoInterface {
  DocRepo({
    required DocDao docDao,
    required PageDao pageDao,
    required StorageService storageService,
  }) : _docDao = docDao,
       _pageDao = pageDao,
       _storageService = storageService,
       _clock = DateTime.now;

  final DocDao _docDao;
  final PageDao _pageDao;
  final StorageService _storageService;
  final DateTime Function() _clock;

  @override
  Future<Result<DocModel>> createDoc({required String name}) async {
    try {
      final id = await _docDao.createDoc(name: name, createdAt: _clock());

      final row = await _docDao.getDocById(id);
      if (row == null) {
        throw StateError('Created document was not found');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<DocModel>>> readDocs({String? search}) async {
    try {
      final rows = await _docDao.readDocs(search: search);
      return Result.ok(rows.map(_toModel).toList());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<DocModel>> renameDoc({
    required int docId,
    required String newName,
  }) async {
    try {
      final updated = await _docDao.renameDoc(docId: docId, newName: newName);

      if (!updated) {
        throw StateError('Document $docId was not found');
      }

      final row = await _docDao.getDocById(docId);
      if (row == null) {
        throw StateError('Document $docId was not found after rename');
      }

      return Result.ok(_toModel(row));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteDoc({required int docId}) async {
    try {
      // Сохраняем пути до удаления строк страниц каскадом.
      final pages = await _pageDao.readPages(docId: docId);
      final paths = pages.map((page) => page.imagePath).toList();

      final deleted = await _docDao.deleteDoc(docId);
      if (deleted == 0) {
        throw StateError('Document $docId was not found');
      }

      // SQLite уже удалил документ и связанные строки страниц.
      await _storageService.deleteFiles(paths: paths);

      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  DocModel _toModel(DocRow row) {
    return DocModel(id: row.id, name: row.name, creationDate: row.createdAt);
  }
}
