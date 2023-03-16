

import 'package:discover_music/songcard.dart';
import 'package:flutter/material.dart';

bool darkmode = false;

class Settings extends StatefulWidget {
  const Settings ({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}



class _SettingsState extends State<Settings> {

  

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color(darkmode ? 0xFF202020 : 0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(78, 146, 150, 0.455),
        // backgroundColor: Color(darkmode ? 0xFF808080 : 0xFF4E9296),
        title: const Text("Settings"),
        leading: 
        IconButton(icon: const Icon(Icons.arrow_back_sharp), onPressed: () {
        Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const SongCard()));
        },),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              leading: Text("Darkmode",
              style: TextStyle(
                color: Color(darkmode ? 0xFFC0C0C0 : 0xFF000000),
                ),),
              trailing: Switch(
                activeColor: Colors.green,
                value: darkmode, 
                onChanged: (value) {                 
                  setState(() {
                    darkmode = value;
                  });
                },
            ))
          ],
        )
      ),
    );
  }
}