import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/page_model.dart';
import 'cubit/page_cubit.dart';
import 'cubit/page_state.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({required this.pageId, super.key});

  final int pageId;

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  final TextEditingController _textController = TextEditingController();

  bool _isInitialized = false;
  bool _isDirty = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateController(PageModel page) {
    if (_isInitialized && !_isDirty) {
      return;
    }

    if (!_isInitialized) {
      _textController.text = page.text;
      _isInitialized = true;
      _isDirty = false;
    }
  }

  Future<void> _saveText() async {
    final cubit = context.read<PageCubit>();
    final state = cubit.state;

    if (state is! PageLoaded) return;

    await cubit.saveText(_textController.text.trim());

    if (!mounted) return;

    if (cubit.state is PageLoaded) {
      setState(() {
        _isDirty = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Текст сохранён')));
    } else if (cubit.state is PageError) {
      final error = (cubit.state as PageError).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить текст: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageCubit, PageState>(
      listener: (context, state) {
        if (state is PageLoaded) {
          _updateController(state.pageModel);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Страница'),
            actions: [
              if (state is PageLoaded)
                IconButton(
                  tooltip: 'Сохранить текст',
                  onPressed: _isDirty ? _saveText : null,
                  icon: const Icon(Icons.save_outlined),
                ),
            ],
          ),
          body: switch (state) {
            PageLoading() => const Center(child: CircularProgressIndicator()),
            PageError(:final error) => _buildError(context, error),
            PageLoaded(:final pageModel) => _buildContent(pageModel),
          },
        );
      },
    );
  }

  Widget _buildContent(PageModel page) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Фото'),
        const SizedBox(height: 8),
        _buildImage(page.imagePath),
        const SizedBox(height: 24),

        _buildSectionTitle('Текущий текст'),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          onChanged: (_) {
            setState(() {
              _isDirty = true;
            });
          },
          minLines: 6,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Введите или исправьте текст...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _isDirty ? _saveText : null,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Распознанный текст'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            page.recognizedText.isEmpty
                ? 'Распознанный текст отсутствует'
                : page.recognizedText,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 40),
            SizedBox(height: 8),
            Text('Изображение не найдено'),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        file,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Не удалось загрузить изображение')),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<PageCubit>().loadPage(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
