import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/models/page_model.dart';
import '../../widgets/card.dart';
import '../../widgets/search_bar.dart';
import 'cubit/doc_cubit.dart';
import 'cubit/doc_state.dart';

class DocScreen extends StatelessWidget {
  const DocScreen({
    required this.docId,
    required this.docName,
    this.onEditPage,
    super.key,
  });

  final int docId;
  final String docName;
  final ValueChanged<PageModel>? onEditPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docName, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchField(
                hintText: 'Поиск по страницам',
                onChanged: (query) {
                  context.read<DocCubit>().searchDocs(query);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<DocCubit, DocState>(
                builder: (context, state) {
                  if (state is DocLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DocError) {
                    return _ErrorView(
                      message: state.error,
                      onRetry: () {
                        context.read<DocCubit>().refresh();
                      },
                    );
                  }

                  if (state is DocLoaded) {
                    if (state.pages.isEmpty) {
                      return _EmptyView(
                        hasSearch: state.search?.trim().isNotEmpty ?? false,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 88),
                      itemCount: state.pages.length,
                      itemBuilder: (context, index) {
                        final page = state.pages[index];

                        return ListItemCard(
                          key: ValueKey(page.id),
                          title: 'Страница ${page.position + 1}',
                          subtitle: _pagePreview(page),
                          leading: _PageThumbnail(imagePath: page.imagePath),
                          onTap: () => onEditPage?.call(page),
                          trailing: PopupMenuButton<_PageAction>(
                            tooltip: 'Действия со страницей',
                            onSelected: (action) {
                              switch (action) {
                                case _PageAction.edit:
                                  onEditPage?.call(page);

                                case _PageAction.resetText:
                                  _confirmResetText(context, page);

                                case _PageAction.delete:
                                  _confirmDeletePage(context, page);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _PageAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Редактировать текст'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: _PageAction.resetText,
                                child: ListTile(
                                  leading: Icon(Icons.restart_alt),
                                  title: Text('Сбросить текст'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: _PageAction.delete,
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Удалить страницу'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPage(context),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Добавить страницу'),
      ),
    );
  }

  String _pagePreview(PageModel page) {
    final text = page.text.trim().isNotEmpty
        ? page.text.trim()
        : page.recognizedText.trim();

    if (text.isEmpty) {
      return 'Текст отсутствует';
    }

    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _addPage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Выбрать из галереи'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    try {
      final image = await ImagePicker().pickImage(source: source);

      if (image == null || !context.mounted) return;

      await context.read<DocCubit>().createPage(File(image.path));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить страницу: $error')),
      );
    }
  }

  Future<void> _confirmDeletePage(BuildContext context, PageModel page) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить страницу?'),
        content: Text(
          'Страница ${page.position + 1} будет удалена вместе с изображением.',
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
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<DocCubit>().deletePage(page.id);
  }

  Future<void> _confirmResetText(BuildContext context, PageModel page) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить текст?'),
        content: const Text(
          'Отредактированный текст будет заменён исходным результатом распознавания.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<DocCubit>().resetText(page.id);
  }
}

enum _PageAction { edit, resetText, delete }

class _PageThumbnail extends StatelessWidget {
  const _PageThumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath),
        width: 56,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 56,
            height: 72,
            child: Icon(Icons.broken_image_outlined),
          );
        },
      ),
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
              hasSearch ? Icons.search_off : Icons.description_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'Страницы не найдены'
                  : 'В документе пока нет страниц',
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 8),
              const Text(
                'Добавь изображение, чтобы распознать текст.',
                textAlign: TextAlign.center,
              ),
            ],
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
