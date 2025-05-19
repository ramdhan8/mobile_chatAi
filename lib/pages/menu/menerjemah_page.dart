import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MenerjemahPage extends StatefulWidget {
  @override
  _MenerjemahPageState createState() => _MenerjemahPageState();
}

class _MenerjemahPageState extends State<MenerjemahPage> {
  String _sourceLanguage = 'Indonesia';
  String _targetLanguage = 'Inggris';
  String _inputText = '';
  String _translatedText = '';
  bool _isLoading = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    const apiKey = 'AIzaSyBnwtYHw5NBa03bcyXZL9KxBulZcF3MaGE';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<void> _translate() async {
    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    if (_inputText.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String sourceLangCode = _sourceLanguage == 'Indonesia' ? 'id' : 'en';
    String targetLangCode = _targetLanguage == 'Inggris' ? 'en' : 'id';

    final prompt = 'Translate the following text from $sourceLangCode to $targetLangCode and return only the translated text without any explanation or additional context: "$_inputText"';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      setState(() {
        _translatedText = response.text?.trim() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Tambahkan SingleChildScrollView untuk mengatasi bottom overflow
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MENERJEMAHKAN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sourceLanguage,
                  items: <String>['Indonesia', 'Inggris']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sourceLanguage = newValue!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _sourceLanguage;
                      _sourceLanguage = _targetLanguage;
                      _targetLanguage = temp;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _targetLanguage,
                  items: <String>['Inggris', 'Indonesia']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _targetLanguage = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan teks...',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _translatedText),
              readOnly: true,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _translate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Terjemahkan'),
                    ),
            ),
            SizedBox(height: 16), // Tambahkan ruang di bawah untuk memastikan tombol terlihat saat scroll
          ],
        ),
      ),
    );
  }
}