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
  bool _isLoading = false;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: _width! * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _imageWidget(),
                        SizedBox(height: _height! * 0.05),
                        _loginFormCard(),
                        SizedBox(height: _height! * 0.04),
                        _loginButton(),
                        SizedBox(height: _height! * 0.03),
                        _registerPage(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Logging in...',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _imageWidget() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.asset(
            'assets/images/logo.png',
            height: 160,
            width: 160,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Welcome Back!",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Please sign in to continue",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _loginFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _emailField(),
            const SizedBox(height: 20),
            _passwordField(),
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "Enter your email",
        labelText: "Email",
        prefixIcon: const Icon(Icons.email, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      onSaved: (value) {
        setState(() {
          _email = value;
        });
      },
      validator: (_value) {
        bool result = _value!.contains(RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$"));
        return result ? null : "Please enter a valid email";
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "Enter your password",
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      onSaved: (value) {
        setState(() {
          _password = value;
        });
      },
      validator: (_value) =>
      _value!.length > 6 ? null : "Password must be at least 6 characters",
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: _width! * 0.65,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginUser,  // Disable button while loading
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? Colors.grey : Colors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 5,
          padding: EdgeInsets.symmetric(vertical: _height! * 0.02),
        ),
        child: Text(
          _isLoading ? "Please wait..." : "Login",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
      setState(() => _isLoading = true);

      try {
        _loginFormKey.currentState!.save();
        bool _result = await _firebaseService!.loginuser(
          email: _email!,
          password: _password!,
        );

        if (_result) {
          if (mounted) {
            Navigator.popAndPushNamed(context, '/home');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed. Please check your credentials.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

}