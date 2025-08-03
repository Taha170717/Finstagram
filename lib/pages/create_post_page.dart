import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(
            result.paths.where((path) => path != null).map((path) => File(path!)),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload images
      List<String> imageUrls = [];
      for (File image in _selectedImages) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        Reference ref = FirebaseStorage.instance.ref().child('posts/$fileName');
        await ref.putFile(image);
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      // Create post
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser?.uid,
        'userName': userDoc.data()?['name'] ?? 'Anonymous',
        'userProfileImage': userDoc.data()?['profileImage'] ?? '',
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': [],
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _createPost,
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview/Selection Area
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImages.isEmpty
                    ? InkWell(
                  onTap: _pickImages,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate, size: 50),
                      SizedBox(height: 8),
                      Text(
                        'Add Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                    : Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: _pickImages,
                              child: Container(
                                width: 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Write a title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Description Input
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Write a description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}