import 'package:glyph/domain/models/page_model.dart';

import '../../utils/result_pattern.dart';

abstract interface class PageRepoInterface {
  Future<Result<PageModel>> createPage({required int docId});
  Future<Result<List<PageModel>>> readPages({
    required int docId,
    String? search,
  }); // поиск по словам в text
  Future<Result<PageModel>> editText({
    required int pageId,
    required String newText,
  });
  Future<Result<PageModel>> resetText({required int pageId});
  Future<Result<void>> deletePage({required int pageId});
  Future<Result<PageModel>> movePage({
    required int newPosition,
    required int newDocId,
    required int pageId,
  });
}
