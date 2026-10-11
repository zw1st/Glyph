import 'package:glyph/utils/result_pattern.dart';

import '../models/doc_model.dart';

abstract interface class DocRepoInterface {
  Future<Result<DocModel>> createDoc({required String name});
  Future<Result<List<DocModel>>> readDocs({
    String? search,
  }); // поиск по названиям доков
  Future<Result<DocModel>> renameDoc({
    required int docId,
    required String newName,
  });
  Future<Result<void>> deleteDoc({required int docId});
  Future<Result<void>> importDoc({required int docId});
}
