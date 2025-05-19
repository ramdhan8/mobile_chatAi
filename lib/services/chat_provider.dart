import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class Chat {
  final int id;
  final String otherUser;
  final DateTime createdAt;

  Chat({required this.id, required this.otherUser, required this.createdAt});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      otherUser: json['other_user'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Message {
  final int senderId;
  final String username;
  final String content;
  final DateTime createdAt;

  Message({required this.senderId, required this.username, required this.content, required this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['sender_id'],
      username: json['username'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    print('User ID from SharedPreferences: $userId');
    return userId;
  }

  Future<void> fetchChats() async {
    print('Starting fetchChats');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userId = await _getUserId();
    if (userId == null) {
      print('No user ID found, exiting fetchChats');
      _isLoading = false;
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      print('Fetching chats for userId: $userId');
      final response = await _apiService.getChats(userId);
      print('Fetch chats response: $response');

      if (response['status'] == 'success') {
        _chats = (response['chats'] as List).map((json) => Chat.fromJson(json)).toList();
        print('Chats loaded: ${_chats.length}');
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch chats';
        print('Fetch chats failed: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching chats: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    print('Finished fetchChats');
  }

  Future<void> fetchMessages(int chatId) async {
    print('Starting fetchMessages for chatId: $chatId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getMessages(chatId);
      print('Fetch messages response: $response');

      if (response['status'] == 'success') {
        _messages = (response['messages'] as List).map((json) => Message.fromJson(json)).toList();
        print('Messages loaded: ${_messages.length}');
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch messages';
        print('Fetch messages failed: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching messages: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    print('Finished fetchMessages');
  }

  Future<void> createChat(int userId2) async {
    final userId = await _getUserId();
    if (userId == null) {
      _errorMessage = 'User not logged in';
      print(_errorMessage);
      return;
    }

    try {
      print('Creating chat with userId2: $userId2');
      final response = await _apiService.createChat(userId, userId2);
      print('Create chat response: $response');

      if (response['status'] == 'success') {
        await fetchChats();
      } else {
        _errorMessage = response['message'] ?? 'Failed to create chat';
        print('Create chat failed: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error creating chat: $e';
      print(_errorMessage);
    }
  }

  Future<void> sendMessage(int chatId, String content) async {
    final userId = await _getUserId();
    if (userId == null) {
      _errorMessage = 'User not logged in';
      print(_errorMessage);
      return;
    }

    try {
      print('Sending message to chatId: $chatId');
      final response = await _apiService.sendMessage(chatId, userId, content);
      print('Send message response: $response');

      if (response['status'] == 'success') {
        await fetchMessages(chatId);
      } else {
        _errorMessage = response['message'] ?? 'Failed to send message';
        print('Send message failed: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      print(_errorMessage);
    }
  }
}