import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/Model.dart';

class DisplaySongsScreen extends StatelessWidget {
  Stream<List<Songs>> readSong() => FirebaseFirestore.instance
      .collection('mycollection')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((e) => Songs.fromJson(e.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Songs'),
      ),
      body: StreamBuilder<List<Songs>>(
        stream: readSong(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                    child: Icon(Icons.music_note_sharp),),
                title: Text(songs[index].title.toString()),
                subtitle: Text(songs[index].artist.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MPlay(song: songs[index])),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Something Went Wrong${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MPlay extends StatefulWidget {
  final Songs song;

  MPlay({required this.song});

  @override
  _MPlayState createState() => _MPlayState();
}

class _MPlayState extends State<MPlay> with SingleTickerProviderStateMixin {
  late AnimationController iconController;
  bool isAnimated = false;
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  double _currentPosition = 0.0;
  double audioDuration = 0.0;

  @override
  void initState() {
    super.initState();
    iconController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    audioPlayer.open(
      Audio.network(widget.song.audioUrl),
      autoStart: false,
      showNotification: true,
    );
    audioPlayer.currentPosition.listen((duration) {
      if (mounted) {
        setState(() {
          _currentPosition = duration.inMilliseconds.toDouble();
        });
      }
    });
    audioPlayer.current.listen((event) {
      if (mounted) {
        setState(() {
          audioDuration = event!.audio.duration.inMilliseconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    iconController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        audioPlayer.dispose();
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Audio Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Playing Audio File Flutter"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img02.jpg",
                  width: 350,
                  height: 400,
                ),
                SizedBox(height: 30),
                Slider(
                  value: _currentPosition,
                  min: 0.0,
                  max: audioDuration,
                  onChanged: (double value) {
                    setState(() {
                      _currentPosition = value;
                    });
                    audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Icon(CupertinoIcons.backward_fill),
                      onTap: () {
                        audioPlayer.seekBy(Duration(seconds: -10));
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        AnimateIcon();
                      },
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: iconController,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      child: Icon(CupertinoIcons.forward_fill),
                      onTap: () {
                        audioPlayer.seekBy(Duration(seconds: 10));
                        audioPlayer.seek(Duration(seconds: 10));
                        audioPlayer.next();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void AnimateIcon() {
    setState(() {
      isAnimated = !isAnimated;

      if (isAnimated) {
        iconController.forward();
        audioPlayer.play();
      } else {
        iconController.reverse();
        audioPlayer.pause();
      }
    });
  }
}
