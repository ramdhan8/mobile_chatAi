import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../widgets/chat_bubble.dart';

class AIModel {
  final String name;
  final String apiKey;
  final String modelName;

  AIModel({required this.name, required this.apiKey, required this.modelName});
}

class ChatPage extends StatefulWidget {
  final int? chatId;
  const ChatPage({super.key, this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Daftar model AI yang tersedia
  final List<AIModel> aiModels = [
    AIModel(
      name: 'Gemini',
      apiKey: 'AIzaSyBnwtYHw5NBa03bcyXZL9KxBulZcF3MaGE',
      modelName: 'gemini-1.5-flash-latest',
    ),
    AIModel(
      name: 'Grok',
      apiKey: 'YOUR_GROK_API_KEY', // Ganti dengan kunci API Grok
      modelName: 'grok-3',
    ),
  ];

  AIModel? selectedModel;
  GenerativeModel? model;
  TextEditingController messageController = TextEditingController();
  List<Content> chatHistory = [];
  bool isLoading = false;

  List<ChatBubble> chatBubbles = [
    const ChatBubble(
      direction: Direction.left,
      message: 'Halo, Ada yang bisa saya bantu?',
      photoUrl: 'https://avatar.iran.liara.run/public/17',
      type: BubbleType.alone,
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedModel = aiModels.first;
    model = GenerativeModel(
      model: selectedModel!.modelName,
      apiKey: selectedModel!.apiKey,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void changeModel(AIModel newModel) {
    setState(() {
      selectedModel = newModel;
      model = GenerativeModel(
        model: newModel.modelName,
        apiKey: newModel.apiKey,
      );
      chatHistory.clear();
      chatBubbles = [
        ChatBubble(
          direction: Direction.left,
          message: 'Model diubah ke ${newModel.name}. Ada yang bisa saya bantu?',
          photoUrl: 'https://avatar.iran.liara.run/public/17',
          type: BubbleType.alone,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              reverse: true,
              padding: const EdgeInsets.all(10),
              children: chatBubbles.reversed.toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Input teks
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      hintText: 'Tanya apa saja',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                // Ikon-ikon tambahan, popup menu, dan tombol kirim/mikrofon
                Row(
                  children: [
                    // Ikon-ikon dan popup menu
                    Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 1,
                                offset: const Offset(0, 0.5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.black),
                            iconSize: 15,
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Aksi untuk lampiran
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 1,
                                offset: const Offset(0, 0.5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.format_shapes, color: Colors.black),
                            iconSize: 15,
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Aksi untuk spiral
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 1,
                                offset: const Offset(0, 0.5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.lightbulb_outline, color: Colors.black),
                            iconSize: 15,
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Aksi untuk lampu
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 1,
                                offset: const Offset(0, 0.5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            iconSize: 15,
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Aksi untuk pena
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        // PopupMenuButton untuk memilih model
                        Container(
                          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 1,
                                offset: const Offset(0, 0.5),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<AIModel>(
                            icon: const Icon(Icons.smart_toy, color: Colors.black, size: 15),
                            offset: const Offset(0, 40), // Menempatkan menu di bawah tombol
                            onSelected: (AIModel newModel) {
                              changeModel(newModel);
                            },
                            itemBuilder: (BuildContext context) => aiModels.map((AIModel model) {
                              return PopupMenuItem<AIModel>(
                                value: model,
                                child: Text(
                                  model.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                            tooltip: 'Pilih Model AI',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Tombol kirim/mikrofon
                    Container(
                      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0.2,
                            blurRadius: 1,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: messageController.text.isNotEmpty
                            ? const Icon(Icons.arrow_upward, color: Colors.black)
                            : const Icon(Icons.mic, color: Colors.black),
                        iconSize: 20,
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          if (messageController.text.isNotEmpty) {
                            String messageText = messageController.text;

                            setState(() {
                              messageController.clear();
                              isLoading = true;
                              chatBubbles = [
                                ...chatBubbles,
                                ChatBubble(
                                  direction: Direction.right,
                                  message: messageText,
                                  photoUrl: null,
                                  type: BubbleType.alone,
                                ),
                                const ChatBubble(
                                  direction: Direction.left,
                                  message: "Typing...",
                                  photoUrl: 'https://avatar.iran.liara.run/public/17',
                                  type: BubbleType.alone,
                                ),
                              ];
                            });

                            chatHistory.add(Content.text(messageText));

                            try {
                              final GenerateContentResponse responseAI =
                                  await model!.generateContent(chatHistory);

                              chatBubbles.removeLast();
                              chatBubbles = [
                                ...chatBubbles,
                                ChatBubble(
                                  direction: Direction.left,
                                  message: responseAI.text ?? 'Maaf, saya tidak mengerti',
                                  photoUrl: 'https://avatar.iran.liara.run/public/17',
                                  type: BubbleType.alone,
                                ),
                              ];

                              chatHistory.add(Content.text(responseAI.text ?? 'Maaf, saya tidak mengerti'));
                            } catch (e) {
                              chatBubbles.removeLast();
                              chatBubbles = [
                                ...chatBubbles,
                                const ChatBubble(
                                  direction: Direction.left,
                                  message: 'Error: Failed to communicate with the API.',
                                  photoUrl: 'https://avatar.iran.liara.run/public/17',
                                  type: BubbleType.alone,
                                ),
                              ];
                            }

                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            setState(() {
                              isLoading = true;
                              chatBubbles = [
                                ...chatBubbles,
                                const ChatBubble(
                                  direction: Direction.left,
                                  message: "Listening...",
                                  photoUrl: 'https://avatar.iran.liara.run/public/17',
                                  type: BubbleType.alone,
                                ),
                              ];
                            });
                            await Future.delayed(const Duration(seconds: 2));
                            chatBubbles.removeLast();
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
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
}