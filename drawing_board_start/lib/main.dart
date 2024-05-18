import 'package:drawing_board_start/firebase_options.dart';
import 'package:drawing_board_start/screens/log_in_screen.dart';
import 'package:drawing_board_start/screens/main_paint_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

const Map<String, dynamic> _testLine1 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{
    'dx': 68.94337550070736,
    'dy': 62.05980083656557
  },
  'endPoint': <String, dynamic>{
    'dx': 277.1373386828114,
    'dy': 277.32029957032194
  },
  'paint': <String, dynamic>{
    'blendMode': 3,
    'color': 4294198070,
    'filterQuality': 3,
    'invertColors': false,
    'isAntiAlias': false,
    'strokeCap': 1,
    'strokeJoin': 1,
    'strokeWidth': 4.0,
    'style': 1
  }
};
//haha
const Map<String, dynamic> _testLine2 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{
    'dx': 106.35164817830423,
    'dy': 255.9575653134524
  },
  'endPoint': <String, dynamic>{
    'dx': 292.76034659254094,
    'dy': 92.125586665872
  },
  'paint': <String, dynamic>{
    'blendMode': 3,
    'color': 4294198070,
    'filterQuality': 3,
    'invertColors': false,
    'isAntiAlias': false,
    'strokeCap': 1,
    'strokeJoin': 1,
    'strokeWidth': 4.0,
    'style': 1
  }
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  runApp(const MyApp());
}

/*class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      //이건 스트림빌더임 ㅇㅇ
      stream:
          FirebaseAuth.instance.authStateChanges(), //스트림에 authStateChanges를 등록함
      //auth 상태가 변경되면 -> user가 로그인을 하던지, 로그아웃을 하던지, 계정 삭제를 하던지
      builder: (context, snapshot) {
        //변경된 상태가 snapshot으로 빌드로 새로함.
        if (snapshot.hasData) {
          //snapshot이 데이터가 있으면
          return const MyApp(); //기존의 MyApp() 위젯 빌드
        } else {
          return const LogInPage(); //아니면 로그인해라~
        }
      },
    ));
  }
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Test',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        body: StreamBuilder<User?>(
          //이건 스트림빌더임 ㅇㅇ
          stream: FirebaseAuth.instance
              .authStateChanges(), //스트림에 authStateChanges를 등록함
          //auth 상태가 변경되면 -> user가 로그인을 하던지, 로그아웃을 하던지, 계정 삭제를 하던지
          builder: (context, snapshot) {
            //변경된 상태가 snapshot으로 빌드로 새로함.
            if (snapshot.hasData) {
              //snapshot이 데이터가 있으면
              return const MyHomePage(); //기존의 MyApp() 위젯 빌드
            } else {
              return const LogInPage(); //아니면 로그인해라~
            }
          },
        ),
      ),
    );
  }
}
