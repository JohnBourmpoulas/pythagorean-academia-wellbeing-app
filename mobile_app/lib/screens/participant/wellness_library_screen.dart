import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';

class WellnessLibraryScreen extends StatefulWidget {
  const WellnessLibraryScreen({super.key});

  @override
  State<WellnessLibraryScreen> createState() => _WellnessLibraryScreenState();
}

class _WellnessLibraryScreenState extends State<WellnessLibraryScreen> {
  bool isLoading = true;
  String? errorMessage;

  String selectedType = 'all';
  List<Map<String, dynamic>> items = [];

  final List<Map<String, dynamic>> filters = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Article', 'value': 'article'},
    {'label': 'Video', 'value': 'video'},
    {'label': 'Audio', 'value': 'audio'},
    {'label': 'Meditation', 'value': 'meditation'},
    {'label': 'PDF', 'value': 'pdf'},
  ];

  @override
  void initState() {
    super.initState();
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final endpoint = selectedType == 'all'
        ? '/participant/library.php'
        : '/participant/library.php?type=$selectedType';

    final response = await ApiService.get(endpoint, auth: true);

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load library';
      });
      return;
    }

    setState(() {
      items = List<Map<String, dynamic>>.from(
        response['items'] ?? response['library'] ?? [],
      );
      isLoading = false;
    });
  }

  Future<void> selectFilter(String value) async {
    if (selectedType == value) return;

    setState(() {
      selectedType = value;
    });

    await loadLibrary();
  }

  String textValue(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return '';
    return value.toString();
  }

  IconData iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'article':
        return Icons.article_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  String labelForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'meditation':
        return 'Meditation';
      case 'pdf':
        return 'PDF';
      case 'article':
        return 'Article';
      default:
        return 'Resource';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadLibrary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  _filters(),
                  const SizedBox(height: 26),
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
                      _messageCard('No library items found')
                    else
                      ...items.map(_libraryCard),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
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
            'Wellness\nLibrary',
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
            onTap: () => selectFilter(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFF2F61D2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Color(0xFF2F61D2),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? const Color(0xFF2F61D2) : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _libraryCard(Map<String, dynamic> item) {
    final title = textValue(item, 'title');
    final description = textValue(item, 'description');
    final type = textValue(item, 'type');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(34),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LibraryItemDetailsScreen(item: item),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFE8F1FF),
              child: Icon(
                iconForType(type),
                color: const Color(0xFF0F3D84),
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelForType(type),
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title.isEmpty ? 'Untitled resource' : title,
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 23,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
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

class LibraryItemDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const LibraryItemDetailsScreen({
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

  String absoluteUrl(String pathOrUrl) {
    final value = pathOrUrl.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final serverUrl = ApiConfig.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/$'), '');

    final cleanPath = value.startsWith('/') ? value.substring(1) : value;

    return '$serverUrl/$cleanPath';
  }

  IconData iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'article':
        return Icons.article_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = value('title');
    final description = value('description');
    final content = value('content');
    final type = value('type');
    final externalUrl = value('external_url');
    final filePath = value('file_path');

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFFE8F1FF),
                          child: Icon(
                            iconForType(type),
                            color: const Color(0xFF0F3D84),
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2F61D2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title.isEmpty ? 'Untitled resource' : title,
                        style: const TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 17,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (type == 'video')
                        _VideoBlock(youtubeUrl: externalUrl)
                      else if (type == 'audio')
                        _AudioBlock(
                          title: title,
                          url: absoluteUrl(filePath),
                          icon: Icons.headphones_rounded,
                        )
                      else if (type == 'meditation')
                          _AudioBlock(
                            title: title,
                            url: absoluteUrl(filePath),
                            icon: Icons.self_improvement_rounded,
                          )
                        else if (type == 'pdf')
                            _PdfBlock(
                              title: title,
                              url: absoluteUrl(filePath),
                            )
                          else if (content.isNotEmpty)
                              Text(
                                content,
                                style: const TextStyle(
                                  color: Color(0xFF17213A),
                                  fontSize: 16,
                                  height: 1.55,
                                ),
                              )
                            else
                              const Text(
                                'No content available.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                ),
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
        Expanded(
          child: Text(
            title.isEmpty ? 'Library Item' : title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoBlock extends StatefulWidget {
  final String youtubeUrl;

  const _VideoBlock({
    required this.youtubeUrl,
  });

  @override
  State<_VideoBlock> createState() => _VideoBlockState();
}

class _VideoBlockState extends State<_VideoBlock> {
  YoutubePlayerController? controller;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    if (videoId == null || videoId.isEmpty) {
      errorMessage = 'Invalid YouTube link';
      return;
    }

    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return _InlineMessage(message: errorMessage!);
    }

    if (controller == null) {
      return const _InlineMessage(message: 'Video could not be loaded');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: YoutubePlayer(
        controller: controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF2F61D2),
      ),
    );
  }
}

class _AudioBlock extends StatefulWidget {
  final String title;
  final String url;
  final IconData icon;

  const _AudioBlock({
    required this.title,
    required this.url,
    required this.icon,
  });

  @override
  State<_AudioBlock> createState() => _AudioBlockState();
}

class _AudioBlockState extends State<_AudioBlock> {
  final AudioPlayer player = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => duration = d);
      }
    });

    player.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => position = p);
      }
    });

    player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> togglePlay() async {
    final url = widget.url.trim();

    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No audio file available for this resource'),
          ),
        );
      }
      return;
    }

    try {
      if (isPlaying) {
        await player.pause();
        if (mounted) {
          setState(() => isPlaying = false);
        }
      } else {
        await player.play(UrlSource(url));
        if (mounted) {
          setState(() => isPlaying = true);
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not play audio.\n$e'),
        ),
      );
    }
  }

  String timeText(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return const _InlineMessage(message: 'No audio file available');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(
              widget.icon,
              color: const Color(0xFF0F3D84),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: position.inSeconds.toDouble().clamp(
              0,
              duration.inSeconds == 0 ? 1 : duration.inSeconds.toDouble(),
            ),
            min: 0,
            max: duration.inSeconds == 0 ? 1 : duration.inSeconds.toDouble(),
            onChanged: (value) async {
              final newPosition = Duration(seconds: value.toInt());
              await player.seek(newPosition);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeText(position)),
              Text(timeText(duration)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: togglePlay,
              icon: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(isPlaying ? 'Pause' : 'Play'),
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
}

class _PdfBlock extends StatelessWidget {
  final String title;
  final String url;

  const _PdfBlock({
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _InlineMessage(message: 'No PDF file available');
    }

    return SizedBox(
      height: 520,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SfPdfViewer.network(url),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
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