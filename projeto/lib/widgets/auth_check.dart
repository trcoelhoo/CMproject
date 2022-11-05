import 'package:flutter/material.dart';
import 'package:projeto/save_night.dart';
import 'package:projeto/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading)
      return loading();
    else if (auth.utilizador == null)
      return LoginPage();
    else
      return SaveNight();
  }

  loading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
