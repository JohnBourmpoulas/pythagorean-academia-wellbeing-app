import 'package:flutter/material.dart';

import '../../../repositories/library_repository.dart';
import 'admin_library_details_screen.dart';
import 'admin_library_form_screen.dart';

class AdminLibraryScreen extends StatefulWidget {
  const AdminLibraryScreen({super.key});

  @override
  State<AdminLibraryScreen> createState() => _AdminLibraryScreenState();
}

class _AdminLibraryScreenState extends State<AdminLibraryScreen> {
  final LibraryRepository repository = LibraryRepository();

  bool isLoading = true;
  String? errorMessage;

  String selectedType = 'all';
  List<Map<String, dynamic>> items = [];

  final filters = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Articles', 'value': 'article'},
    {'label': 'Videos', 'value': 'video'},
    {'label': 'Audio', 'value': 'audio'},
    {'label': 'Meditations', 'value': 'meditation'},
    {'label': 'PDF', 'value': 'pdf'},
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await repository.getAdminLibraryItems(type: selectedType);

      if (!mounted) return;

      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> selectType(String type) async {
    if (selectedType == type) return;

    setState(() {
      selectedType = type;
    });

    await loadItems();
  }

  Future<void> deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete resource?'),
        content: Text(
          'This will permanently delete "${item['title'] ?? 'this item'}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await repository.deleteLibraryItem(
        int.parse(item['id'].toString()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource deleted')),
      );

      loadItems();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> toggleItem(Map<String, dynamic> item) async {
    final id = int.parse(item['id'].toString());
    final isActive = item['is_active'] == true ||
        item['is_active'] == 1 ||
        item['is_active'].toString() == '1';

    try {
      await repository.toggleLibraryItem(
        id: id,
        isActive: !isActive,
      );

      loadItems();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
        return 'PDF';
      default:
        return 'Resource';
    }
  }

  Future<void> openForm({Map<String, dynamic>? item}) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminLibraryFormScreen(item: item),
      ),
    );

    if (changed == true) {
      loadItems();
    }
  }

  Future<void> openDetails(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminLibraryDetailsScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadItems,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 26),
                  _filters(),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (items.isEmpty)
                      _messageCard('No resources found')
                    else
                      ...items.map(_itemCard),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2F61D2),
        onPressed: () => openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Resource',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _topBar() {
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
            'Library\nManagement',
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

  Widget _filters() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final label = filter['label']!;
          final value = filter['value']!;
          final selected = selectedType == value;

          return GestureDetector(
            onTap: () => selectType(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFF2F61D2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF2F61D2) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Untitled resource';
    final description = item['description']?.toString() ?? '';
    final active = item['is_active'] == true ||
        item['is_active'] == 1 ||
        item['is_active'].toString() == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE8F1FF),
                child: Icon(
                  iconForType(type),
                  color: const Color(0xFF0F3D84),
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel(type).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2F61D2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F3D84),
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: active,
                onChanged: (_) => toggleItem(item),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openDetails(item),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openForm(item: item),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => deleteItem(item),
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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