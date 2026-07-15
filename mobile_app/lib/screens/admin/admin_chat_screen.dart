import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AdminChatScreen extends StatefulWidget {
  final Map<String, dynamic> participant;

  const AdminChatScreen({
    super.key,
    required this.participant,
  });

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  bool isLoading = true;
  bool isSending = false;
  bool isDeleting = false;
  String? errorMessage;

  List<Map<String, dynamic>> messages = [];

  final messageController = TextEditingController();
  final subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subjectController.text = 'Message from program team';
    loadConversation();
  }

  @override
  void dispose() {
    messageController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  int get participantUserId {
    return int.tryParse(widget.participant['user_id']?.toString() ?? '') ?? 0;
  }

  String get participantName {
    return widget.participant['full_name']?.toString() ?? 'Participant';
  }

  Future<void> loadConversation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/admin/messages/conversation.php?participant_user_id=$participantUserId',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load conversation';
      });
      return;
    }

    setState(() {
      messages = List<Map<String, dynamic>>.from(response['messages'] ?? []);
      isLoading = false;
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final subject = subjectController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is required')),
      );
      return;
    }

    setState(() => isSending = true);

    final response = await ApiService.post(
      '/admin/messages/send.php',
      {
        'receiver_user_id': participantUserId,
        'subject': subject.isEmpty ? 'Message from program team' : subject,
        'message': text,
      },
      auth: true,
    );

    if (!mounted) return;

    setState(() => isSending = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not send message',
          ),
        ),
      );
      return;
    }

    messageController.clear();
    await loadConversation();
  }

  Future<void> deleteConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text(
          'This will permanently delete the full conversation with $participantName.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    final response = await ApiService.post(
      '/admin/messages/delete_conversation.php',
      {'participant_user_id': participantUserId},
      auth: true,
    );

    if (!mounted) return;

    setState(() => isDeleting = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not delete conversation',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation deleted')),
    );

    Navigator.pop(context, true);
  }

  String value(Map<String, dynamic> item, String key) {
    final raw = item[key];
    if (raw == null) return '';
    return raw.toString();
  }

  bool isMine(Map<String, dynamic> item) {
    final raw = item['is_mine'];
    return raw == true || raw == 1 || raw.toString() == '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : errorMessage != null
                    ? Padding(
                  padding: const EdgeInsets.all(28),
                  child: _messageCard(errorMessage!),
                )
                    : RefreshIndicator(
                  onRefresh: loadConversation,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(22, 16, 22, 22),
                    children: [
                      if (messages.isEmpty)
                        _emptyConversation()
                      else
                        ...messages.map(_bubble),
                    ],
                  ),
                ),
              ),
              _composer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final email = widget.participant['email']?.toString() ?? '';
    final program = widget.participant['program_title']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.18),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF2F61D2),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (program.isNotEmpty)
                  Text(
                    program,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: isDeleting ? null : deleteConversation,
            icon: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyConversation() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFF2F61D2),
            size: 58,
          ),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Send the first message to this participant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> item) {
    final mine = isMine(item);
    final message = value(item, 'message');
    final createdAt = value(item, 'created_at');
    final sender = value(item, 'sender_name');

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mine ? Colors.white : const Color(0xFFDDFBE8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(mine ? 22 : 6),
            bottomRight: Radius.circular(mine ? 6 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              mine ? 'You' : (sender.isEmpty ? participantName : sender),
              style: TextStyle(
                color: mine ? const Color(0xFF2F61D2) : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: mine ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF17213A),
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (createdAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                createdAt,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                filled: true,
                fillColor: const Color(0xFFF4F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      filled: true,
                      fillColor: const Color(0xFFF4F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSending ? null : sendMessage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF2F61D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
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