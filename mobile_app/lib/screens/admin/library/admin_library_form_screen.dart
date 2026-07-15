import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../repositories/library_repository.dart';

class AdminLibraryFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;

  const AdminLibraryFormScreen({
    super.key,
    this.item,
  });

  bool get isEdit => item != null;

  @override
  State<AdminLibraryFormScreen> createState() => _AdminLibraryFormScreenState();
}

class _AdminLibraryFormScreenState extends State<AdminLibraryFormScreen> {
  final LibraryRepository repository = LibraryRepository();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final contentController = TextEditingController();
  final youtubeController = TextEditingController();
  final durationController = TextEditingController();
  final sortOrderController = TextEditingController();

  String selectedType = 'article';
  String? uploadedFilePath;
  String? uploadedFileName;

  bool isRequired = false;
  bool isActive = true;
  bool isSaving = false;
  bool isUploading = false;

  final types = const [
    {'label': 'Article', 'value': 'article'},
    {'label': 'Video', 'value': 'video'},
    {'label': 'Audio', 'value': 'audio'},
    {'label': 'Meditation', 'value': 'meditation'},
    {'label': 'PDF', 'value': 'pdf'},
  ];

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item != null) {
      selectedType = item['type']?.toString() ?? 'article';
      titleController.text = item['title']?.toString() ?? '';
      descriptionController.text = item['description']?.toString() ?? '';
      contentController.text = item['content']?.toString() ?? '';
      youtubeController.text = item['external_url']?.toString() ?? '';
      uploadedFilePath = item['file_path']?.toString();
      durationController.text = item['duration_seconds']?.toString() ?? '';
      sortOrderController.text = item['sort_order']?.toString() ?? '0';

      if (uploadedFilePath != null && uploadedFilePath!.trim().isNotEmpty) {
        uploadedFileName = uploadedFilePath!.split('/').last;
      }

      isRequired = item['is_required'] == true ||
          item['is_required'] == 1 ||
          item['is_required'].toString() == '1';

      isActive = item['is_active'] == true ||
          item['is_active'] == 1 ||
          item['is_active'].toString() == '1';
    } else {
      sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    contentController.dispose();
    youtubeController.dispose();
    durationController.dispose();
    sortOrderController.dispose();
    super.dispose();
  }

  bool get isVideo => selectedType == 'video';
  bool get isArticle => selectedType == 'article';
  bool get needsFile =>
      selectedType == 'audio' ||
          selectedType == 'meditation' ||
          selectedType == 'pdf';

  String get uploadType {
    switch (selectedType) {
      case 'audio':
      case 'meditation':
        return 'audio';
      case 'pdf':
        return 'pdf';
      default:
        return 'file';
    }
  }

  String get uploadButtonText {
    switch (selectedType) {
      case 'audio':
        return uploadedFilePath == null ? 'Choose Audio File' : 'Change Audio File';
      case 'meditation':
        return uploadedFilePath == null
            ? 'Choose Meditation Audio'
            : 'Change Meditation Audio';
      case 'pdf':
        return uploadedFilePath == null ? 'Choose PDF File' : 'Change PDF File';
      default:
        return 'Choose File';
    }
  }

  String get helperText {
    switch (selectedType) {
      case 'article':
        return 'Article resources contain written content inside the app.';
      case 'video':
        return 'Videos use only a YouTube link. No video upload is needed.';
      case 'audio':
        return 'Audio resources use an uploaded audio file from your device.';
      case 'meditation':
        return 'Meditations use an uploaded guided-audio file.';
      case 'pdf':
        return 'PDF resources use an uploaded PDF file.';
      default:
        return '';
    }
  }

  IconData iconForSelectedType() {
    switch (selectedType) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Future<void> pickAndUploadFile() async {
    FileType fileType = FileType.any;
    List<String>? allowedExtensions;

    if (selectedType == 'audio' || selectedType == 'meditation') {
      fileType = FileType.custom;
      allowedExtensions = ['mp3', 'wav', 'm4a'];
    } else if (selectedType == 'pdf') {
      fileType = FileType.custom;
      allowedExtensions = ['pdf'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final selectedFile = result.files.single;

    if (selectedFile.path == null) {
      showMessage('Could not read selected file');
      return;
    }

    setState(() => isUploading = true);

    try {
      final path = await repository.uploadLibraryFile(
        file: File(selectedFile.path!),
        type: uploadType,
      );

      if (!mounted) return;

      setState(() {
        uploadedFilePath = path;
        uploadedFileName = selectedFile.name;
        isUploading = false;
      });

      showMessage('File uploaded successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() => isUploading = false);

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> save() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      showMessage('Title is required');
      return;
    }

    if (isArticle && contentController.text.trim().isEmpty) {
      showMessage('Article content is required');
      return;
    }

    if (isVideo && youtubeController.text.trim().isEmpty) {
      showMessage('YouTube link is required for video resources');
      return;
    }

    if (needsFile && (uploadedFilePath == null || uploadedFilePath!.isEmpty)) {
      showMessage('Please choose and upload a file first');
      return;
    }

    setState(() => isSaving = true);

    final payload = {
      if (widget.isEdit) 'id': widget.item!['id'],
      'type': selectedType,
      'title': title,
      'description': descriptionController.text.trim(),
      'content': isArticle ? contentController.text.trim() : '',
      'external_url': isVideo ? youtubeController.text.trim() : '',
      'file_path': needsFile ? uploadedFilePath : '',
      'thumbnail_path': '',
      'duration_seconds': int.tryParse(durationController.text.trim()) ?? 0,
      'sort_order': int.tryParse(sortOrderController.text.trim()) ?? 0,
      'is_required': isRequired ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };

    try {
      final ok = widget.isEdit
          ? await repository.updateLibraryItem(payload)
          : await repository.createLibraryItem(payload);

      if (!mounted) return;

      if (ok) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void changeType(String value) {
    setState(() {
      selectedType = value;

      if (value == 'video') {
        uploadedFilePath = null;
        uploadedFileName = null;
        contentController.clear();
      } else if (value == 'article') {
        uploadedFilePath = null;
        uploadedFileName = null;
        youtubeController.clear();
        durationController.clear();
      } else {
        youtubeController.clear();
        contentController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 28),
                _formCard(),
              ],
            ),
          ),
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
        Expanded(
          child: Text(
            widget.isEdit ? 'Edit\nResource' : 'Add\nResource',
            style: const TextStyle(
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

  Widget _formCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _typeSelector(),
          const SizedBox(height: 18),
          _helperBox(),
          const SizedBox(height: 22),
          _field(
            controller: titleController,
            label: 'Title',
            icon: Icons.title_rounded,
          ),
          _field(
            controller: descriptionController,
            label: 'Description',
            icon: Icons.description_rounded,
            maxLines: 3,
          ),
          if (isArticle)
            _field(
              controller: contentController,
              label: 'Article Content',
              icon: Icons.article_rounded,
              maxLines: 8,
            ),
          if (isVideo)
            _field(
              controller: youtubeController,
              label: 'YouTube Link',
              icon: Icons.play_circle_fill_rounded,
              keyboardType: TextInputType.url,
            ),
          if (needsFile) _uploadBox(),
          if (selectedType == 'audio' ||
              selectedType == 'meditation' ||
              selectedType == 'video')
            _field(
              controller: durationController,
              label: 'Duration Seconds',
              icon: Icons.timer_rounded,
              keyboardType: TextInputType.number,
            ),
          _field(
            controller: sortOrderController,
            label: 'Sort Order',
            icon: Icons.sort_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          _switchTile(
            title: 'Required Resource',
            subtitle: 'Participant should complete/view this item',
            value: isRequired,
            onChanged: (v) => setState(() => isRequired = v),
          ),
          _switchTile(
            title: 'Visible',
            subtitle: 'Show this resource to participants',
            value: isActive,
            onChanged: (v) => setState(() => isActive = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSaving || isUploading ? null : save,
              icon: Icon(widget.isEdit ? Icons.save_rounded : Icons.add_rounded),
              label: Text(
                isSaving
                    ? 'Saving...'
                    : widget.isEdit
                    ? 'Save Changes'
                    : 'Create Resource',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F61D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resource Type',
          style: TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types.map((type) {
            final label = type['label']!;
            final value = type['value']!;
            final selected = selectedType == value;

            return GestureDetector(
              onTap: () => changeType(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2F61D2)
                      : const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? Icons.check_rounded : iconForSelectedType(),
                      color: selected ? Colors.white : const Color(0xFF2F61D2),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color:
                        selected ? Colors.white : const Color(0xFF0F3D84),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _helperBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconForSelectedType(), color: const Color(0xFF2F61D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              helperText,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedType == 'pdf'
                ? 'PDF File'
                : selectedType == 'meditation'
                ? 'Meditation Audio File'
                : 'Audio File',
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            uploadedFileName == null
                ? 'No file selected'
                : 'Selected: $uploadedFileName',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUploading ? null : pickAndUploadFile,
              icon: isUploading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(
                isUploading ? 'Uploading...' : uploadButtonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2F61D2)),
          filled: true,
          fillColor: const Color(0xFFF4F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
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