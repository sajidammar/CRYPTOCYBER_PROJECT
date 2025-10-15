 import 'package:cryptocyber/screens/syegano_screens/stegano_image_screen.dart';
import 'package:cryptocyber/screens/syegano_screens/unstegano_screen.dart';
import 'package:flutter/material.dart';
class MainSteganoScreen extends StatefulWidget {
  const MainSteganoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainSteganoScreenState createState() => _MainSteganoScreenState();
}

class _MainSteganoScreenState extends State<MainSteganoScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    SteganographyScreen(),
    UnSteganoScreen()
  ];

  final List<String> _tabTitles = [
    'تعمئة الصورة',
    'فك التعمئة'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF101622),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _tabTitles[_currentIndex],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('معلومات التطبيق'),
                  content: Text('تطبيق فلاتر التحليل - تحليل الملفات والصور باستخدام تقنيات التشفير والتعمية'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('موافق'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color(0xFF101622),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Color(0xFF8E8E93),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            activeIcon: Icon(Icons.lock),
            label: ' تعمئة الصورة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            activeIcon: Icon(Icons.lock_open),
            label: 'فك التعمئة',
          ),
        ],
      ),
    );
  }
}