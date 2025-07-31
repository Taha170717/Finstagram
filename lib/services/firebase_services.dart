import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

final String USER_COLLECTION = "users";
class FirebaseService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Map? CurrentUserData;
  FirebaseService();

  Future<bool> loginuser({required String email, required String password}) async {

    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_userCredential.user != null) {
        CurrentUserData = await getUserdata(uid: _userCredential.user!.uid);
        return true;
      } else {
        return false;
      }
    }
    catch (e) {
      print("Login failed: $e");
      return false;
    }

  }
  Future<Map> getUserdata({required String uid}) async {
    DocumentSnapshot _doc = await _db.collection(USER_COLLECTION).doc(uid).get();
    return _doc.data() as Map;

  }

  Future <bool> registerUser({
    required String name,
    required String email,
    required String password,
    required File image
      }) async
  {
    try{
      UserCredential _userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String _userId = _userCredential.user!.uid;
      String _Filename= Timestamp.now().millisecondsSinceEpoch.toString()+ p.extension(image.path);
      UploadTask _task = _storage.ref('images/$_userId/$_Filename').putFile(image);
      return _task.then((_snapshot)async{
        String _downloadUrl = await _snapshot.ref.getDownloadURL();
       await _db.collection(USER_COLLECTION).doc(_userId).set({
          "name": name,
          "email": email,
          "image": _downloadUrl,

        });
       return true;



      });
    }
    catch (e){
      print(e);
      return false;
    }

  }
}