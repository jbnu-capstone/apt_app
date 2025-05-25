import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;

  Future<void> _handleSignIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        setState(() {
          _user = user;
        });
      }
    } catch (error) {
      print('로그인 실패: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Login")),
      body: Center(
        child: _user == null
            ? ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text("Sign in with Google"),
                onPressed: _handleSignIn,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoUrl ?? ""),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text("Hello, ${_user!.displayName}"),
                  Text(_user!.email),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text("Logout"),
                    onPressed: _handleSignOut,
                  ),
                ],
              ),
      ),
    );
  }
}
