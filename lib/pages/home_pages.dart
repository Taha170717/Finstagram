import 'package:finstagram/pages/profile_page.dart';
import 'package:flutter/material.dart';

import 'feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentpage =0 ;
  final List<Widget> _pages = [
     FeedPage(),
     ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('Finstagram', style: TextStyle(color: Colors.white),),
          actions: [
            GestureDetector(
              child: Icon(Icons.add_a_photo,color: Colors.white,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 8),
              child: GestureDetector(
                child: Icon(Icons.logout,color: Colors.white,),
              ),
            )
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar(),
        body: _pages[_currentpage],
      ),
    );
  }
  Widget _bottomNavigationBar(){
    return BottomNavigationBar(
      currentIndex: _currentpage,
    selectedItemColor: Colors.purple,
        onTap: (_int){
      setState(() {
        _currentpage = _int;
      });
        },
        items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.feed),
        label: 'Feed',
      ),

      BottomNavigationBarItem(

        icon: Icon(Icons.account_box),
        label: 'Profile',
      ),
    ]);
  }

}
