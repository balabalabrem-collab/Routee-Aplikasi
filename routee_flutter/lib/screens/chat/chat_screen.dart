import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/driver_data.dart';
import '../../core/models/chat_model.dart';
import '../../core/models/driver_model.dart';

class ChatScreen extends StatefulWidget {
  final String driverId;
  const ChatScreen({super.key, required this.driverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  DriverModel? _driver;

  // Auto replies from driver
  final _autoReplies = [
    'Baik, saya mengerti. Saya segera ke lokasi 🚗',
    'Estimasi 5-10 menit lagi ya kak 🙏',
    'Oke kak, sudah di jalan!',
    'Terima kasih sudah sabar menunggu, sebentar lagi sampai',
    'Baik kak, noted ya 👍',
    'Siap kak, saya sudah on the way ke titik penjemputan',
  ];
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    _driver = DriverData.findById(widget.driverId);

    // Initial greeting from driver
    _messages.add(ChatMessage(
      id: 'msg-0',
      senderId: widget.driverId,
      message: 'Halo kak! Saya ${_driver?.name ?? 'driver'} 👋\nSiap menjadi driver perjalanan heritage Surabaya hari ini.\n\nMau dijemput dimana kak?',
      timestamp: DateTime.now(),
      isFromDriver: true,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: 'msg-${_messages.length}',
        senderId: 'user',
        message: text.trim(),
        timestamp: DateTime.now(),
        isFromDriver: false,
      ));
    });

    _textController.clear();
    _scrollToBottom();

    // Simulate driver auto-reply
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: 'msg-${_messages.length}',
          senderId: widget.driverId,
          message: _autoReplies[_replyIndex % _autoReplies.length],
          timestamp: DateTime.now(),
          isFromDriver: true,
        ));
        _replyIndex++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_driver?.name ?? 'Driver', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('Online', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                      if (_driver != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, size: 11, color: AppColors.accent),
                        Text(' ${_driver!.rating}', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.accentLight)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'Lacak Driver',
            onPressed: () => context.push('/driver-tracking/current'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _MessageBubble(message: _messages[i]),
            ),
          ),

          // Quick replies
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _QuickReply(text: 'Saya sudah di lokasi 📍', onTap: () => _sendMessage('Saya sudah di lokasi 📍')),
                _QuickReply(text: 'Berapa lama lagi? ⏰', onTap: () => _sendMessage('Berapa lama lagi? ⏰')),
                _QuickReply(text: 'Tolong hubungi saya 📞', onTap: () => _sendMessage('Tolong hubungi saya 📞')),
                _QuickReply(text: 'Oke, terima kasih 👍', onTap: () => _sendMessage('Oke, terima kasih 👍')),
              ],
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDriver = message.isFromDriver;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isDriver ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isDriver)
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDriver ? AppColors.surface : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isDriver ? 4 : 16),
                  bottomRight: Radius.circular(isDriver ? 16 : 4),
                ),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.message,
                    style: GoogleFonts.poppins(fontSize: 13, color: isDriver ? AppColors.textPrimary : Colors.white, height: 1.4),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(fontSize: 9, color: isDriver ? AppColors.textMuted : Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReply extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _QuickReply({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
        ),
      ),
    );
  }
}
