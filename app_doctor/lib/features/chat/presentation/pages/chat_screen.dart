import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../domain/models/conversation.dart';

// Helper function to format time (reused)
String _formatChatTime(String? isoTime) {
  if (isoTime == null || isoTime.isEmpty) return 'Unknown';
  try {
    final dateTime = DateTime.parse(isoTime);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime); // e.g., "14:30"
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime); // e.g., "23/01 14:30"
    }
  } catch (e) {
    return isoTime.length > 16 ? isoTime.substring(11, 16) : isoTime;
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();
  StompClient? client;
  String _connectionStatus = 'Connecting...';
  String? _doctorId; // Store logged-in doctor ID
  bool _isUploading = false;

  final List<Map<String, dynamic>> _messages = [];
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _initializeChat() async {
    await _loadDoctorId();
    await _loadChatHistory();
    _connectWebSocket();
  }

  Future<void> _loadDoctorId() async {
    // Ideally get from ProfileController, but storage is direct
    final userId = await _storage.read(key: 'user_id'); // Assuming same key
    if (mounted) {
      setState(() {
        _doctorId = userId;
      });
    }
    print('Loaded Doctor ID: $_doctorId');
  }

  Future<void> _loadChatHistory() async {
    if (_doctorId == null) return;

    try {
      // API might be slightly different or same. Assuming same endpoint structure for now.
      // Need to verify if backend distinguishes via role or just participants.
      // For now using the same endpoint but swapping params if needed or relying on backend handling.
      // Actually backend likely expects 'userId' (patient) and 'doctorId'.
      final url = Uri.parse(
        'http://localhost:8080/api/chat/conversation?userId=${widget.conversation.patientId}&doctorId=$_doctorId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _conversationId = data['conversationId'];

        final messagesData =
            data['messages']?['content'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _messages.clear();
            for (var msg in messagesData.reversed) {
              _messages.add({
                'isMe': msg['senderId'] == _doctorId,
                'text': msg['content'],
                'time': _formatChatTime(msg['createdAt']),
                'type': msg['type'] ?? 'TEXT',
                'imageUrl': msg['imageUrl'],
              });
            }
          });
          _scrollToBottom();
        }
        print('Loaded ${messagesData.length} messages from history');
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _connectWebSocket() {
    final socketUrl = 'ws://localhost:8080/ws';

    if (mounted) {
      setState(() {
        _connectionStatus = 'Connecting...';
      });
    }

    client = StompClient(
      config: StompConfig.sockJS(
        url: 'http://localhost:8080/ws',
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket Error: $error');
          if (mounted) {
            setState(() {
              _connectionStatus = 'Error: $error';
            });
          }
        },
        onDisconnect: (frame) {
          print('Disconnected: ${frame.body}');
          if (mounted) {
            setState(() {
              _connectionStatus = 'Disconnected';
            });
          }
        },
        onStompError: (frame) {
          print('STOMP Error: ${frame.body}');
          if (mounted) {
            setState(() {
              _connectionStatus = 'STOMP Error';
            });
          }
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    client!.activate();
  }

  void onConnect(StompFrame frame) {
    if (mounted) {
      setState(() {
        _connectionStatus = 'Connected';
      });
    }
    final topic = _conversationId != null
        ? '/topic/conversation/$_conversationId'
        : '/topic/messages'; // Fallback, might need specific topic for doctor

    print('Subscribing to topic: $topic');

    client!.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        if (frame.body != null && mounted) {
          final data = json.decode(frame.body!);
          // Skip if this is my own message
          if (data['senderId'] == _doctorId) return;

          setState(() {
            _messages.add({
              'isMe': false,
              'text': data['content'],
              'time': _formatChatTime(data['createdAt']),
              'type': data['type'] ?? 'text',
              'imageUrl': data['imageUrl'],
            });
          });
          _scrollToBottom();
        }
      },
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Add message to local list immediately
    if (mounted) {
      setState(() {
        _messages.add({
          'isMe': true,
          'text': text,
          'time': 'Just now',
          'type': 'TEXT',
          'isRead': false,
        });
      });
      _scrollToBottom();
    }

    // Send to server if connected
    if (client != null && _doctorId != null) {
      final message = {
        'content': text,
        'senderId': _doctorId,
        'receiverId': widget.conversation.patientId,
        'type': 'TEXT',
      };
      try {
        client!.send(destination: '/app/chat', body: json.encode(message));
      } catch (e) {
        print('Error sending message: $e');
      }
    }
    _textController.clear();
  }

  /// Chọn ảnh từ gallery và gửi
  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image == null) return;

      if (mounted) {
        setState(() {
          _isUploading = true;
        });
      }

      // Upload ảnh lên server
      final imageUrl = await _uploadImage(File(image.path));

      if (imageUrl != null) {
        _sendImageMessage(imageUrl);
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể gửi ảnh: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Upload ảnh lên server và trả về URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('http://localhost:8080/users/upload');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']?['url'];
      } else {
        print('Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Gửi tin nhắn ảnh qua WebSocket
  void _sendImageMessage(String imageUrl) {
    // Add message to local list immediately
    if (mounted) {
      setState(() {
        _messages.add({
          'isMe': true,
          'text': '',
          'time': 'Just now',
          'type': 'IMAGE',
          'imageUrl': imageUrl,
          'isRead': false,
        });
      });
      _scrollToBottom();
    }

    // Send to server if connected
    if (client != null && _doctorId != null) {
      final message = {
        'content': '',
        'senderId': _doctorId,
        'receiverId': widget.conversation.patientId,
        'type': 'IMAGE',
        'imageUrl': imageUrl,
      };
      try {
        client!.send(destination: '/app/chat', body: json.encode(message));
      } catch (e) {
        print('Error sending image message: $e');
      }
    }
  }

  @override
  void dispose() {
    client?.deactivate();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                children: [
                  ..._messages.map((msg) {
                    if (msg['type'] == 'text' || msg['type'] == 'TEXT') {
                      return _buildTextMessage(msg);
                    } else {
                      return _buildImageMessage(msg);
                    }
                  }),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Header adapted for Patient info
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFDADFE7))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF101418),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: ClipOval(
                  child: widget.conversation.patientAvatar != null
                      ? CachedNetworkImage(
                          imageUrl: widget.conversation.patientAvatar!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Icon(Icons.person, color: Colors.grey),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _connectionStatus == 'Connected'
                        ? const Color(0xFF00C853)
                        : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.patientName,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF101418),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _connectionStatus,
                  style: GoogleFonts.manrope(
                    color: _connectionStatus == 'Connected'
                        ? const Color(0xFF00C853)
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: widget.conversation.patientAvatar != null
                    ? CachedNetworkImage(
                        imageUrl: widget.conversation.patientAvatar!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF297EFF) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: isMe
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: const Color(0xFFDADFE7)),
                    boxShadow: !isMe
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(0xFF297EFF).withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    msg['text'],
                    style: GoogleFonts.manrope(
                      color: isMe ? Colors.white : const Color(0xFF101418),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg['time'],
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: const Color(0xFF5E718D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    final hasText = msg['text'] != null && (msg['text'] as String).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: widget.conversation.patientAvatar != null
                    ? CachedNetworkImage(
                        imageUrl: widget.conversation.patientAvatar!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (hasText)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF297EFF) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      border: isMe
                          ? null
                          : Border.all(color: const Color(0xFFDADFE7)),
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? const Color(0xFF297EFF).withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: GoogleFonts.manrope(
                        color: isMe ? Colors.white : const Color(0xFF101418),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                Container(
                  width: 180,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe
                          ? const Color(0xFF297EFF).withOpacity(0.2)
                          : const Color(0xFFDADFE7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: msg['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: msg['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 48),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg['time'] ?? '',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: const Color(0xFF5E718D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFDADFE7))),
      ),
      child: Row(
        children: [
          _isUploading
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : GestureDetector(
                  onTap: _pickAndSendImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF5E718D),
                      size: 24,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: GoogleFonts.manrope(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF297EFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF297EFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
