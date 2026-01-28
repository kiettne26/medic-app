import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../domain/models/conversation.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  String? _doctorId;
  StompClient? _stompClient;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    super.dispose();
  }

  void _connectWebSocket() {
    if (_doctorId == null) return;

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://localhost:8080/ws',
        onConnect: _onStompConnect,
        beforeConnect: () async {
          print('MessagesScreen: Waiting to connect WebSocket...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (error) =>
            print('MessagesScreen WebSocket error: $error'),
        onStompError: (frame) =>
            print('MessagesScreen STOMP error: ${frame.body}'),
        onDisconnect: (frame) =>
            print('MessagesScreen: Disconnected from WebSocket'),
      ),
    );
    _stompClient!.activate();
  }

  void _onStompConnect(StompFrame frame) {
    print('Connected to WebSocket for notifications');
    // Subscribe to doctor's notification topic
    _stompClient!.subscribe(
      destination: '/topic/user/$_doctorId/notification',
      callback: (frame) {
        print('New message notification received');
        // Refresh conversation list when new message arrives
        _loadConversations(showLoading: false);
      },
    );
  }

  Future<void> _loadConversations({bool showLoading = true}) async {
    try {
      const storage = FlutterSecureStorage();
      _doctorId ??= await storage.read(key: 'user_id');

      if (_doctorId == null) {
        setState(() {
          _error = 'Không tìm thấy thông tin bác sĩ';
          _isLoading = false;
        });
        return;
      }

      // Connect WebSocket if not connected
      if (_stompClient == null) {
        _connectWebSocket();
      }

      // Call API to get conversations
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/chat/conversations?userId=$_doctorId&isDoctor=true',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _conversations = data.map((json) {
              return Conversation(
                id: json['id'] ?? '',
                patientId: json['userId'] ?? '',
                patientName: json['patientName'] ?? 'Bệnh nhân',
                patientAvatar: json['patientAvatar'],
                lastMessage: json['lastMessage'],
                lastMessageTime: json['lastMessageTime'] != null
                    ? DateTime.tryParse(json['lastMessageTime'])
                    : null,
                unreadCount: json['unreadCount'] ?? 0,
              );
            }).toList();
            if (showLoading) _isLoading = false;
          });
        }
      } else {
        if (mounted && showLoading) {
          setState(() {
            _error = 'Lỗi tải dữ liệu: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && showLoading) {
        setState(() {
          _error = 'Lỗi kết nối: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_error!, style: GoogleFonts.manrope(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadConversations();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm cuộc trò chuyện...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          if (_conversations.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có cuộc trò chuyện nào',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadConversations,
                child: ListView.separated(
                  itemCount: _conversations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    return ListTile(
                      onTap: () {
                        context.push('/messages/detail', extra: conversation);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: conversation.patientAvatar != null
                            ? NetworkImage(conversation.patientAvatar!)
                            : null,
                        child: conversation.patientAvatar == null
                            ? Text(
                                conversation.patientName[0].toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              )
                            : null,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conversation.patientName,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF101418),
                            ),
                          ),
                          if (conversation.lastMessageTime != null)
                            Text(
                              _formatTime(conversation.lastMessageTime!),
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage ?? '',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: conversation.unreadCount > 0
                                    ? const Color(0xFF101418)
                                    : Colors.grey[600],
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
