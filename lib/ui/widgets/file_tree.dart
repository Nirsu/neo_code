import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/project/file_node.dart';
import 'package:neo_code/project/file_list_provider.dart';
import 'package:neo_code/project/active_file_provider.dart';

class FileTree extends ConsumerWidget {
  final String projectPath;

  const FileTree({super.key, required this.projectPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    final filesAsync = ref.watch(fileListProvider(projectPath));

    return filesAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: neo.textSecondary,
          ),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: TextStyle(color: neo.textSecondary, fontSize: 12),
        ),
      ),
      data: (nodes) {
        if (nodes.isEmpty) {
          return Center(
            child: Text(
              t.ui.fileTree.emptyFolder,
              style: TextStyle(color: neo.textSecondary, fontSize: 13),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: nodes.length,
          itemBuilder: (_, index) => _FileTreeNode(
            node: nodes[index],
            depth: 0,
          ),
        );
      },
    );
  }
}

class _FileTreeNode extends ConsumerStatefulWidget {
  final FileNode node;
  final int depth;

  const _FileTreeNode({required this.node, required this.depth});

  @override
  ConsumerState<_FileTreeNode> createState() => _FileTreeNodeState();
}

class _FileTreeNodeState extends ConsumerState<_FileTreeNode> {
  bool _isExpanded = false;
  List<FileNode> _lazyChildren = [];
  bool _isLoadingLazy = false;

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    final node = widget.node;
    final indent = widget.depth * 16.0;

    if (node.isDirectory) {
      final children = node.isLazyLoad ? _lazyChildren : node.children;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTile(node, neo, indent),
          if (_isExpanded) ...[
            if (_isLoadingLazy)
              Padding(
                padding: EdgeInsets.only(left: indent + 28),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: neo.textSecondary,
                  ),
                ),
              ),
            ...children.map(
              (child) => _FileTreeNode(
                node: child,
                depth: widget.depth + 1,
              ),
            ),
          ],
        ],
      );
    }

    return _buildTile(node, neo, indent);
  }

  Widget _buildTile(FileNode node, NeoTheme neo, double indent) {
    final activeFilePath = ref.watch(activeFileProvider);
    final isActive = !node.isDirectory && activeFilePath == node.path;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (node.isDirectory) {
            if (!node.isLazyLoad || _lazyChildren.isNotEmpty) {
              setState(() => _isExpanded = !_isExpanded);
              return;
            }

            if (_isLoadingLazy) return;

            setState(() {
              _isExpanded = true;
              _isLoadingLazy = true;
            });

            try {
              final children = await ref.read(
                fileListProvider(node.path).future,
              );
              setState(() {
                _lazyChildren = children;
                _isLoadingLazy = false;
              });
            } catch (_) {
              setState(() => _isLoadingLazy = false);
            }
          } else {
            ref.read(activeFileProvider.notifier).openFile(node.path);
          }
        },
        child: Container(
          height: 28,
          padding: EdgeInsets.only(left: indent + 8),
          color: isActive ? neo.hoverBg : Colors.transparent,
          child: Row(
            children: [
              if (node.isDirectory)
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 16,
                  color: neo.textSecondary,
                )
              else
                const SizedBox(width: 16),
              const SizedBox(width: 4),
              Icon(
                node.isDirectory
                    ? (_isExpanded ? Icons.folder_open : Icons.folder)
                    : _fileIcon(node.name),
                size: 16,
                color: node.isHidden ? neo.textSecondary : neo.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  node.name,
                  style: TextStyle(
                    color:
                        node.isHidden ? neo.textSecondary : neo.textPrimary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'dart' => Icons.code,
      'yaml' || 'yml' => Icons.settings,
      'json' => Icons.data_object,
      'md' => Icons.description_outlined,
      'txt' => Icons.article_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}
