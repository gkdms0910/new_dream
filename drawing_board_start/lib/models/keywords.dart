import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntp/ntp.dart';

import 'text_highlight.dart';

class KeyWords extends StatefulWidget {
  const KeyWords({super.key});

  @override
  State<KeyWords> createState() => _KeyWordsState();
}

class _KeyWordsState extends State<KeyWords> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAsset('assets/words.txt'),
      builder: (context, snapshot) {
        Future<DateTime> date = serverDate();
        var contents = snapshot.data.toString();

        List<String> text = contents.split('\n');
        int counter = 0;
        // serverTime( ;
        date.then(
          (value) {
            print('$value');
          },
        );
        if (text.length > 1) {
          print(text[1]);

          counter = 12;
        }

        // print(text[1]);
        String todayWord = text[counter];
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: HighLightedText(
                color: const Color.fromARGB(255, 0, 0, 0),
                todayWord,

                //todayWord,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<DateTime> serverDate() async {
    DateTime serverDate = await NTP.now();

    //print('$serverTime');
    return serverDate;
  }
}
