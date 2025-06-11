import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';

class ChatpdfPage extends StatefulWidget {
  @override
  _ChatpdfPageState createState() => _ChatpdfPageState();
}

class _ChatpdfPageState extends State<ChatpdfPage> {
  // Function to handle file picking
  Future<void> _pickFile() async {
    // try {
    //   FilePickerResult? result = await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //     allowedExtensions: ['pdf', 'doc', 'ppt'], // Allow pdf, doc, ppt files
    //   );

    //   if (result != null && result.files.single.path != null) {
    //     PlatformFile file = result.files.single;
    //     print('File picked: ${file.name}, Size: ${file.size} bytes');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('File ${file.name} selected successfully!')),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('No file selected.')),
    //     );
    //   }
    // } catch (e) {
    //   print('Error picking file: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error picking file: $e')),
    //   );
    // }
  }

  // Function to handle PDF link input
  Future<void> _inputPdfLink() async {
    TextEditingController linkController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Tautan PDF'),
          content: TextField(
            controller: linkController,
            decoration: InputDecoration(
              hintText: '',
              labelText: 'URL PDF',
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                String link = linkController.text.trim();
                if (link.isNotEmpty) {
                  print('PDF link submitted: $link');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tautan PDF: $link')),
                  );
                  // Add logic here to handle the PDF link (e.g., fetch the PDF)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tautan tidak boleh kosong!')),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                SizedBox(width: 10),
                Icon(Icons.description, color: Colors.purple, size: 40),
                SizedBox(width: 10),
                Icon(Icons.slideshow, color: Colors.orange, size: 40),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Klik atau seret file ke halaman ini untuk mengunggah atau masukkan tautan PDF',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Format: pdf / doc / ppt',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile, // Call the file picker function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload),
                  SizedBox(width: 5),
                  Text('Unggah'),
                ],
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _inputPdfLink, // Call the link input function
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link, size: 16),
                  SizedBox(width: 5),
                  Text('Tautan PDF'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}