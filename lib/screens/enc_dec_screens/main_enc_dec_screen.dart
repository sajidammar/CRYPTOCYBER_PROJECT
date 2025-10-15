import 'package:flutter/material.dart';
import 'encryption_screen.dart';
import 'decryption_screen.dart';

class MainEncryptDecryptScreen extends StatefulWidget {
  const MainEncryptDecryptScreen({super.key});

  @override
  _MainEncryptDecryptScreenState createState() => _MainEncryptDecryptScreenState();
}

class _MainEncryptDecryptScreenState extends State<MainEncryptDecryptScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const EncryptionScreen(),
    const DecryptionScreen()
  ];

  final List<String> _tabTitles = [
    'تشفير الملفات',
    'فك تشفير الملفات'
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
            icon: Icon(Icons.lock_outline),
            activeIcon: Icon(Icons.lock),
            label: 'تشفير الملفات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open_outlined),
            activeIcon: Icon(Icons.lock_open),
            label: 'فك تشفير ملف',
          ),
        ],
      ),
    );
  }
}
