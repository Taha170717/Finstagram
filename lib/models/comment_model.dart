import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userId;
  final String userName;
  final String userProfileImage;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}