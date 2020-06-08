import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'tab_page.dart';

class LoginPage extends StatelessWidget {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Instagram Clon',
              style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(50.0),
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _handleSignin().then((user) {
                  Navigator.pushReplacement(context, 
                    MaterialPageRoute(builder: (context) => TabPage(user))
                  );
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> _handleSignin() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = (await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken)
    )).user;
    return user;
  }
}
