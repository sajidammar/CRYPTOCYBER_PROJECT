import 'package:cryptocyber/screens/analysis_screens/image_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'file_analysis_screen.dart';

class MainAnalysisScreen extends StatefulWidget {
  const MainAnalysisScreen({super.key});

  @override
  _MainAnalysisScreenState createState() => _MainAnalysisScreenState();
}

class _MainAnalysisScreenState extends State<MainAnalysisScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    FileAnalysisTab(),
    ImageAnalysisTab()
  ];

  final List<String> _tabTitles = [
    'File Analysis',
    'Image Analysis'
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
            icon: Icon(Icons.insert_drive_file_outlined),
            activeIcon: Icon(Icons.insert_drive_file),
            label: 'File Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            activeIcon: Icon(Icons.image),
            label: 'Image Analysis',
          ),
        ],
      ),
    );
  }
}