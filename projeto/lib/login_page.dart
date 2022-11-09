import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:projeto/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projeto/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool action) {
    setState(() {
      isLogin = action;
      if (isLogin) {
        titulo = 'Welcome';
        actionButton = 'Login';
        toggleButton = 'Need an account? SIGN UP.';
      } else {
        titulo = 'Create account';
        actionButton = 'Sign up';
        toggleButton = 'Go back to login.';
      }
    });
  }

  login() async {
    try {
      await context.read<AuthService>().login(email.text, password.text);
      Provider.of<GroupState>(context, listen: false).addSelf(email.text);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  signup() async {
    try {
      await context.read<AuthService>().signup(email.text, password.text);
      Provider.of<GroupState>(context, listen: false).addSelf(email.text);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  registar() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/savenight-logo.png'),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email not fount!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digit password!';
                      } else if (value.length < 6) {
                        return 'Your password need at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (isLogin) {
                          login();
                        } else {
                          signup();
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            actionButton,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setFormAction(!isLogin),
                  child: Text(toggleButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
