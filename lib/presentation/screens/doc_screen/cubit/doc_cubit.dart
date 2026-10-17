import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:glyph/domain/models/page_model.dart';
import 'package:glyph/domain/repo_interface/page_repo_interface.dart';

import '../../../../utils/result_pattern.dart';
import 'doc_state.dart';

class DocCubit extends Cubit<DocState> {
  String _searchQuery = '';
  final int _docId;
  final PageRepoInterface _pageRepo;

  DocCubit({required pageRepo, required int docId})
    : _pageRepo = pageRepo,
      _docId = docId,
      super(DocLoading());

  Future<void> loadPages() async {
    emit(DocLoading());
    await _fetchPages();
  }

  Future<void> searchDocs(String query) async {
    _searchQuery = query.trim();
    await _fetchPages();
  }

  Future<void> refresh() async {
    await _fetchPages();
  }

  Future<void> createPage(File sourceFile) async {
    final page = await _pageRepo.createPage(
      docId: _docId,
      sourceFile: sourceFile,
    );

    switch (page) {
      case Ok<PageModel>():
        await _fetchPages();
      case Error<PageModel>(:final error):
        emit(DocError(error.toString()));
    }
  }

  Future<void> deletePage(int pageId) async {
    final result = await _pageRepo.deletePage(pageId: pageId);

    switch (result) {
      case Ok<void>():
        await _fetchPages();
      case Error<void>(:final error):
        emit(DocError(error.toString()));
    }
  }

  Future<void> resetText(int pageId) async {
    final page = await _pageRepo.resetText(pageId: pageId);
    switch (page) {
      case Ok<PageModel>():
        await _fetchPages();
      case Error<PageModel>(:final error):
        emit(DocError(error.toString()));
    }
  }

  Future<void> _fetchPages() async {
    final pages = await _pageRepo.readPages(
      docId: _docId,
      search: _searchQuery,
    );
    switch (pages) {
      case Ok<List<PageModel>>(:final value):
        emit(
          DocLoaded(
            docId: _docId,
            pages: value,
            search: _searchQuery.isEmpty ? null : _searchQuery,
          ),
        );
      case Error<List<PageModel>>(:final error):
        emit(DocError(error.toString()));
    }
  }
}
