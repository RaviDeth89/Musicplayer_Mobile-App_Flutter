import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musicplayer/Display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSongScreen extends StatefulWidget {
  @override
  _AddSongScreenState createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  File? _audioFile;
  bool _isLoading = false;

  Future<void> _uploadAudioFile() async {
    setState(() {
      _isLoading = true;
    });
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('audio/${DateTime.now().toString()}');
    UploadTask uploadTask = ref.putFile(_audioFile!);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference songsCollection = firestore.collection('mycollection');
    String docId = DateTime.now().toString();
    await songsCollection.doc(docId).set({
      'title': 'Song title',
      'artist': 'Artist name',
      'audioUrl': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audio file uploaded successfully'),
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.isNotEmpty) {
      String? path = result.files.single.path;
      if (path != null) {
        setState(() {
          _audioFile = File(path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Song'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _audioFile != null
                ? Text('Selected file: ${_audioFile!.path}')
                : Text('No file selected'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: Text('Pick audio file'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _audioFile != null ? _uploadAudioFile : null,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Upload audio file'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('All Records'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplaySongsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
