import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
// variable for firestore collection 'users'
final userReference = FirebaseFirestore.instance.collection('users');

final DateTime timestamp = DateTime.now();
late User currentUser;

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String _buttonClick = "click sign in button";

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _buttonClick,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 5.0,
              ),

              SignInButton(
                  buttonType: ButtonType.google,
                  onPressed: () {
                    signInWithGoogle();
                    setState(() {
                      _buttonClick = "google";
                    });
                  }),
              SignInButton(
                  buttonType: ButtonType.github,
                  onPressed: () {
                    setState(() {
                      _buttonClick = "github";
                    });
                  }),

              SignInButton(
                  buttonType: ButtonType.youtube,
                  onPressed: () {
                    setState(() {
                      _buttonClick = "youtube";
                    });
                  }),

              SignInButton(
                  buttonType: ButtonType.instagram,
                  onPressed: () {
                    setState(() {
                      _buttonClick = "instagram";
                    });
                  }),
              //custom button
            ],
          ),
        ),
      ),
    );
  }
}
