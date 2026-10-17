import 'package:bloc/bloc.dart';

import '../../../../domain/models/doc_model.dart';
import '../../../../domain/repo_interface/doc_repo_interface.dart';
import '../../../../utils/result_pattern.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required DocRepoInterface docRepo})
    : _docRepo = docRepo,
      super(HomeLoading());

  final DocRepoInterface _docRepo;

  String _searchQuery = '';

  Future<void> loadDocs() async {
    emit(HomeLoading());
    await _fetchDocs();
  }

  Future<void> searchDocs(String query) async {
    _searchQuery = query.trim();
    await _fetchDocs();
  }

  Future<void> refresh() async {
    await _fetchDocs();
  }

  Future<void> createDoc(String name) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      return;
    }

    final result = await _docRepo.createDoc(name: normalizedName);

    switch (result) {
      case Ok<DocModel>(:final value):
        await _fetchDocs();
      case Error<DocModel>(:final error):
        emit(HomeError(error.toString()));
    }
  }

  Future<void> renameDoc({required int docId, required String newName}) async {
    final normalizedName = newName.trim();

    if (normalizedName.isEmpty) {
      return;
    }

    final result = await _docRepo.renameDoc(
      docId: docId,
      newName: normalizedName,
    );

    switch (result) {
      case Ok<DocModel>():
        await _fetchDocs();
      case Error<DocModel>(:final error):
        emit(HomeError(error.toString()));
    }
  }

  Future<void> deleteDoc({required int docId}) async {
    final result = await _docRepo.deleteDoc(docId: docId);

    switch (result) {
      case Ok<void>():
        await _fetchDocs();
      case Error<void>(:final error):
        emit(HomeError(error.toString()));
    }
  }

  Future<void> _fetchDocs() async {
    final result = await _docRepo.readDocs(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    switch (result) {
      case Ok<List<DocModel>>(:final value):
        emit(HomeLoaded(docs: value, searchQuery: _searchQuery));
      case Error<List<DocModel>>(:final error):
        emit(HomeError(error.toString()));
    }
  }
}
