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
    // FileAnalysisTab(),
    // ImageAnalysisTab(),
  ];

  final List<String> _tabTitles = [
    'تحليل ملف',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_currentIndex],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file),
            label: 'تحليل ملف',
          ),
        ],
      ),
    );
  }
}