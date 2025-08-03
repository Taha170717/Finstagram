import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/comment_model.dart';
import 'create_post_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  Map<String, int> _currentImageIndexes = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _lastDocument == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _deletePost(String postId, List<String> imageUrls) async {
    try {
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) return;

      for (String imageUrl in imageUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('posts')
          .doc(postId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }

  Widget _buildPostHeader(Map<String, dynamic> data, String postId, List<String> imageUrls) {
    bool isCurrentUserPost = data['userId'] == currentUser?.uid;
    String? profileImageUrl = data['userProfileImage'];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: profileImageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
        )
            : const Icon(Icons.person, color: Colors.grey),
      ),
      title: Text(data['userName'] ?? 'Anonymous'),
      subtitle: Text(
        timeago.format((data['timestamp'] as Timestamp).toDate()),
      ),
      trailing: isCurrentUserPost
          ? PopupMenuButton<String>(
        onSelected: (String choice) {
          if (choice == 'delete') {
            _deletePost(postId, imageUrls);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete Post'),
          ),
        ],
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .limit(_pageSize)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }

          _lastDocument = snapshot.data!.docs.last;

          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == snapshot.data!.docs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final post = snapshot.data!.docs[index];
              final data = post.data() as Map<String, dynamic>;
              final bool isLiked = (data['likedBy'] as List?)?.contains(currentUser?.uid) ?? false;
              final List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);

              if (!_currentImageIndexes.containsKey(post.id)) {
                _currentImageIndexes[post.id] = 0;
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostHeader(data, post.id, imageUrls),
                    if (imageUrls.isNotEmpty)
                      Stack(
                        children: [
                          SizedBox(
                            height: 400,
                            child: PageView.builder(
                              itemCount: imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndexes[post.id] = index;
                                });
                              },
                              itemBuilder: (context, imageIndex) {
                                return CachedNetworkImage(
                                  imageUrl: imageUrls[imageIndex],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
                          ),
                          if (imageUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  imageUrls.length,
                                      (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == _currentImageIndexes[post.id]
                                          ? Colors.purple
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: () => _handleLike(post.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: () => _showComments(context, post.id, data),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '${data['likes'] ?? 0} likes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(data['description'] ?? ''),
                        ],
                      ),
                    ),
                    if ((data['comments'] as List?)?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () => _showComments(context, post.id, data),
                          child: Text(
                            'View all ${(data['comments'] as List?)?.length ?? 0} comments',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleLike(String postId) async {
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);

      if (!postDoc.exists) return;

      final List<dynamic> likedBy = List.from(postDoc.data()?['likedBy'] ?? []);
      final bool isLiked = likedBy.contains(currentUser!.uid);

      if (isLiked) {
        likedBy.remove(currentUser!.uid);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(currentUser!.uid);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': FieldValue.increment(1),
        });
      }
    });
  }

  void _showComments(BuildContext context, String postId, Map<String, dynamic> postData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          color: Colors.white,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  'Comments',
                  style: TextStyle(color: Colors.black),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = List.from(snapshot.data!.get('comments') ?? []);

                    return ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = CommentModel.fromMap(
                          Map<String, dynamic>.from(comments[index]),
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: comment.userProfileImage.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: comment.userProfileImage,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.person, color: Colors.grey),
                            )
                                : const Icon(Icons.person, color: Colors.grey),
                          ),
                          title: Text(comment.userName),
                          subtitle: Text(comment.text),
                          trailing: Text(
                            timeago.format(comment.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _addComment(postId),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addComment(String postId) async {
    if (currentUser == null || _commentController.text.trim().isEmpty) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      final comment = CommentModel(
        userId: currentUser!.uid,
        userName: userDoc.data()?['name'] ?? 'Anonymous',
        userProfileImage: userDoc.data()?['profileImage'] ?? '',
        text: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}