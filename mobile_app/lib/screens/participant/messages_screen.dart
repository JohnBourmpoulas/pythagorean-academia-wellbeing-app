import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> conversations = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/messages/list.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load messages';
      });
      return;
    }

    setState(() {
      conversations = List<Map<String, dynamic>>.from(
        response['messages'] ?? [],
      );
      isLoading = false;
    });
  }

  int toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int adminUserIdFrom(Map<String, dynamic> item) {
    return toInt(item['admin_user_id'] ?? item['sender_user_id']);
  }

  Future<void> openConversation(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParticipantChatScreen(conversation: item),
      ),
    );

    if (mounted) {
      loadMessages();
    }
  }

  Future<void> deleteConversation(Map<String, dynamic> item) async {
    final adminUserId = adminUserIdFrom(item);

    if (adminUserId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid conversation')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will permanently delete the full conversation.',
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

    final response = await ApiService.post(
      '/participant/messages/delete_conversation.php',
      {'admin_user_id': adminUserId},
      auth: true,
    );

    if (!mounted) return;

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

    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : RefreshIndicator(
            onRefresh: loadMessages,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (conversations.isEmpty)
                    _emptyCard()
                  else
                    ...conversations.map(_conversationCard),
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
        const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard() {
    return _WhiteCard(
      child: const Column(
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 58,
            color: Color(0xFF2F61D2),
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
            'Messages from the program team will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationCard(Map<String, dynamic> item) {
    final subject = item['subject']?.toString() ?? 'Message';
    final message = item['message']?.toString() ?? '';
    final sender = item['sender_name']?.toString() ?? 'Program Team';
    final email = item['sender_email']?.toString() ?? '';
    final createdAt = item['created_at']?.toString() ?? '';
    final unreadCount = toInt(item['unread_count']);
    final isRead = unreadCount == 0;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openConversation(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isRead
                      ? const Color(0xFFE8F1FF)
                      : const Color(0xFFDDFBE8),
                  child: Icon(
                    isRead
                        ? Icons.mark_email_read_rounded
                        : Icons.mark_email_unread_rounded,
                    color: isRead ? const Color(0xFF2F61D2) : Colors.green,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unreadCount > 0 ? 'NEW MESSAGE' : 'CONVERSATION',
                    style: TextStyle(
                      color: unreadCount > 0
                          ? Colors.green
                          : const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sender,
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2F61D2),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.isEmpty ? 'No messages yet' : message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 10),
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
            Column(
              children: [
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                ),
                IconButton(
                  onPressed: () => deleteConversation(item),
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
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
    return _WhiteCard(
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

class ParticipantChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ParticipantChatScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ParticipantChatScreen> createState() => _ParticipantChatScreenState();
}

class _ParticipantChatScreenState extends State<ParticipantChatScreen> {
  bool isLoading = true;
  bool isSending = false;
  bool isDeleting = false;
  String? errorMessage;

  List<Map<String, dynamic>> messages = [];

  final messageController = TextEditingController();

  int get adminUserId {
    return int.tryParse(
      (widget.conversation['admin_user_id'] ??
          widget.conversation['sender_user_id'])
          ?.toString() ??
          '',
    ) ??
        0;
  }

  String get adminName {
    return widget.conversation['sender_name']?.toString() ?? 'Program Team';
  }

  String get adminEmail {
    return widget.conversation['sender_email']?.toString() ?? '';
  }

  String get subject {
    return widget.conversation['subject']?.toString() ?? 'Message';
  }

  @override
  void initState() {
    super.initState();
    loadConversation();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> loadConversation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/messages/conversation.php?admin_user_id=$adminUserId',
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

  Future<void> sendReply() async {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is required')),
      );
      return;
    }

    if (adminUserId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin user id')),
      );
      return;
    }

    setState(() => isSending = true);

    final response = await ApiService.post(
      '/participant/messages/reply.php',
      {
        'admin_user_id': adminUserId,
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
    if (adminUserId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid conversation')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will permanently delete the full conversation.',
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
      '/participant/messages/delete_conversation.php',
      {'admin_user_id': adminUserId},
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
              Icons.admin_panel_settings_rounded,
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
                  adminName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  adminEmail.isEmpty ? subject : adminEmail,
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
              mine ? 'You' : (sender.isEmpty ? adminName : sender),
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
        child: Row(
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
                onPressed: isSending ? null : sendReply,
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

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
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