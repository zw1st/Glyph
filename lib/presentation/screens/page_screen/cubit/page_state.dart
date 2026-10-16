import 'package:glyph/domain/models/page_model.dart';

sealed class PageState {}

class PageLoading extends PageState {}

class PageLoaded extends PageState {
  final PageModel pageModel;

  PageLoaded(this.pageModel);
}

class PageError extends PageState {
  final String error;

  PageError(this.error);
}
