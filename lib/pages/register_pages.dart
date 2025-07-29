import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _width! * 0.05),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: _height! * 0.03),
                  title(),
                  SizedBox(height: _height! * 0.02),
                  _profileimage(),
                  SizedBox(height: _height! * 0.03),
                  _registerform(),
                  SizedBox(height: _height! * 0.03),
                  _registerbutton(),
                  SizedBox(height: _height! * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerform() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _usernamefield(),
          SizedBox(height: _height! * 0.02),
          _emailField(),
          SizedBox(height: _height! * 0.02),
          _passwordField(),
        ],
      ),
    );
  }

  Widget _usernamefield() {
    return TextFormField(
      decoration: _inputDecoration("Username", Icons.person),
      validator: (_value) =>
      _value!.isNotEmpty ? null : "Username cannot be empty",
      onSaved: (_value) {
        username = _value;
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      decoration: _inputDecoration("Email", Icons.email),
      onSaved: (value) {
        email = value;
      },
      validator: (_value) {
        bool result = RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
            .hasMatch(_value!);
        return result ? null : "Please enter a valid email";
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: _inputDecoration("Password", Icons.lock),
      onSaved: (value) {
        password = value;
      },
      validator: (_value) => _value!.length > 6
          ? null
          : "Password must be longer than 6 characters",
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: "Enter $label",
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.purple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.purple, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
      ),
    );
  }

  Widget _registerbutton() {
    return MaterialButton(
      onPressed: _registerUser,
      minWidth: _width! * 0.6,
      height: _height! * 0.06,
      color: Colors.purple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'Register',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: _height! * 0.20,
          width: _width! * 0.40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.purple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget title() {
    return const Text(
      "Finstagram",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  void _registerUser() {
    if (_registerFormKey.currentState!.validate() && _image != null) {
      _registerFormKey.currentState!.save();
      print("✅ Registered successfully!");
      print("Username: $username");
      print("Email: $email");
      print("Password: $password");
    } else {
      print("⚠️ Form is not valid or image not selected.");
    }
  }
}
