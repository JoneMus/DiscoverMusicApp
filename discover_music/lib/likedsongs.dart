import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'songcard.dart';
import 'settings.dart';

var listOfLikes = [];

class LikedSongs extends StatefulWidget {
  const LikedSongs({super.key});

  @override
  State<LikedSongs> createState() => _LikedSongsState();
}

// funktio jolla haetaan lisätään tykätyt listaan
void addSongToLikes(Track ?track, Track2 ?track2) {
  if (track != null) {
    for (var song in listOfLikes) {
      if (song.preview == track.preview) {
        return;
      }
    }
    listOfLikes.add(track);
    return;
  }else {
    for (var song in listOfLikes) {
      if (song.preview == track2!.preview) {
        return;
      }
    }
    listOfLikes.add(track2);
  }
  
}

// funktio jolla haetaan tiedot tykätyistä 

class _LikedSongsState extends State<LikedSongs> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }


  final player = AudioPlayer();
  bool isPlaying = false;
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {      
      player.onPlayerStateChanged.listen((event) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });     
      });
    }
  }


  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color(darkmode ? 0xFF202020 : 0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(78, 146, 150, 0.455),
        // backgroundColor: Color(darkmode ? 0xFF808080 : 0xFF4E9296),
        title: const Text("Likes"),
        leading: 
        IconButton(icon: const Icon(Icons.arrow_back_sharp), onPressed: () {
        Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const SongCard()));
        },),
      ),


      body: Center(
        child: Column(children: listOfLikes.map((song) {
          return Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            color: const Color.fromRGBO(242, 242, 242, 96),
            child: ListTile(
              leading: Image.network(song.imageURL),
              trailing: CircleAvatar(
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                  if (isPlaying){
                    player.stop();
                    
                  }else {
                    player.play(UrlSource(song.preview));
                  }
                },), 
              ),            
              title: Text(song.title),
              subtitle: Text(song.name),
            ),
          );
        }).toList()        
        ), 
      ),
    );
  }

}

