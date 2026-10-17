import 'package:glyph/domain/models/page_model.dart';

sealed class DocState {}

class DocLoading extends DocState {}

class DocLoaded extends DocState {
  final List<PageModel> pages;
  final String? search;
  final int docId;

  DocLoaded({required this.docId, required this.pages, this.search});
}

class DocError extends DocState {
  final String error;

  DocError(this.error);
}
