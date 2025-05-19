import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.100.10/loginregishistory-backend';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  // Method untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login.php');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'user_id': data['user_id'],
          'email': data['email'],
          'name': data['name'],
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk registrasi
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register.php');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk logout
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$_baseUrl/logout.php');
    try {
      final response = await http.post(
        url,
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Logout berhasil',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Logout gagal',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk membuat chat baru
  Future<Map<String, dynamic>> createChat(int userId, int userId2) async {
    final url = Uri.parse('$_baseUrl/chat.php');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'action': 'create_chat',
          'user_id_1': userId.toString(),
          'user_id_2': userId2.toString(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'chat_id': data['chat_id'],
          'message': data['message'] ?? 'Chat created',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Failed to create chat',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk mengirim pesan
  Future<Map<String, dynamic>> sendMessage(int chatId, int senderId, String content, {bool isAI = false}) async {
    final url = Uri.parse('$_baseUrl/chat.php');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: {
          'action': 'send_message',
          'chat_id': chatId.toString(),
          'sender_id': senderId.toString(),
          'content': content,
          'is_ai': isAI ? '1' : '0',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Message sent',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Failed to send message',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Method untuk mendapatkan daftar chat
  Future<Map<String, dynamic>> getChats(int userId) async {
  final url = Uri.parse('$_baseUrl/chat.php?action=get_chats&user_id=$userId');
  try {
    final response = await http.get(
      url,
      headers: _headers,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Request timeout');
    });

    print('Get chats response: ${response.body}');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return {
        'status': 'success',
        'chats': data['chats'],
      };
    } else {
      return {
        'status': 'error',
        'message': data['message'] ?? 'Failed to fetch chats',
      };
    }
  } catch (e) {
    print('Get chats error: $e');
    return {
      'status': 'error',
      'message': 'Gagal terhubung ke server: $e',
    };
  }
}

  // Method untuk mendapatkan pesan dari chat
  Future<Map<String, dynamic>> getMessages(int chatId) async {
    final url = Uri.parse('$_baseUrl/chat.php?action=get_messages&chat_id=$chatId');
    try {
      final response = await http.get(
        url,
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'messages': data['messages'],
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Failed to fetch messages',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}