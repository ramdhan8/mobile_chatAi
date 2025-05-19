import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyBnwtYHw5NBa03bcyXZL9KxBulZcF3MaGE';

class MenulisPage extends StatefulWidget {
  @override
  _MenulisPageState createState() => _MenulisPageState();
}

class _MenulisPageState extends State<MenulisPage> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  String? _selectedStyle = "Resmi"; // Default value for the first dropdown
  String? _selectedOption = "Pendek"; // Default value for the second dropdown
  String? _selectedLanguage = "Indonesia"; // Default value for the third dropdown
  TextEditingController _topicController = TextEditingController();
  List<Content> chatHistory = []; // To store chat history for the AI model
  bool isLoading = false; // To show loading state
  String _responseTitle = ""; // Initialize as empty string to avoid null issues
  String _responseContent = ""; // Initialize as empty string to avoid null issues
  List<TextSpan> _parsedResponseContent = []; // To store parsed TextSpans for RichText

  @override
  void initState() {
    super.initState();
    _topicController.text = "";
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  // Function to parse simple Markdown (bold text with **)
  List<TextSpan> _parseMarkdown(String content) {
    List<TextSpan> spans = [];
    RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*'); // Matches **text**
    int lastIndex = 0;

    // Find all bold sections
    for (var match in boldRegex.allMatches(content)) {
      // Add text before the bold section (if any)
      if (match.start > lastIndex) {
        String normalText = content.substring(lastIndex, match.start);
        // Split by newlines and add as separate TextSpans
        normalText.split('\n').forEach((line) {
          spans.add(TextSpan(
            text: line + (line.isNotEmpty ? '\n' : ''),
            style: TextStyle(fontSize: 14, color: Colors.black),
          ));
        });
      }

      // Add the bold section
      String boldText = match.group(1)!; // Text inside **...**
      boldText.split('\n').forEach((line) {
        spans.add(TextSpan(
          text: line + (line.isNotEmpty ? '\n' : ''),
          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        ));
      });

      lastIndex = match.end;
    }

    // Add remaining text after the last bold section
    if (lastIndex < content.length) {
      String remainingText = content.substring(lastIndex);
      remainingText.split('\n').forEach((line) {
        spans.add(TextSpan(
          text: line + (line.isNotEmpty ? '\n' : ''),
          style: TextStyle(fontSize: 14, color: Colors.black),
        ));
      });
    }

    return spans;
  }

  // Function to generate a response using the Google Generative AI API
  Future<void> _generateResponse(String topic) async {
    setState(() {
      isLoading = true;
      _responseTitle = "";
      _responseContent = "";
      _parsedResponseContent = [];
    });

    chatHistory.add(Content('user', [TextPart(topic)]));

    try {
      final GenerateContentResponse responseAI = await model.generateContent(chatHistory);

      // Log the raw response for debugging
      print("Raw AI Response: ${responseAI.text}");

      // Sanitize the response to remove problematic characters
      String sanitizedTitle = "Tentang: $topic";
      String rawContent = responseAI.text ?? 'Maaf, saya tidak mengerti';

      // Enhanced sanitization: Remove non-printable characters, normalize newlines, and ensure safe characters
      String sanitizedContent = rawContent
          .replaceAll(RegExp(r'[^\x20-\x7E\n]'), ' ') // Replace non-printable ASCII with space, preserve newlines
          .replaceAll(RegExp(r'\n+'), '\n') // Normalize multiple newlines to single newline
          .replaceAll(RegExp(r'[\p{C}]', unicode: true), '') // Remove control characters
          .trim(); // Remove leading/trailing whitespace

      setState(() {
        _responseTitle = sanitizedTitle;
        _responseContent = sanitizedContent;
        _parsedResponseContent = _parseMarkdown(sanitizedContent); // Parse the content for Markdown
        isLoading = false;
      });

      chatHistory.add(Content('model', [TextPart(sanitizedContent)]));
    } catch (e) {
      setState(() {
        _responseTitle = "Error";
        _responseContent = 'Failed to communicate with the API: ${e.toString()}';
        _parsedResponseContent = _parseMarkdown(_responseContent);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "TULIS",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Text(
                  "MEMBALAS",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Icon(Icons.history),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Chip(label: Text("Karangan")),
                      SizedBox(width: 8),
                      Chip(label: Text("Gugus Kalimat")),
                      SizedBox(width: 8),
                      Chip(label: Text("Sure")),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        value: _selectedStyle,
                        items: ["Resmi", "Santai", "Formal"]
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStyle = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        value: _selectedOption,
                        items: ["Pendek", "Sedang", "Panjang"]
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        value: _selectedLanguage,
                        items: ["Indonesia", "English", "Mandarin"]
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Text Field
                TextField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: "Masukkan topik yang ingin Anda tulis",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.mic),
                  ),
                ),
                SizedBox(height: 10),
                // Send Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                    ),
                    onPressed: () async {
                      if (_topicController.text.isNotEmpty) {
                        String topic = _topicController.text;
                        await _generateResponse(topic); // Generate response using AI
                      }
                    },
                    child: Text("Kirim"),
                  ),
                ),
                if (isLoading) ...[
                  SizedBox(height: 20),
                  Center(child: CircularProgressIndicator()),
                ],
                if (_responseTitle.isNotEmpty && _parsedResponseContent.isNotEmpty) ...[
                  SizedBox(height: 20),
                  // Response Section
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          "SF",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "SIDER FUSION",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      // Text("1/3"),
                      SizedBox(width: 10),
                      // Icon(Icons.arrow_back_ios, size: 16),
                      // Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    _responseTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: _parsedResponseContent, // Use the parsed TextSpans
                    ),
                  ),
                  SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Sunting"),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}