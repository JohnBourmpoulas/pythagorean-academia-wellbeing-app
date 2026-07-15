import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool isLoading = true;
  bool isGenerating = false;
  bool isDownloading = false;
  int? activeDocumentId;
  String? errorMessage;
  List<Map<String, dynamic>> documents = [];

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/documents/list.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load documents';
      });
      return;
    }

    setState(() {
      documents = List<Map<String, dynamic>>.from(response['documents'] ?? []);
      isLoading = false;
    });
  }

  String absoluteUrl(String path) {
    final cleanValue = path.trim();
    if (cleanValue.isEmpty) return '';

    if (cleanValue.startsWith('http://') ||
        cleanValue.startsWith('https://')) {
      return cleanValue;
    }

    final cleanPath = cleanValue.startsWith('/')
        ? cleanValue.substring(1)
        : cleanValue;

    final serverUrl = ApiConfig.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/$'), '');

    return '$serverUrl/$cleanPath';
  }

  String safeFileName(String title) {
    final cleaned = title
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_\- ]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    if (cleaned.isEmpty) {
      return 'wellness_report.pdf';
    }

    return cleaned.endsWith('.pdf') ? cleaned : '$cleaned.pdf';
  }

  int documentId(Map<String, dynamic> document) {
    return int.tryParse(document['id']?.toString() ?? '') ?? 0;
  }

  Future<File?> downloadDocumentFile(
      Map<String, dynamic> document, {
        bool openAfterDownload = false,
        bool showSuccessMessage = true,
      }) async {
    final path = document['file_path']?.toString() ?? '';
    final url = absoluteUrl(path);
    final title = document['title']?.toString() ?? 'wellness_report';
    final id = documentId(document);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document file not found')),
      );
      return null;
    }

    setState(() {
      isDownloading = true;
      activeDocumentId = id;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/pythagorean_documents');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${safeFileName(title)}';
      final file = File('${downloadsDir.path}/$fileName');

      await Dio().download(
        url,
        file.path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (!mounted) return file;

      if (showSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded successfully')),
        );
      }

      if (openAfterDownload) {
        await OpenFilex.open(file.path);
      }

      return file;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download PDF: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
          activeDocumentId = null;
        });
      }
    }
  }

  Future<void> downloadDocument(Map<String, dynamic> document) async {
    await downloadDocumentFile(
      document,
      openAfterDownload: true,
      showSuccessMessage: true,
    );
  }

  Future<void> shareDocument(Map<String, dynamic> document) async {
    final file = await downloadDocumentFile(
      document,
      openAfterDownload: false,
      showSuccessMessage: false,
    );

    if (file == null || !mounted) return;

    final title = document['title']?.toString() ?? 'Wellness Report';

    await Share.shareXFiles(
      [XFile(file.path)],
      text: title,
      subject: title,
    );
  }

  Future<void> generateReport(int months) async {
    setState(() => isGenerating = true);

    final response = await ApiService.post(
      '/participant/documents/generate.php',
      {'months': months},
      auth: true,
    );

    if (!mounted) return;

    setState(() => isGenerating = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not generate document',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document generated successfully')),
    );

    loadDocuments();
  }

  Future<void> showGenerateDialog() async {
    final months = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Generate Wellness Report',
                  style: TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _periodButton('Last 1 Month', 1),
                _periodButton('Last 3 Months', 3),
                _periodButton('Last 6 Months', 6),
                _periodButton('Last 12 Months', 12),
              ],
            ),
          ),
        );
      },
    );

    if (months != null) {
      generateReport(months);
    }
  }

  Widget _periodButton(String title, int months) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context, months),
        child: Text(title),
      ),
    );
  }

  Future<void> deleteDocument(Map<String, dynamic> document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text(
          'This will delete "${document['title'] ?? 'this document'}".',
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

    final response = await ApiService.post(
      '/participant/documents/delete.php',
      {'id': document['id']},
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not delete document',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document deleted')),
    );

    loadDocuments();
  }

  void openDocument(Map<String, dynamic> document) {
    final path = document['file_path']?.toString() ?? '';
    final url = absoluteUrl(path);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document file not found')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          title: document['title']?.toString() ?? 'Document',
          url: url,
          document: document,
          onDownload: () => downloadDocument(document),
          onShare: () => shareDocument(document),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadDocuments,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 28),
                  _generateCard(),
                  const SizedBox(height: 22),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (documents.isEmpty)
                      _messageCard('No documents generated yet')
                    else
                      ...documents.map(_documentCard),
                ],
              ),
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
        const Expanded(
          child: Text(
            'Documents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _generateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFF2F61D2),
            size: 54,
          ),
          const SizedBox(height: 14),
          const Text(
            'Generate Personal Report',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a PDF report from your program history, tasks and reflections.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : showGenerateDialog,
              icon: isGenerating
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.add_rounded),
              label: Text(isGenerating ? 'Generating...' : 'Generate Report'),
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

  Widget _documentCard(Map<String, dynamic> document) {
    final title = document['title']?.toString() ?? 'Document';
    final period = document['period_label']?.toString() ?? '';
    final createdAt = document['created_at']?.toString() ?? '';
    final id = documentId(document);
    final isActive = isDownloading && activeDocumentId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8F1FF),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF2F61D2),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => openDocument(document),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (period.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          period,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                      if (createdAt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          createdAt,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isActive)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                IconButton(
                  onPressed: () => deleteDocument(document),
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openDocument(document),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('View'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isDownloading
                      ? null
                      : () => downloadDocument(document),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isDownloading ? null : () => shareDocument(document),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                ),
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
        borderRadius: BorderRadius.circular(30),
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

class DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String url;
  final Map<String, dynamic> document;
  final Future<void> Function() onDownload;
  final Future<void> Function() onShare;

  const DocumentViewerScreen({
    super.key,
    required this.title,
    required this.url,
    required this.document,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDownload,
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SfPdfViewer.network(url),
                ),
              ),
            ],
          ),
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
