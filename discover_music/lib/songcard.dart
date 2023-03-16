import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'likedsongs.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http; 
import 'settings.dart';

const clientId = "31ffe76fbf734e979b76489373d538fe";
const redirectUrl = "http://localhost:8080";
const randomQueries = ['%25a%25', 'a%25', '%25e%25', 'e%25', '%25i%25', 'i%25', '%25o%25', 'o%25'];
String url = "https://api.spotify.com/v1/search?q=";
String ?token;



String getRandomQuery() {
  int min = 0;
  int max = randomQueries.length;
  final random = Random();
  int query = min + random.nextInt(max-min);  
  return randomQueries[query];
}

void generateNewUrl() {
  int min = 0;
  int max = 1000;
  final random = Random();
  int offset = min + random.nextInt(max-min); 
  url = "https://api.spotify.com/v1/search?q=";
  url = url+getRandomQuery()+"&type=track&limit=1&offset="+offset.toString();
}

Future <String> getToken() async {
  return await SpotifySdk.getAccessToken(clientId: clientId, redirectUrl: redirectUrl);
}

Future <void> setToken() async {
  var accessToken = await Future.wait([getToken()]);
  token = accessToken[0];
}

Future <Track> getTrack() async {
  // var accessToken = await Future.wait([getToken()]);   
  await Future.wait([setToken()]);
  generateNewUrl();
  final response = await http.get(Uri.parse(url),
  headers: {
    // HttpHeaders.authorizationHeader: accessToken[0],
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token",
  });

  if (response.statusCode == 200) {
    return Track.fromJson(jsonDecode(response.body));
  }else {
    debugPrint(response.statusCode.toString());
    debugPrint(url);
    debugPrint(token);
    throw Exception("Failed to load track");
  }
  
}

class Track {
  final String title;
  final String imageURL;
  final String name;
  final String preview;

  const Track({
    required this.title,
    required this.imageURL,
    required this.name,
    required this.preview,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      title: json["tracks"]["items"][0]["name"], 
      imageURL: json["tracks"]["items"][0]["album"]["images"][0]["url"],
      name: json["tracks"]["items"][0]["artists"][0]["name"], 
      preview: json["tracks"]["items"][0]["preview_url"]);
  }
}

Future <Track2> getTrack2() async {
  await Future.delayed(const Duration(seconds: 1));
  generateNewUrl();
  final response = await http.get(Uri.parse(url),
  headers: {
    // HttpHeaders.authorizationHeader: accessToken[0],
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token",
  });

  if (response.statusCode == 200) {
    return Track2.fromJson(jsonDecode(response.body));
  }else {
    debugPrint(response.statusCode.toString());
    debugPrint(url);
    debugPrint(token);
    throw Exception("Failed to load track2");
  }
  
}

class Track2 {
  final String title;
  final String imageURL;
  final String name;
  final String preview;

  const Track2({
    required this.title,
    required this.imageURL,
    required this.name,
    required this.preview,
  });

  factory Track2.fromJson(Map<String, dynamic> json) {
    return Track2(
      title: json["tracks"]["items"][0]["name"], 
      imageURL: json["tracks"]["items"][0]["album"]["images"][0]["url"],
      name: json["tracks"]["items"][0]["artists"][0]["name"], 
      preview: json["tracks"]["items"][0]["preview_url"]);
  }
}

  void themeChange() {

  }


class SongCard extends StatefulWidget {
  const SongCard({super.key});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  late Future<Track> futureTrack;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureTrack = getTrack();
    if (mounted) {      
      audioPlayer.onPlayerStateChanged.listen((event) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });     
      });

      audioPlayer.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      audioPlayer.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color(darkmode ? 0xFF303030 : 0xFFFFFFFF),

      body: Center(            
          child: FutureBuilder<Track>(
          future: futureTrack,
          builder: (context, snapshot,) {
            if (snapshot.hasData) {
              audioPlayer.setReleaseMode(ReleaseMode.loop);
              audioPlayer.setSourceUrl(snapshot.data!.preview);
              // audioPlayer.setSource(UrlSource(snapshot.data!.preview));
              
              return DropShadow(
                spread: 1.5,
                blurRadius: 15,
                opacity: 1,
                child :Container(
                margin: const EdgeInsets.only(bottom: 50),
                // color: const Color.fromRGBO(78, 146, 150, 0.455),
                
                color: Color(darkmode ? 0xFF404040 : 0xFF9BC2C4),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 18, left: 20, right: 20),
                      child: Image.network(snapshot.data!.imageURL)
                    ), 
                    Text(snapshot.data!.title, 
                      style: const TextStyle(fontSize: 15, height: 2),
                    ),                  
                    Text(snapshot.data!.name,
                      style: const TextStyle(fontSize: 12, height: 3),
                    ),
                    SliderTheme(
                    data: const SliderThemeData(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2)
                    ),  
                    child: Slider(                      
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                        },
                      ),  
                      ),                  
                    Container(
                      margin: const EdgeInsets.fromLTRB(120, 10, 20, 0),
                      child: Row(                      
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                    
                      CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow
                      ),
                      iconSize: 50,
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {                
                          await audioPlayer.resume();
                        }
                      },
                      ),
                      ),
                      FloatingActionButton(
                        heroTag: null,
                      onPressed: () {
                        addSongToLikes(snapshot.data, null);
                      },
                      child: const Icon(Icons.favorite_border),
                      ),
                      ]
                      ), 
                      ),                     
                  ],
                )
                ));              
            }else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      )     
    );
  }
}


class SongCard2 extends StatefulWidget {
  const SongCard2({super.key});

  @override
  State<SongCard2> createState() => _SongCard2State();
}

class _SongCard2State extends State<SongCard2> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  late Future<Track2> futureTrack2;
  final audioPlayer2 = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void dispose() {
    audioPlayer2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureTrack2 = getTrack2();
    if (mounted) {  
      audioPlayer2.onPlayerStateChanged.listen((event) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });     
      });

      audioPlayer2.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      audioPlayer2.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color(darkmode ? 0xFF303030 : 0xFFFFFFFF),

      body: Center(
          child: FutureBuilder<Track2>(
          future: futureTrack2,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              audioPlayer2.setReleaseMode(ReleaseMode.loop);
              audioPlayer2.setSourceUrl(snapshot.data!.preview);

              return DropShadow(
                spread: 1.5,
                blurRadius: 15,
                child: Container(
                margin: const EdgeInsets.only(bottom: 50),
                color: Color(darkmode ? 0xFF404040 : 0xFF9BC2C4),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 18, left: 20, right: 20),
                      child: Image.network(snapshot.data!.imageURL)
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),                     
                      child: Text(snapshot.data!.title, 
                        style: const TextStyle(fontSize: 15, height: 2),
                      ),
                    ),                  
                    Text(snapshot.data!.name,
                      style: const TextStyle(fontSize: 12, height: 3),
                    ),
                    SliderTheme(
                      data: const SliderThemeData(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2)
                      ),  
                      child: Slider(                      
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer2.seek(position);
                        },
                      ),  
                      ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(120, 10, 20, 0),
                      child: Row(                      
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                    
                      CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow
                      ),
                      iconSize: 50,
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer2.pause();
                        } else {                
                          await audioPlayer2.resume();
                        }
                      },
                      ),
                      ),
                      FloatingActionButton(
                        heroTag: null,
                      onPressed: () {
                        addSongToLikes(null, snapshot.data);
                      },
                      child: const Icon(Icons.favorite_border),
                      ),
                      ]
                      ), 
                      ),                    
                  ],
                )
                ));              
            }else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ), 
    )     
    );
  }
}
