import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'admin_chat_screen.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> participants = [];

  @override
  void initState() {
    super.initState();
    loadParticipants();
  }

  Future<void> loadParticipants() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/admin/messages/participants.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load participants';
      });
      return;
    }

    setState(() {
      participants = List<Map<String, dynamic>>.from(
        response['participants'] ?? [],
      );
      isLoading = false;
    });
  }

  int toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> openChat(Map<String, dynamic> participant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminChatScreen(participant: participant),
      ),
    );

    if (mounted) {
      loadParticipants();
    }
  }

  Future<void> deleteConversation(Map<String, dynamic> participant) async {
    final participantUserId = toInt(participant['user_id']);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will permanently delete the full conversation with this participant.',
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
      '/admin/messages/delete_conversation.php',
      {'participant_user_id': participantUserId},
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

    loadParticipants();
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
            onRefresh: loadParticipants,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (participants.isEmpty)
                    _emptyCard()
                  else
                    ...participants.map(_participantCard),
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
            'Messages',
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

  Widget _participantCard(Map<String, dynamic> participant) {
    final name = participant['full_name']?.toString() ?? 'Participant';
    final email = participant['email']?.toString() ?? '';
    final program = participant['program_title']?.toString() ?? '';
    final lastMessage = participant['last_message']?.toString() ?? '';
    final lastAt = participant['last_message_at']?.toString() ?? '';
    final unread = toInt(participant['unread_count']);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => openChat(participant),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F1FF),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2F61D2),
                    size: 32,
                  ),
                ),
                if (unread > 0)
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
                        unread > 99 ? '99+' : unread.toString(),
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
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unread > 0 ? 'NEW REPLY' : 'PARTICIPANT',
                    style: TextStyle(
                      color: unread > 0 ? Colors.green : const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 21,
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
                      ),
                    ),
                  ],
                  if (program.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      program,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2F61D2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  if (lastAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      lastAt,
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
                  size: 32,
                ),
                IconButton(
                  onPressed: () => deleteConversation(participant),
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

  Widget _emptyCard() {
    return _WhiteCard(
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: Color(0xFF2F61D2),
            size: 58,
          ),
          SizedBox(height: 16),
          Text(
            'No active participants',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Participants will appear here after their applications are approved.',
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