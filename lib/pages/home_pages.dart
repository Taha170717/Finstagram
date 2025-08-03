import 'package:finstagram/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentpage = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Widget> _pages = [
    FeedPage(),
    ProfilePage(),
  ];

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _auth.signOut();
                  if (mounted) {
                    Navigator.pop(context); // Close dialog
                    // Navigate to login page and remove all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error logging out: $e')),
                    );
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Finstagram',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
      body: SafeArea(
        child: _pages[_currentpage],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentpage,
      selectedItemColor: Colors.purple,
      onTap: (_int) {
        setState(() {
          _currentpage = _int;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.feed),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: 'Profile',
        ),
      ],
    );
  }
}