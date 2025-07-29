import 'package:finstagram/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double? _height, _width;
  FirebaseService? _firebaseService;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _width! * 0.05),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _imageWidget(),
                    SizedBox(height: _height! * 0.05),
                    _loginForm(),
                    SizedBox(height: _height! * 0.03),
                    _loginButton(),
                    SizedBox(height: _height! * 0.02),
                    _registerPage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageWidget() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 150,
          width: 150,
        ),
        const SizedBox(height: 16),
        const Text(
          "Welcome Back!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          "Please sign in to continue",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [_emailField(), const SizedBox(height: 16), _passwordField()],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Enter Email",
        labelText: "Email",
        prefixIcon: Icon(Icons.email, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
        ),
      ),
      onSaved: (value) {
        setState(() {
          _email = value;
        });
      },
      validator: (_value) {
        bool result = _value!.contains(RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"));
        return result ? null : "Please enter a valid email";
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Enter Password",
        labelText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
        ),
      ),
      onSaved: (value) {
        setState(() {
          _password = value;
        });
      },
      validator: (_value) =>
      _value!.length > 6 ? null : "Password must be 6+ characters",
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: _width! * 0.6,
      child: ElevatedButton(
        onPressed: _loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 5,
          padding: EdgeInsets.symmetric(vertical: _height! * 0.02),
        ),
        child: const Text(
          "Login",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _registerPage() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: const Text(
        "Don't have an account? Register",
        style: TextStyle(
          color: Colors.purpleAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      bool _result = await _firebaseService!.loginuser(
        email: _email!,
        password: _password!,
      );
      if (_result)Navigator.popAndPushNamed(context, '/home');

    }
  }
}