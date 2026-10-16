import '../../../../domain/models/doc_model.dart';

sealed class HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  HomeLoaded({required this.docs, required this.searchQuery});

  final List<DocModel> docs;
  final String searchQuery;
}

final class HomeError extends HomeState {
  HomeError(this.message);

  final String message;
}
