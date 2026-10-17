import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glyph/presentation/screens/page_screen/cubit/page_state.dart';

import '../../../../domain/models/page_model.dart';
import '../../../../domain/repo_interface/page_repo_interface.dart';
import '../../../../utils/result_pattern.dart';

class PageCubit extends Cubit<PageState> {
  PageCubit({required PageRepoInterface pageRepo, required int pageId})
    : _pageRepo = pageRepo,
      _pageId = pageId,
      super(PageLoading());

  final PageRepoInterface _pageRepo;
  final int _pageId;

  Future<void> loadPage() async {
    emit(PageLoading());
    await _fetchPage();
  }

  Future<void> saveText(String newText) async {
    final result = await _pageRepo.editText(pageId: _pageId, newText: newText);

    switch (result) {
      case Ok<PageModel>(:final value):
        emit(PageLoaded(value));

      case Error<PageModel>(:final error):
        emit(PageError(error.toString()));
    }
  }

  Future<void> resetText() async {
    final result = await _pageRepo.resetText(pageId: _pageId);

    switch (result) {
      case Ok<PageModel>(:final value):
        emit(PageLoaded(value));

      case Error<PageModel>(:final error):
        emit(PageError(error.toString()));
    }
  }

  Future<void> _fetchPage() async {
    final result = await _pageRepo.readPage(pageId: _pageId);

    switch (result) {
      case Ok<PageModel>(:final value):
        emit(PageLoaded(value));

      case Error<PageModel>(:final error):
        emit(PageError(error.toString()));
    }
  }
}
