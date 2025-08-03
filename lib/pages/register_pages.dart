import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:finstagram/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  double? _height, _width;
  String? username;
  String? email;
  String? password;
  File? _image;
  bool _isLoading = false;

  FirebaseService? _firebaseService;

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
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _header(),
                    _mainCard(),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              // Center loader
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        SizedBox(height: _height! * 0.1),
        const Text(
          "Welcome to Finstagram",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Create a new account",
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        SizedBox(height: _height! * 0.05),
      ],
    );
  }

  Widget _mainCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _width! * 0.05),
        child: Column(
          children: [
            SizedBox(height: _height! * 0.02),
            _profileimage(),
            SizedBox(height: _height! * 0.02),
            _registerform(),
            SizedBox(height: _height! * 0.02),
            _registerbutton(),
          ],
        ),
      ),
    );
  }

  Widget _profileimage() {
    ImageProvider imageProvider;
    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else {
      imageProvider = const NetworkImage("https://i.pravatar.cc/300");
    }

    return GestureDetector(
      onTap: () async {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);

        if (result != null) {
          setState(() {
            _image = File(result.files.first.path!);
          });
        }
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.purple.shade100,
        child: ClipOval(
          child: Image(
            image: imageProvider,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// Registration Form Section
  Widget _registerform() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _textField("Username", Icons.person, false, (value) => username = value),
          SizedBox(height: _height! * 0.02),
          _textField("Email", Icons.email, false, (value) => email = value),
          SizedBox(height: _height! * 0.02),
          _textField("Password", Icons.lock, true, (value) => password = value),
        ],
      ),
    );
  }

  Widget _textField(
      String label, IconData icon, bool isPassword, Function(String?) onSave) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: label,
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label cannot be empty";
        } else if (label == "Email" &&
            !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                .hasMatch(value)) {
          return "Enter a valid email";
        } else if (label == "Password" && value.length < 6) {
          return "Password should be at least 6 characters";
        }
        return null;
      },
      onSaved: (value) => onSave(value),
    );
  }

  Widget _registerbutton() {
    return MaterialButton(
      onPressed: _registerUser,
      minWidth: _width! * 0.6,
      height: _height! * 0.07,
      color: Colors.deepPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Register',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _registerUser() async {
    if (_registerFormKey.currentState!.validate() && _image != null) {
      _registerFormKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      bool _result = await _firebaseService!.registerUser(
        name: username!,
        email: email!,
        password: password!,
        image: _image!,
      );

      setState(() {
        _isLoading = false;
      });

      if (_result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Failed. Try again!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete all fields and upload a profile picture."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}