import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/services/chat_provider.dart';
import 'chat_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..fetchChats(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat History'),
          automaticallyImplyLeading: false, // Menghapus tombol kembali
        ),
        body: Consumer<ChatProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.fetchChats(); // Coba lagi
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (provider.chats.isEmpty) {
              return const Center(child: Text('No chats yet'));
            }
            return ListView.builder(
              itemCount: provider.chats.length,
              itemBuilder: (context, index) {
                final chat = provider.chats[index];
                return ListTile(
                  title: Text(chat.otherUser == 'AI' ? 'Chat with AI' : chat.otherUser),
                  subtitle: Text(chat.createdAt.toString()),
                  onTap: () {
                    try {
                      print('Navigating to ChatPage with chatId: ${chat.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatId: chat.id),
                        ),
                      );
                    } catch (e) {
                      print('Navigation error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to open chat: $e')),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('Creating new chat');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}