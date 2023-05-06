import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:musicplayer/HomePage.dart';//2
Future main() async{ //1
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Firebase Demo"),
        ),
        body: AddSongScreen(),
      ),
    );
  }
}
