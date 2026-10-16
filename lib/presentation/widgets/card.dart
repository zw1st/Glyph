import 'package:flutter/material.dart';

class ListItemCard extends StatelessWidget {
  const ListItemCard({
    required this.title,
    required this.onTap,
    this.onRename,
    this.onDelete,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: leading ?? const Icon(Icons.folder_outlined, size: 32),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing ?? _buildActions(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActions() {
    if (onRename == null && onDelete == null) {
      return const Icon(Icons.chevron_right);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRename != null)
          IconButton(
            tooltip: 'Переименовать',
            onPressed: onRename,
            icon: const Icon(Icons.edit_outlined),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Удалить',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }
}
