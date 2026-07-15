import 'package:flutter/material.dart';

class AdminLibraryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const AdminLibraryDetailsScreen({
    super.key,
    required this.item,
  });

  String value(String key) {
    final raw = item[key];
    if (raw == null) return '';
    final text = raw.toString().trim();
    if (text == 'null') return '';
    return text;
  }

  bool boolValue(String key) {
    final raw = item[key];
    return raw == true || raw == 1 || raw.toString() == '1';
  }

  String typeLabel(String type) {
    switch (type) {
      case 'article':
        return 'Article';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'meditation':
        return 'Meditation';
      case 'pdf':
        return 'PDF Document';
      default:
        return 'Resource';
    }
  }

  IconData iconForType(String type) {
    switch (type) {
      case 'article':
        return Icons.article_rounded;
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = value('type');
    final title = value('title');
    final description = value('description');
    final content = value('content');
    final externalUrl = value('external_url');
    final filePath = value('file_path');
    final thumbnailPath = value('thumbnail_path');
    final duration = value('duration_seconds');
    final sortOrder = value('sort_order');

    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, title),
                const SizedBox(height: 28),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFE8F1FF),
                          child: Icon(
                            iconForType(type),
                            color: const Color(0xFF0F3D84),
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          typeLabel(type).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2F61D2),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          title.isEmpty ? 'Untitled Resource' : title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0F3D84),
                            fontSize: 27,
                            height: 1.15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (description.isNotEmpty)
                        _section(
                          title: 'Description',
                          value: description,
                        ),
                      if (content.isNotEmpty)
                        _section(
                          title: 'Content',
                          value: content,
                        ),
                      if (externalUrl.isNotEmpty)
                        _section(
                          title: 'External URL',
                          value: externalUrl,
                        ),
                      if (filePath.isNotEmpty)
                        _section(
                          title: 'File Path',
                          value: filePath,
                        ),
                      if (thumbnailPath.isNotEmpty)
                        _section(
                          title: 'Thumbnail',
                          value: thumbnailPath,
                        ),
                      if (duration.isNotEmpty && duration != '0')
                        _section(
                          title: 'Duration',
                          value: '$duration seconds',
                        ),
                      _section(
                        title: 'Required',
                        value: boolValue('is_required') ? 'Yes' : 'No',
                      ),
                      _section(
                        title: 'Visible',
                        value: boolValue('is_active') ? 'Yes' : 'No',
                      ),
                      if (sortOrder.isNotEmpty)
                        _section(
                          title: 'Sort Order',
                          value: sortOrder,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, String title) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Resource\nPreview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17213A),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Gradient extends StatelessWidget {
  final Widget child;

  const _Gradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3D84),
            Color(0xFF2F61D2),
            Color(0xFF5A5CF6),
          ],
        ),
      ),
      child: child,
    );
  }
}