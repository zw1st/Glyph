import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/doc_model.dart';
import '../../../utils/di.dart';
import '../../widgets/card.dart';
import '../../widgets/search_bar.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.onDocTap, super.key});

  final ValueChanged<DocModel>? onDocTap;

  @override
  Widget build(BuildContext context) {
    return _HomeView(onDocTap: onDocTap);
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({this.onDocTap});

  final ValueChanged<DocModel>? onDocTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои документы')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchField(
                hintText: 'Поиск документов',
                onChanged: (query) {
                  context.read<HomeCubit>().searchDocs(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HomeError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<HomeCubit>().refresh();
                      },
                    );
                  }

                  if (state is HomeLoaded) {
                    if (state.docs.isEmpty) {
                      return _EmptyView(
                        hasSearch: state.searchQuery.isNotEmpty,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: state.docs.length,
                      itemBuilder: (context, index) {
                        final doc = state.docs[index];

                        return ListItemCard(
                          key: ValueKey(doc.id),
                          title: doc.name,
                          onTap: () => onDocTap?.call(doc),
                          onRename: () {
                            _showRenameDialog(context, doc);
                          },
                          onDelete: () {
                            _showDeleteDialog(context, doc);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        tooltip: 'Добавить документ',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final name = await _showNameDialog(
      context,
      title: 'Новый документ',
      confirmText: 'Создать',
    );

    if (name == null || !context.mounted) return;

    await context.read<HomeCubit>().createDoc(name);
  }

  Future<void> _showRenameDialog(BuildContext context, DocModel doc) async {
    final name = await _showNameDialog(
      context,
      title: 'Переименовать документ',
      confirmText: 'Сохранить',
      initialValue: doc.name,
    );

    if (name == null || !context.mounted) return;

    await context.read<HomeCubit>().renameDoc(docId: doc.id, newName: name);
  }

  Future<void> _showDeleteDialog(BuildContext context, DocModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить документ?'),
          content: Text(
            'Документ «${doc.name}» и все его страницы будут удалены.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<HomeCubit>().deleteDoc(docId: doc.id);
  }

  Future<String?> _showNameDialog(
    BuildContext context, {
    required String title,
    required String confirmText,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _NameDialog(
        title: title,
        confirmText: confirmText,
        initialValue: initialValue,
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirmText,
    required this.initialValue,
  });

  final String title;
  final String confirmText;
  final String initialValue;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();

    if (value.isNotEmpty) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Название',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmText)),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.folder_open_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'Документы не найдены' : 'Пока нет документов',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              hasSearch
                  ? 'Попробуй изменить поисковый запрос'
                  : 'Нажми «+», чтобы создать первый документ',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Не удалось загрузить документы'),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
