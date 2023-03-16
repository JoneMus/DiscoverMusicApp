import 'package:flutter/material.dart';
import "songcard.dart";
import 'settings.dart';
import 'likedsongs.dart';
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Music',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Discover Music'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  final _controller = PageController();
  var songCards = [const SongCard(),const SongCard2()];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(darkmode ? 0xFF202020 : 0xFFFFFFFF),

      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(78, 146, 150, 0.455),
        // backgroundColor: Color(darkmode ? 0xFF808080 : 0xFF4E9296),
        title: const Text("Discover Music"),
        // Settings button
        actions: [
          IconButton(icon: const Icon(Icons.favorite), onPressed: () {
            Navigator.of(context).push( MaterialPageRoute(builder: (context) => const LikedSongs()));
          },),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {
            Navigator.of(context).push( MaterialPageRoute(builder: (context) => const Settings()));
          },)
        ],
        ),


      body: PageView.builder(
      controller: _controller,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return songCards[index % songCards.length];
      }),
    );

  }  
}


